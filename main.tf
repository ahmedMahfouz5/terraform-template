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
  user_data_install = templatefile("./template/template.sh", {})
}

module "lb_target_group" {
  source                   = "./lb-target-group"
  lb_target_group_name     = "lb-target-group"
  lb_target_group_port     = 80
  lb_target_group_protocol = "HTTP"
  vpc_id                   = module.networking.vpc_id
  ec2_instance_id          = module.compute.ec2_instance_id
}

module "alb" {
  source                    = "./load-balancer"
  lb_name                   = "alb"
  is_external               = false
  lb_type                   = "application"
  sg_enable_ssh_https       = module.security_group.sg_ec2_sg_ssh_http_id
  subnet_ids                = tolist(module.networking.public_subnets)
  tag_name                  = "alb"
  lb_target_group_arn       = module.lb_target_group.lb_target_group_arn
  lb_listner_port           = 80
  lb_listner_protocol       = "HTTP"
  lb_listner_default_action = "forward"
  lb_https_listner_port     = 80
  lb_https_listner_protocol = "HTTP"
  #dev_proj_1_acm_arn        = module.aws_ceritification_manager.dev_proj_1_acm_arn
  lb_target_group_attachment_port = 80
}