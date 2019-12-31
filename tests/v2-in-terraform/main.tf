provider "aws" {
  region = "us-east-2"
}

resource "aws_dynamodb_table" "db" {
  name           = "simplechat_connections"
  billing_mode   = "PROVISIONED"
  hash_key       = "connectionId"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "connectionId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_iam_role" "iam_for_disconnect" {
  name = "serverlessrepo-simple-web-OnDisconnectFunctionRole-104KVNTAZXXSG"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_lambda_function" "disconnect" {
  function_name = "serverlessrepo-simple-websock-OnDisconnectFunction-581AMGL1N2K6"
  role          = aws_iam_role.iam_for_disconnect.arn
  handler       = "app.handler"

  filename         = "ondisconnect.zip"
  source_code_hash = filebase64sha256("ondisconnect.zip")

  runtime     = "nodejs10.x"
  memory_size = 256
  layers      = []

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.db.id
    }
  }
  tags = {
    "lambda:createdBy"               = "SAM"
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_lambda_permission" "allow_api_disconnect" {
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.websocket.execution_arn}/*/*/*"
}

resource "aws_iam_role" "iam_for_connect" {
  name = "serverlessrepo-simple-websoc-OnConnectFunctionRole-89HES1AB6DEF"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_lambda_function" "connect" {
  function_name = "serverlessrepo-simple-websockets-OnConnectFunction-12HSTX93Y55AZ"
  role          = aws_iam_role.iam_for_connect.arn
  handler       = "app.handler"

  filename         = "onconnect.zip"
  source_code_hash = filebase64sha256("onconnect.zip")

  runtime     = "nodejs10.x"
  memory_size = 256
  layers      = []

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.db.id
    }
  }
  tags = {
    "lambda:createdBy"               = "SAM"
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_lambda_permission" "allow_api_connect" {
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.websocket.execution_arn}/*/*/*"
}

resource "aws_iam_role" "iam_for_message" {
  name = "serverlessrepo-simple-webs-SendMessageFunctionRole-17TOUMAQFJA5K"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_lambda_function" "message" {
  function_name = "serverlessrepo-simple-websocke-SendMessageFunction-10FYI4YEVKIZD"
  role          = aws_iam_role.iam_for_message.arn
  handler       = "app.handler"

  filename         = "sendmessage.zip"
  source_code_hash = filebase64sha256("sendmessage.zip")

  runtime     = "nodejs10.x"
  memory_size = 256
  layers      = []

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.db.id
    }
  }
  tags = {
    "lambda:createdBy"               = "SAM"
    "serverlessrepo:applicationId"   = "arn:aws:serverlessrepo:us-east-1:729047367331:applications/simple-websockets-chat-app"
    "serverlessrepo:semanticVersion" = "1.0.1"
  }
}

resource "aws_lambda_permission" "allow_api_message" {
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.websocket.execution_arn}/*/*/*"
}

# resource "aws_api_gateway_integration" "api_method_integration" {
#   rest_api_id             = module.websocket.id
#   resource_id             = aws_api_gateway_resource.MyDemoResource.id
#   http_method             = "GET"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.message.invoke_arn
#   integration_http_method = "POST"
# }

output "m" { value = module.websocket.root_resource_id }
# resource "aws_api_gateway_resource" "MyDemoResource" {
#   rest_api_id = "${module.websocket.id}"
#   parent_id   = "${module.websocket.root_resource_id}"
#   path_part   = "mydemoresource"
# }

# resource "aws_api_gateway_method" "MyDemoMethod" {
#   rest_api_id   = "${module.websocket.id}"
#   resource_id   = "${aws_api_gateway_resource.MyDemoResource.id}"
#   http_method   = "GET"
#   authorization = "NONE"
# }

module "websocket" {
  source      = "./modules/apigateway-websocket"
  name        = "MyDemoAPISample"
  description = "A simple example of things"
  region      = "us-east-2"
}

output "sample" {
  value = module.websocket.id
}
