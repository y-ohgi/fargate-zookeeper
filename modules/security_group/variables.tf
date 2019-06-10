variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "myapp"
}

variable "description" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  default     = ""
}

variable "ingress" {
  description = "List of ingress rules. (Simplified)"
  default     = []
}
