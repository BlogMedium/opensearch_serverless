data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_opensearchserverless_access_policy" "demo-access-policy" {
  name = "demo-access-policy"
  type = "data"
  policy = jsonencode([
    {
      "Rules" : [
        {
          "ResourceType" : "index",
          "Resource" : [
            "index/demo-collection/*"
          ],
          "Permission" : [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/demo-collection"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      "Principal" = [
        "arn:aws:iam::${local.account_id}:role/opensearch_role",
        "arn:aws:iam::${local.account_id}:user/opensearch",
         "arn:aws:iam::${local.account_id}:role/opensearch_dashboard"

      ]
    }
  ])
}


resource "aws_opensearchserverless_security_policy" "demo-security-policy" {
  name = "demo-security-policy"
  type = "encryption"
  policy = jsonencode({
    "Rules" = [
      {
        "Resource" = [
          "collection/*"
        ],
        "ResourceType" = "collection"
      }
    ],
    "AWSOwnedKey" = true
