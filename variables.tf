variable "prefix" {
  description = "prefixing resources"
  default     = "rig"
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
  description = "increase the current bet by x (eg.: 0.2)"
  type        = number
  default     = 0
}

variable "availability_zone" {
  description = "number in array of possible availability_zones"
  type        = number
  default     = 0
}
