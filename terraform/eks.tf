module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.allowed_cidr_blocks

  enable_cluster_creator_admin_permissions = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      addon_version = "v1.12.4-eksbuild.17"
    }
    kube-proxy = {
      addon_version = "v1.34.6-eksbuild.11"
    }
    vpc-cni = {
      addon_version = "v1.21.2-eksbuild.2"
    }
    aws-ebs-csi-driver = {
      addon_version            = "v1.62.0-eksbuild.1"
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
    }
  }

  self_managed_node_groups = {
    "app-nodes" = {
      ami_type      = var.ami_type
      instance_type = var.instance_type

      min_size     = var.app_min_nodes
      max_size     = var.app_max_nodes
      desired_size = var.desired_nodes

      # lets the app's Helm chart target this pool explicitly via
      # nodeSelector, instead of landing here only "by elimination"
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                flags:
                  - "--node-labels=role=app"
          EOT
        }
      ]
    }

    "monitoring-nodes" = {
      ami_type      = var.ami_type
      instance_type = var.monitoring_instance_type

      min_size     = var.monitoring_min_nodes
      max_size     = var.monitoring_max_nodes
      desired_size = var.monitoring_desired_nodes

      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                flags:
                  - "--register-with-taints=dedicated=monitoring:NoSchedule"
                  - "--node-labels=role=monitoring"
          EOT
        }
      ]
    }
  }

  tags = {
    Project = "devops-assignment"
  }
}
