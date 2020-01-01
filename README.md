# AWS Chat App

SAM Application for a simple chat application based on API Gateways new WebSocket API feature. This was originally developed as an experiment to see how viable running a chat-bot in a fully serverless environment, as opposed to just running on a container in ECS.

This repository is based on [Announcing WebSocket APIs in Amazon API Gateway](https://aws.amazon.com/blogs/compute/announcing-websocket-apis-in-amazon-api-gateway/), with the cloudformation and lambdas from [simple-websockets-chat-app](https://github.com/aws-samples/simple-websockets-chat-app).

## Usage

A build-harness created with `make` is available for the repository. This harness simplifies the command necessary to build and deploy the project. You can see the available targets by running `make help`:

```bash
Usage: make <target>
  help        This help text.

Deploy
  pack        Package the yaml files as a single
  package     Package an AWS SAM application.
  deploy      Deploy an AWS SAM application.
  publish     Re-package and deploy an AWS SAM application.

Cloudformation
  describe    Describes the deployed cloudformation stack.
  outputs     Describes the outputs of the deployed cloudformation stack.

Docker
  docker      Runs AWS SAM in docker.

Tests
  chat        Login to one of the chat sessions.
  stop        Halt the existing chat services.
  logs        Dump the logs from the docker image.
```

The build-harness does a bit more in this case, as I experimented with a couple different tools while working on this. Notably:

- `AWS SAM` for packaging and deploying the code
- `cfpack.js` for bundling multiple cloudformation templates into a single one
- `docker-compose` for testing the service with `wscat`
- `awscli` for describing and working with the deployed cloudformation stack

### Deploy

Using docker, you can build and deploy the sample using the following steps:

```bash
make docker
make pack
make package
make deploy
```

You can get the URL for the websocket by calling `make outputs`. This can then be provided to the docker-compose template in docker/.

```bash
make outputs

echo "WSCAT_URI=wss://<id>.execute-api.<region>.amazonaws.com/<env>" > docker/.env

make chat
# wscat -c $WSCAT_URI
# {"message":"sendmessage", "data":"hello world"}
```

## Notes

I built this while I was looking into serverless chat-ops. At the time I was tinkering with ideas about chat-ops like services that could be used to manage key rotation in external services. This lead to some experiments with Hubot and AWS Lambda. I thought this example would offer sufficient complexity for tinkering with the idea of a lambda-based application for working with different services. The ideas were as follows:

1) If each service is its own lambda, permissions to service tokens (GitHub / CircleCI / TravisCI / Jenkins) can be locked down at the route level
2) Each service token could have its own secret store, allowing granular access permissions
3) Rotations would occur on set intervals, which meant the service didn't need to remain running at all times
4) Trigger actions (revocations / deletes / freezes) could be trigger by API Routes
5) Authentication could _potentially_ leverage existing AWS services (useful for a secure service)

### Terraform

I had originally intended to write this in terraform, however at time of development (& writing), Terraform does not have support for the new version of API Gateway (V2). I have included CloudFormation in Terraform prototype in the directory [tests/] for future reference. Rather than trying to get this working, I looked for ways to setup a terraform-like experience in cloudformation.

### CfPack

I used `cfpack.js` to split the cloudformation template into smaller templates. Although this added another dependency (& build step), I found it a lot easier to work with multiple smaller templates as opposed to one big one. I did some early experiments with nested stacks, but personally found it like juggling.

> cfpack is a small CLI tool that can help you to deal with huge CloudFormation templates by splitting it into multiple smaller templates. Using this tool you can also build sharable drop-in templates that you can share across your projects.