data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  user_data_replace_on_change = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  depends_on = [
    aws_iam_role_policy_attachment.ec2_attach, # Attach policy before trying to pull the image from ECR
    aws_db_instance.postgres_db                # Create the DB before fetching the password from Secrets Manager
  ]

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y docker
    systemctl enable --now docker
    
    usermod -aG docker ec2-user

    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.ecr_repo.repository_url}

    docker pull ${aws_ecr_repository.ecr_repo.repository_url}:latest
    docker run -d \
      --name uptime-checker \
      --restart unless-stopped \
      -e AWS_REGION="us-east-1" \
      -e S3_BUCKET="${aws_s3_bucket.url_storage_bucket.bucket}" \
      -e DB_HOST="${aws_db_instance.postgres_db.address}" \
      -e DB_PORT="5432" \
      -e DB_NAME="${aws_db_instance.postgres_db.db_name}" \
      -e DB_SECRET_ARN="${aws_db_instance.postgres_db.master_user_secret[0].secret_arn}" \
      -e SNS_TOPIC_ARN="${aws_sns_topic.daily_report.arn}" \
      ${aws_ecr_repository.ecr_repo.repository_url}:latest
  EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}