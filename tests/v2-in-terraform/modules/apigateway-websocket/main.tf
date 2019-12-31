data "aws_caller_identity" "current" {}

resource "aws_cloudformation_stack" "websocket_api" {
  name = "TerraformWebSocketWorkaround"

  template_body = <<EOF
Resources:
  WebSocketApi:
    Type: AWS::ApiGatewayV2::Api
    Properties:
      Name: ${var.name}
      Description: ${var.description}
      ProtocolType: WEBSOCKET
      RouteSelectionExpression: $request.body.message

Outputs:
  WebSocketApi:
    Value: !Ref WebSocketApi
EOF
}

locals {
  id = aws_cloudformation_stack.websocket_api.outputs["WebSocketApi"]
}
