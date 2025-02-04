module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "app_upload" {
  bucket = var.bucket_name
  key = "app.py"
  source = "./app/app.py"
  depends_on = [ module.s3_bucket ]
}

resource "aws_s3_bucket_object" "templates_upload" {
  bucket = var.bucket_name
  key = "templates/index.html"
  source = "./templates/index.html"
  depends_on = [ module.s3_bucket ]
}