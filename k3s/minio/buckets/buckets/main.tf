terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.12.0"
    }
  }
}

variable "username" {
  type = string
}

variable "buckets" {
  type = set(string)
}

variable "k8s_secret_namespace" {
  type = string
}

resource "random_password" "password" {
  length = 12
  special = false
}

resource "kubernetes_secret_v1" "bucket" {
  metadata {
    name = "minio-user-${var.username}"
    namespace = var.k8s_secret_namespace
  }
  data = {
    username = var.username
    password = random_password.password.result
  }
  type = "kubernetes.io/basic-auth"
}

resource "minio_iam_user" "bucket" {
  name = var.username
  secret = random_password.password.result
}

resource "minio_s3_bucket" "bucket" {
  for_each = var.buckets
  bucket = each.key
}

resource "minio_iam_policy" "bucket" {
  name = "read-write-${var.username}"
  policy = data.minio_iam_policy_document.bucket.json
}

resource "minio_iam_user_policy_attachment" "bucket" {
  user_name   = minio_iam_user.bucket.id
  policy_name = minio_iam_policy.bucket.id
}

data "minio_iam_policy_document" "bucket" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [
      for s in var.buckets : "arn:aws:s3:::${s}"
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
      for s in var.buckets : "arn:aws:s3:::${s}/*"
    ]
  }
}