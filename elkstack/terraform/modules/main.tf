#########################
# Elasticsearch Module  #
#########################


###################################
# Elasticsearch Host EC2 Instance #
###################################
resource "aws_instance" "es_host" {
  instance_type               = var.es_instance_type
  ami                         = var.es_ec2_ami
  subnet_id                   = var.es_subnet_id
  key_name                    = var.es_key_name
  iam_instance_profile        = var.iam_instance_profile
  vpc_security_group_ids      = [aws_security_group.es_sg.id]
  associate_public_ip_address = var.associate_public_ip_address

  tags = merge(
    local.tags_global,
    local.tags_elasticsearch,
    {
      Name = "${var.environment}-es-host"
    }
  )
  volume_tags = local.tags_elasticsearch

  root_block_device {
    delete_on_termination = var.delete_on_termination
    encrypted             = true
    volume_size           = var.es_host_volume_size
    volume_type           = var.es_host_volume_type
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = file("scripts/elasticinstall.sh")

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
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }


  ingress {
    description = "Kibana HTTP API"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    locals, tags_global,
    {
      Name = "${var.environment}-es-kibana-sg"
    }
  )
}