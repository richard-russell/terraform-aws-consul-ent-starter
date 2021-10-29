variable "allowed_inbound_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks to permit inbound traffic from to Consul servers"
  default     = null
}

variable "allowed_inbound_cidrs_ssh" {
  type        = list(string)
  description = "List of CIDR blocks to give SSH access to Consul nodes"
  default     = null
}

variable "consul_license_filepath" {
  type        = string
  description = "Absolute filepath to location of Consul license file"
}

variable "consul_license_name" {
  type        = string
  description = "The file name for the Consul license file as it will be stored in S3"
  default     = "consul.hclic"
}

variable "consul_version" {
  type        = string
  default     = "1.10.3"
  description = "Consul version"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "m5.xlarge"
}

variable "key_name" {
  type        = string
  description = "key pair to use for SSH access to instance"
  default     = null
}

variable "kms_key_deletion_window" {
  type        = number
  default     = 7
  description = "Duration in days after which the key (used for S3 bucket encryption) is deleted after destruction of the resource (must be between 7 and 30 days)."
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags which specify the subnets to deploy Consul into"
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix used for tagging and naming AWS resources"
}

variable "node_count_servers" {
  type        = number
  description = "Number of Consul servers to deploy in ASG"
  default     = 5
}

variable "secrets_manager_arn_gossip" {
  type        = string
  description = "Secrets manager ARN where gossip encryption key is stored"
}

variable "secrets_manager_arn_tls" {
  type        = string
  description = "Secrets manager ARN where TLS cert info is stored"
}

variable "secrets_manager_arn_acl_token_server" {
  type        = string
  description = "Secrets manager ARN where Consul server default ACL token is stored"
}

variable "user_supplied_userdata_path_server" {
  type        = string
  description = "(Optional) File path to custom userdata script for Consul servers being supplied by the user"
  default     = null
}

variable "user_supplied_ami_id" {
  type        = string
  description = "AMI ID to use with Consul servers"
  default     = null
}

variable "user_supplied_iam_role_name_server" {
  type        = string
  description = "(OPTIONAL) User-provided IAM role name for Consul servers. This will be used for the instance profile provided to the AWS launch configuration. The minimum permissions must match the defaults generated by the IAM submodule for cloud auto-join, secrets manager access, and KMS"
  default     = null
}

variable "user_supplied_kms_key_arn" {
  type        = string
  description = "(Optional) User-provided KMS key ARN. This is used for S3 bucket encryption. If not supplied, the module will generate one."
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Consul will be deployed"
}
