variable "prefix" {
  description = "prefixing resources"
  default     = "rig"
}

variable "app_tag" {
  description = "application tag"
  default     = "gaming-rig"
}

variable "rig_ami_name" {
  description = "ami_name"
  default     = "gaming-rig"
}

variable "rig_ami_root_ebs_size" {
  description = "Size of the root_ebs_volume of the image."
  default     = 8
}

variable "instance_type" {
  description = "prefered instance type for the gaming rig"
  default     = "g5.xlarge"
  validation {
    condition = contains([
      "g5.xlarge",
      "g5.2xlarge",
      "g5.4xlarge",
      "g5.8xlarge",
      "g5.16xlarge"],
    var.instance_type)
    error_message = <<-EOT
    You can use the following instance types for the gaming rig
    
    * g5.xlarge
    * g5.2xlarge
    * g5.4xlarge
    * g5.8xlarge
    * g5.16xlarge
    EOT
  }
}

variable "increase_bet_by" {
  description = "increase the current bet by x (e.g.: 0.2)"
  type        = number
  default     = 0
}

variable "bet_valid_until" {
  description = "guarant price bet for given time (e.g. 1h)"
  type        = string
  default     = "1h"
}

variable "availability_zone" {
  description = "number in array of possible availability_zones"
  type        = number
  default     = 0
}

variable "use_spot_instance" {
  description = "use spot instance if available"
  type        = bool
  default     = true
}

variable "use_own_ami" {
  description = "Try to use own ami."
  type        = bool
  default     = false
}
