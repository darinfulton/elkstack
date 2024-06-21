data "aws_availability_zones" "available" {}



resource "aws_vpc" "primary-vpc" {
  cidr_block = var.cidr_block

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.primary-vpc.id

  tags = local.tags
}

resource "aws_eip" "eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.eip.id

  tags = local.tags
}

resource "aws_subnet" "public" {
  count = length(var.availability_zone)

  vpc_id                  = aws_vpc.primary-vpc.id
  cidr_block              = var.public_subnet_cidr_block[var.availability_zone[count.index]]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[count.index]

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-${var.availability_zone[count.index]}-public"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "private" {
  count = length(var.availability_zone)

  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = var.private_subnet_cidr_block[var.availability_zone[count.index]]
  availability_zone = var.availability_zone[count.index]

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-${var.availability_zone[count.index]}-private"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.primary-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-private"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "public_sg" {
  name        = "${var.environment-name}-public-sg"
  description = "Public Subnet Security Group"
  vpc_id      = aws_vpc.primary-vpc.id
}

resource "aws_security_group_rule" "public_ingress" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_egress" {
  security_group_id = aws_security_group.public_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "private_sg" {
  name        = "${var.environment-name}-private-sg"
  description = "Private Subnet Security Group"
  vpc_id      = aws_vpc.primary-vpc.id
}

resource "aws_security_group_rule" "private_ingress" {
  security_group_id = aws_security_group.private_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "private_egress" {
  security_group_id = aws_security_group.private_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

#############################
# Application Load Balancer #
#############################

resource "aws_lb" "es_lb" {
  name               = "elasticsearch"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.es_lb_sg.id]
  subnets         = aws_subnet.public[*].id

  enable_deletion_protection = false

  timeouts {
    create = "30m"
    delete = "30m"
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-elasticsearch-lb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.es_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.es_tg.arn
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-elasticsearch-lb"
    }
  )
  depends_on = [aws_lb.es_lb]
}

/*
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.es_lb.arn
  port = "443"
  protocol = "HTTPS"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.es_tg.arn
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-elasticsearch-lb"
      }
  )
}
*/

resource "aws_lb_target_group" "es_tg" {
  name     = "es-target-group"
  port     = 5601
  protocol = "HTTP"
  vpc_id   = aws_vpc.primary-vpc.id

  health_check {
    enabled             = true
    path                = "/status"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}



resource "aws_lb_target_group_attachment" "es_tg_attch_http" {
  target_group_arn = aws_lb_target_group.es_tg.arn

  target_id = aws_instance.es_host.id
  port      = 5601
}



resource "aws_security_group" "es_lb_sg" {
  name        = "${var.environment-name}-es-lb"
  description = "Security Group for Elasticsearch Loadbalancer"
  vpc_id      = aws_vpc.primary-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ["70.171.0.72/32" , "10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["70.171.0.72/32", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["70.171.0.72/32", "10.0.0.0/16"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["70.171.0.72/32", "10.0.0.0/16"]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment-name}-${var.vpc-name}-elasticsearch-lb"
    }
  )
}


