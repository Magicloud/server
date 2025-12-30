terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.12.0"
    }
  }
}

provider "minio" {
  minio_server   = "minio.magicloud.lan:443"
  minio_user     = "minio"
  minio_password = "minio123"
  minio_ssl      = true
}

resource "minio_iam_user" "sccache" {
   name = "sccache"
   secret = "sccache123"
}

resource "minio_s3_bucket" "sccache" {
    bucket = "sccache"
}

resource "minio_iam_policy" "read-write-sccache" {
  name = "read-write-sccache"
  policy = data.minio_iam_policy_document.sccache.json
}

resource "minio_iam_user_policy_attachment" "sccache" {
  user_name   = minio_iam_user.sccache.id
  policy_name = minio_iam_policy.read-write-sccache.id
}

data "minio_iam_policy_document" "sccache" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::sccache",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::sccache/*",
    ]
  }
}