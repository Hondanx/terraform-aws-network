
# Calling the Module
module "networking" {
  # 1. Source: Where is the module folder located?
  source = "./vpc_module"

  # 2. Passing Arguments: Overriding the variables
  vpc_cidr = "99.99.0.0/16"

  # Pass the Public Subnets (Tier 1) as a list
  public_subnets = [
    "99.99.0.0/19",
    "99.99.32.0/19"
  ]

  # Pass the Private Subnets (Tier 2)
  private_subnets = [
    "99.99.64.0/19",
    "99.99.96.0/19"
  ]

  # Pass the Internal DB Subnets (Tier 3)
  internal_subnets = [
    "99.99.128.0/19",
    "99.99.160.0/19"
  ]
}

# 3. (Optional) Output specific data from the module
output "vpc_id" {
  value = module.networking.vpc_id
}
