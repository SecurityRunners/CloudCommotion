data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_route_table" "subnet_route_tables" {
  count     = length(data.aws_subnets.vpc_subnets.ids)
  subnet_id = tolist(data.aws_subnets.vpc_subnets.ids)[count.index]
}

locals {
  public_subnets = [
    for rt in data.aws_route_table.subnet_route_tables :
    rt.subnet_id if length([for r in rt.routes : r.gateway_id if startswith(r.gateway_id, "igw-")]) > 0
  ]

  private_subnets = [
    for rt in data.aws_route_table.subnet_route_tables :
    rt.subnet_id if length([for r in rt.routes : r.gateway_id if startswith(r.gateway_id, "igw-")]) == 0
  ]
}
