resource "aws_security_group" "docdb" {
  name   = "${var.db_name}-docdb"
  vpc_id = var.vpc_id
  ingress {
    to_port     = 27017
    from_port   = 27017
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }
  tags = {
    Environment = "dev"
  }
}

resource "aws_docdb_subnet_group" "service" {
  name       = var.db_name
  #subnet_ids = [ var.subnet_id ]
  subnet_ids = split(",",var.subnet_ids)
}

resource "aws_docdb_cluster_instance" "service" {
  count              = var.num_count
  identifier         = "${var.db_name}-${count.index}"
  cluster_identifier = aws_docdb_cluster.service.id
  instance_class     = var.instance_class
  ca_cert_identifier = var.ca_cert_identifier
}

resource "aws_docdb_cluster" "service" {
  db_subnet_group_name            = aws_docdb_subnet_group.service.name
  cluster_identifier_prefix       = var.db_name
  engine                          = var.engine
  engine_version                  = var.engine_version
  master_username                 = var.master_username
  master_password                 = var.master_password
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.service.name
  storage_encrypted               = var.storage_encrypted
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately
  vpc_security_group_ids          = [ aws_security_group.docdb.id ]

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
}

resource "aws_docdb_cluster_parameter_group" "service" {

  family  = var.family
  name    = var.db_name

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

