locals {
  workspaces = {
    default = "${local.stg}"
    stg     = "${local.stg}"

    # prd     = "${local.prd}"
  }

  workspace = "${local.workspaces[terraform.workspace]}"

  # S(olr)C(loud)
  name = "sc-${terraform.workspace}"

  tags = {
    Terraform   = "true"
    Environment = "${terraform.workspace}"
  }
}
