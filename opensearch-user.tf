resource "aws_iam_role" "opensearch_dashboard" {
  name = "opensearch_dashboard"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})

  tags = {
    tag-key = "openseachdashboarduser"
  }
}
