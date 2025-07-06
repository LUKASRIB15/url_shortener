data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
  
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "create_logs_cloudwatch" {
  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*:*"]
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

data "aws_s3_bucket" "url_shortener_bucket" {
  bucket = "lukasrib15-url-shortener-storage"
}

data "aws_iam_policy_document" "s3_bucket_access" {
  statement {
    sid       = "AllowS3PutGetObject"
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${data.aws_s3_bucket.url_shortener_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_bucket_access_policy" {
  name        = "url-shortener-s3-access-policy"
  description = "Permite que a função Lambda acesse o bucket de armazenamento do encurtador de URL."
  policy      = data.aws_iam_policy_document.s3_bucket_access.json
}

resource "aws_iam_role" "url_shortener_iam_role" {
  name = "url-shortener-iam-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "create_logs_cloudwatch" {
  name   = "create-cw-logs-policy"
  policy = data.aws_iam_policy_document.create_logs_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "url_shortener_cloudwatch" {
  policy_arn = aws_iam_policy.create_logs_cloudwatch.arn
  role = aws_iam_role.url_shortener_iam_role.name
}

resource "aws_iam_role_policy_attachment" "url_shortener_s3_access" {
  policy_arn = aws_iam_policy.s3_bucket_access_policy.arn
  role       = aws_iam_role.url_shortener_iam_role.name
}