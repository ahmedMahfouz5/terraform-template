module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  us_availability_zone = var.us_availability_zone
}

module "security_group" {
  source              = "./security-groups"
  ec2_sg_name_ssh         = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id              = module.networking.vpc_id
  ec2_sg_name_http = "Allow port 8080 for jenkins"
}

module "compute" {
  source                    = "./compute"
  ec2_ami_id                = var.ec2_ami_id
  instance_type             = var.instance_type
  tag_name                  = "Ubuntu Linux EC2"
  public_key                = var.public_key
  subnet_id                 = tolist(module.networking.public_subnets)[0]
  sg_for_jenkins            = [module.security_group.sg_ec2_sg_ssh_http_id, module.security_group.sg_ec2_port_8080_id]
  enable_public_ip_address  = true
  user_data_install_jenkins = templatefile("./template/template.sh", {})
}