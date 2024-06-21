######################
#  EC2 Bastion Host  #
######################

resource "aws_instance" "bastion" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  user_data = file("scripts/keys.sh")

  tags = merge(
    local.tags,
    {
      Name        = "bastion-host",
      environment = "${var.environment-name}"
    }
  )
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment-name}-bastion"
  description = "Security Group for Bastion host"
  vpc_id      = aws_vpc.primary-vpc.id

  tags = merge(
    local.tags,
    {
      Name        = "${var.environment-name}-bastion",
      environment = "${var.environment-name}"
    }
  )
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["70.171.0.72/32"] #Change to allowed IPs
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["70.171.0.72/32"]
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["70.171.0.72/32"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

#################
# ELK Stack EC2 #
#################

resource "aws_instance" "es_host" {
  instance_type = "t2.large"
  key_name      = var.key_name


  launch_template {
    name    = "ES-HOST"
    version = "$Latest"
  }

  user_data = file("scripts/elasticinstall.sh")

  tags = merge(
    local.tags,
    {
      Name        = "es-host",
      environment = "${var.environment-name}"
    }
  )
}

resource "aws_security_group" "es_sg" {
  name        = "es-sg"
  description = "Security group for Elasticsearch and Kibana"
  vpc_id      = aws_vpc.primary-vpc.id

  ingress {
    description = "Elasticsearch HTTP API"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }


  ingress {
    description = "Kibana HTTP API"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-es-kibana-sg"
    }
  )
}