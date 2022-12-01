# Start the rig

You can start the rig by

```
$ make up password config
```

After about **2 minutes** the instance should be reachable via **rdp**.
About **10 minutes** later, the instance should be provisioned.

Now you can use the DCV client to connect.

A `./config.dcv` file is generated with all necessary information to
connect to the instance.

```
$ make connect
```

will connect you to the instance.

# First time connect

On the desktop you will find a `$home\Desktop\provisioning` folder that contains some log files about the deployment. 
You can simply delete this folder if you want.
