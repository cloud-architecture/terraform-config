provider "aws" {}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

module "aws_az_1b" {
  source = "../modules/aws_az"

  az = "1b"
  bastion_ami = "ami-53d4a344"
  bastion_config = "${file("${path.module}/config/bastion-env")}"
  env = "${var.env}"
  gateway_id = "${aws_internet_gateway.gw.id}"
  index = "${var.index}"
  nat_ami = "ami-12c5b205"
  nat_instance_type = "c3.8xlarge"
  public_subnet = "10.10.1.0/24"
  vpc_id = "${aws_vpc.main.id}"
  workers_com_subnet = "${var.workers_com_subnet_1b}"
  workers_org_subnet = "${var.workers_org_subnet_1b}"
}

module "aws_az_1e" {
  source = "../modules/aws_az"

  az = "1e"
  bastion_ami = "ami-53d4a344"
  bastion_config = "${file("${path.module}/config/bastion-env")}"
  env = "${var.env}"
  gateway_id = "${aws_internet_gateway.gw.id}"
  index = "${var.index}"
  nat_ami = "ami-12c5b205"
  nat_instance_type = "c3.8xlarge"
  public_subnet = "10.10.4.0/24"
  vpc_id = "${aws_vpc.main.id}"
  workers_com_subnet = "${var.workers_com_subnet_1e}"
  workers_org_subnet = "${var.workers_org_subnet_1e}"
}

resource "null_resource" "outputs_signature" {
  triggers {
    bastion_security_group_id_1b = "${module.aws_az_1b.bastion_sg_id}"
    bastion_security_group_id_1e = "${module.aws_az_1e.bastion_sg_id}"
    gateway_id = "${aws_internet_gateway.gw.id}"
    nat_id_1b = "${module.aws_az_1b.nat_id}"
    nat_id_1e = "${module.aws_az_1e.nat_id}"
    public_subnet_1b = "${module.aws_az_1b.public_subnet}"
    public_subnet_1e = "${module.aws_az_1e.public_subnet}"
    vpc_id = "${aws_vpc.main.id}"
    workers_com_subnet_1b = "${var.workers_com_subnet_1b}"
    workers_com_subnet_1b_id = "${module.aws_az_1b.workers_com_subnet_id}"
    workers_com_subnet_1e = "${var.workers_com_subnet_1e}"
    workers_com_subnet_1e_id = "${module.aws_az_1e.workers_com_subnet_id}"
    workers_org_subnet_1b = "${var.workers_org_subnet_1b}"
    workers_org_subnet_1b_id = "${module.aws_az_1b.workers_org_subnet_id}"
    workers_org_subnet_1e = "${var.workers_org_subnet_1e}"
    workers_org_subnet_1e_id = "${module.aws_az_1e.workers_org_subnet_id}"
  }
}
