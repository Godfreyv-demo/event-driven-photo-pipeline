resource "aws_lambda_layer_version" "pillow" {
  layer_name          = "${local.name_prefix}-pillow"
  filename            = "${path.module}/../../layers/pillow/pillow_layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/../../layers/pillow/pillow_layer.zip")
  compatible_runtimes = ["python3.11"]
}