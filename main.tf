module "networking" {
    source               = "./modules/networking"
    vpc_cidr             = var.vpc_cidr
    vpc_name             = var.vpc_name
    cidr_public_subnet   = var.cidr_public_subnet
    availability_zone = var.availability_zone
    cidr_private_subnet  = var.cidr_private_subnet
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  name        = var.name
  environment = var.environment
}

module "security_group" {
  source              = "./modules/security-groups"
  ec2_sg_name         = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id              = module.networking.capstoneJenkins_vpc_id
  ec2_jenkins_sg_name = "Allow port 8080 for jenkins"
}


module "jenkins" {
  source                    = "./modules/jenkins"
  ami_id                    = var.ec2_ami_id
  instance_type             = "t2.medium"
  tag_name                  = "Jenkins:Ubuntu Linux EC2"
  public_key                = var.public_key
  subnet_id                 = tolist(module.networking.capstoneJenkins_public_subnets)[0]
  sg_for_jenkins            = [module.security_group.sg_ec2_ssh_http_id, module.security_group.sg_ec2_jenkins_port_8080]
  enable_public_ip_address  = true
  user_data_install_jenkins = templatefile("./modules/jenkins-runner-script/jenkins-installer.sh", {})
}
#load balancer
/*
module "lb_target_group" {
  source                   = "./modules/load-balancer-target-group"
  lb_target_group_name     = "jenkins-lb-target-group"
  lb_target_group_port     = 8080
  lb_target_group_protocol = "HTTP"
  vpc_id                   = module.networking.capstoneJenkins_vpc_id
  ec2_instance_id          = module.jenkins.jenkins_ec2_instance_id
}

module "alb" {
  source                    = "./modules/load-balancer"
  lb_name                   = "capstoneJenkins-alb"
  is_external               = false
  lb_type                   = "application"
  sg_enable_ssh_https       = module.security_group.sg_ec2_ssh_http_id
  subnet_ids                = tolist(module.networking.capstoneJenkins_public_subnets)
  tag_name                  = "capstoneJenkins-alb"
  lb_target_group_arn       = module.lb_target_group.capstoneJenkins_lb_target_group_arn
  ec2_instance_id           = module.jenkins.jenkins_ec2_instance_id
  lb_listner_port           = 80
  lb_listner_protocol       = "HTTP"
  lb_listner_default_action = "forward"
  lb_https_listner_port     = 443
  lb_https_listner_protocol = "HTTPS"
  capstoneJenkins_acm_arn        = module.aws_ceritification_manager.capstoneJenkins_acm_arn
  lb_target_group_attachment_port = 8080
}

module "hosted_zone" {
  source          = "./modules/hosted-zone"
  domain_name     = "jenkins.timileyindaso.com"
  aws_lb_dns_name = module.alb.aws_lb_dns_name
  aws_lb_zone_id  = module.alb.aws_lb_zone_id
}

module "aws_ceritification_manager" {
  source         = "./modules/certificate-manager"
  domain_name    = "jenkins.timileyindaso.com"
  hosted_zone_id = module.hosted_zone.hosted_zone_id
}

*/
