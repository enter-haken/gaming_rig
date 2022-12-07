<powershell>

$ProvisioningBasePath = "$home\Desktop\provisioning"
$LogFile = "$ProvisioningBasePath\info.log"
$ErrorFile = "$ProvisioningBasePath\error.log"

New-Item $ProvisioningBasePath -ItemType Directory

function log($msg) {
  $logtime = [DateTime]::Now.ToString("s")
  Write-Output "$logtime - $msg" | Out-File $LogFile -append
}

function error($msg) {
  $logtime = [DateTime]::Now.ToString("s")
  Write-Output "$logtime - $msg" | Out-File $ErrorFile -append
}

function install-chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n allowGlobalConfirmation
}

function download-nvidia-drivers {
  $Bucket = "ec2-windows-nvidia-drivers"
  $KeyPrefix = "latest"
  $LocalPath = Join-Path $ProvisioningBasePath "NVIDIA"
  $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
  foreach ($Object in $Objects) {
      $LocalFileName = $Object.Key
      if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
          $LocalFilePath = Join-Path $LocalPath $LocalFileName
          Copy-S3Object `
            -BucketName $Bucket `
            -Key $Object.Key `
            -LocalFile $LocalFilePath `
            -Region us-east-1
      }
  }
}

function install_nvidia_drivers() {
    $install_dir = Join-Path $ProvisioningBasePath "NVIDIA\latest"
    $installation_file = Get-ChildItem $install_dir | Select-Object -First 1
	
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = Join-Path $install_dir $installation_file
    $pinfo.UseShellExecute = $false
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.Arguments = '-s'
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start()
    $p.WaitForExit()
}

function disable_licensing_page {
  New-ItemProperty `
    -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" `
    -Name "NvCplDisableManageLicensePage" `
    -PropertyType "DWord" `
    -Value "1"
}

function download_and_install_dcv_server() {
    log "downloading dcv server"

    New-Item -Path "$ProvisioningBasePath\dcv" -ItemType Directory

    $InstallationFile = "$ProvisioningBasePath\dcv\nice-dcv-server-x64-Release.msi"
    $InstallationSoure = ("https://d1uj6qtbmh3dt5.cloudfront.net/2022.2/Servers/" +
      "nice-dcv-server-x64-Release-2022.2-13907.msi")

    Invoke-WebRequest -Uri $InstallationSoure -OutFile $InstallationFile 

    $args=("/i $InstallationFile /quiet /norestart /l*v " +
      "$ProvisioningBasePath\dcv_install_msi.log")

    Start-Process msiexec.exe -ArgumentList "$args" -Wait

    $storageDir = "C:\dcv-session-storage"
    New-Item -Path $storageDir -ItemType Directory 

    $registyRoot = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv"
    New-Item -Path "$registyRoot\session-management" -Force
    New-Item -Path "$registyRoot\filestorage" -Force
    New-Item -Path "$registyRoot\connectivity" -Force
    New-Item -Path "$registyRoot\display" -Force
    
    # This creates a dcv server session 
    New-ItemProperty -Path "$registyRoot\session-management" -Name create-session -PropertyType DWord -Value 1
    New-ItemProperty -Path "$registyRoot\session-management" -Name owner -Value Administrator 
    New-ItemProperty -Path "$registyRoot\filestorage" -Name storage-root -Value $storageDir
    New-ItemProperty -Path "$registyRoot\display" -Name max-num-heads -Value 1

    # This is optional. quality is poor for game performance
    New-ItemProperty -Path "$registyRoot\connectivity" -Name enable-quic-frontend -Value 1
}

function auto_login() {
  # TODO: send cloud watch events instead of writing to file
  $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
  $Password = (Get-SSMParameter -WithDecryption $true -Name '${password_ssm_parameter}').Value
  net user Administrator "$Password"

  New-ItemProperty -Path $RegistryPath -Name 'AutoAdminLogon' 
  Set-ItemProperty -Path $RegistryPath -Name 'AutoAdminLogon' -Value "1" 

  New-ItemProperty -Path $RegistryPath -Name 'DefaultUsername' 
  Set-ItemProperty -Path $RegistryPath -Name 'DefaultUsername' -Value "Administrator" 

  New-ItemProperty -Path $RegistryPath -Name 'DefaultPassword' 
  Set-ItemProperty -Path $RegistryPath -Name 'DefaultPassword' -Value "$Password" 
}

# function parsec() {
#     $InstallationFile = "$ProvisioningBasePath\parsec\Parsec-Cloud-Preparation-Tool-master.zip"
#     $InstallationPath = "C:\parsec"
#     $InstallationSoure = "https://github.com/parsec-cloud/Parsec-Cloud-Preparation-Tool/archive/refs/heads/master.zip"
# 
#     New-Item -Path "$ProvisioningBasePath\parsec" -ItemType Directory
#     New-Item -Path $InstallationPath -ItemType Directory 
# 
#     Invoke-WebRequest -Uri $InstallationSoure -OutFile $InstallationFile 
#     Expand-Archive $InstallationFile -DestinationPath $InstallationPath
# 
#     $Entrypoint = "$InstallationExtractPath\PostInstall\PostInstall.ps1"
# 
#     # start on login
#     $Action = New-ScheduledTaskAction -Execute powershell.exe -WorkingDirectory $InstallationPath -Argument "-Command `"$Entrypoint -DontPromptPasswordUpdateGPU`""
#     $Trigger = New-ScheduledTaskTrigger -AtLogon -RandomDelay $(New-TimeSpan -seconds 30)
#     $Trigger.Delay = "PT30S"
#     $TaskName = "Parsec-Cloud-Preparation-Tool"
#     $SelfDestruct = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command `"Disable-ScheduledTask -TaskName $TaskName`""
#     Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action, $SelfDestruct -RunLevel Highest 
#     log "ScheduledTask created for parsec"
# }

function cleanup() {
    Remove-Item -Recurse -Force $ProvisioningBasePath\NVIDIA 
    Remove-Item -Recurse -Force $ProvisioningBasePath\dcv
    Remove-Item -Recurse -Force $ProvisioningBasePath\parsec

    Remove-Item 'C:\Users\Administrator\EC2 Feedback.website'
    Remove-Item 'C:\Users\Administrator\EC2 Microsoft Windows Guide.website'
}


log "start provisioning"

try {
  install-chocolatey
  log "chocolatey installed"

  Install-PackageProvider -Name NuGet -Force
  log "NuGet installed"

  choco install awscli
  log "aws cli installed"

  choco install chromium
  log "chromium installed"

  choco install steam
  log "steam installed"

  log "downloading NVIDIA drivers"
  download-nvidia-drivers
  log "NVIDIA drivers downloaded"

  disable_licensing_page

  log "installing NVIDIA drivers"
  install_nvidia_drivers
  log "NVIDIA drivers installed"

  log "download and install dcv server"
  download_and_install_dcv_server
  log "dcv server installed"

  log "setup auto_login"
  auto_login
  
  log "install parsec"
  choco install parsec
  log "parsec installed"

  cleanup

  log "restart"
  Restart-Computer
}
catch
{
  error $_.Exception.Message  
  error "Provisioning aborted"
}

</powershell>
