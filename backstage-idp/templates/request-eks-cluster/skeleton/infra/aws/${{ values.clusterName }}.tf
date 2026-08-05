# requested through the portal, don't hand-edit - raise a new request instead
module "${{ values.clusterName }}" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/aws-eks?ref=main"

  name               = "${{ values.clusterName }}"
  kubernetes_version = "${{ values.kubernetesVersion }}"
  node_instance_type = "${{ values.nodeInstanceType }}"
  node_count         = ${{ values.nodeCount }}

  tags = {
    Team        = "${{ values.team }}"
    Environment = "${{ values.environment }}"
    ManagedBy   = "terraform"
  }
}
