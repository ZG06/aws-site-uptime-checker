#-------EC2-------

# Allow EC2 to assume the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create an EC2 role
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Least-Privilege permissions policy
data "aws_iam_policy_document" "ec2_permissions" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
    effect = "Allow"
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [aws_ecr_repository.ecr_repo.arn]
    effect = "Allow"
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.url_storage_bucket.arn]
    effect = "Allow"
  }
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.url_storage_bucket.arn}/*"]
    effect = "Allow"
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [aws_db_instance.postgres_db.master_user_secret[0].secret_arn]
    effect = "Allow"
  }
  # TODO: create SNS permissions
}

# EC2 instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Convert the document into a JSON policy
resource "aws_iam_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  description = "Least privilege execution policy for ${var.project_name} EC2 instance"
  policy = data.aws_iam_policy_document.ec2_permissions.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Attach baseline permissions needed for AWS SSM to the role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#--------