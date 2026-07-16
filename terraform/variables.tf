variable "aws_region" {
  description = "region in which the resources are deployed"
  type        = string
}

variable "env" {
  description = "env you want to use"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "k8s_version" {
  description = ""
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "ami_type" {
  description = "EKS-optimized AMI type used by both node groups"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the app node group"
  type        = string
}

variable "desired_nodes" {
  description = " desired number of worker nodes running"
  type        = number
}

variable "app_min_nodes" {
  description = ""
  type        = number
}

variable "app_max_nodes" {
  description = ""
  type        = number
}

variable "monitoring_instance_type" {
  description = "Instance type for the dedicated monitoring node group"
  type        = string
}

variable "monitoring_desired_nodes" {
  description = "desired number of monitoring nodes running"
  type        = number
}

variable "monitoring_min_nodes" {
  description = ""
  type        = number
}

variable "monitoring_max_nodes" {
  description = ""
  type        = number
}

variable "github_repo" {
  description = "repo that's allowed to assume the CI deploy role"
  type        = string
}

variable "namespace" {
  description = ""
  type        = string
}

variable "ecr_repo_name" {
  description = "Name of the ECR repo the app image gets pushed to"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = ""
  type        = list(string)
}
