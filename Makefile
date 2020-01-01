.DEFAULT_GOAL:=help

STACK_NAME=websocket-chat-app
S3_BUCKET=jrbeverly-serverless-chat-app
DIR_OUT=.out
TEMPLATE_FILE=$(DIR_OUT)/cloudformation.json
OUTPUT_TEMPLATE_FILE=$(DIR_OUT)/packaged.yaml

.PHONY: help
help: ## This help text.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Deploy

.PHONY: pack
pack: ## Package the yaml files as a single 
	@mkdir -p "$(DIR_OUT)"
	@cfpack build

.PHONY: package
package: pack ## Package an AWS SAM application.
	@mkdir -p "$(DIR_OUT)"
	@sam package \
		--template-file "$(TEMPLATE_FILE)" \
		--output-template-file "$(OUTPUT_TEMPLATE_FILE)" \
		--s3-bucket $(S3_BUCKET) \
		--region $(AWS_REGION)

.PHONY: deploy
deploy: ## Deploy an AWS SAM application.
	@sam deploy \
		--template-file "$(OUTPUT_TEMPLATE_FILE)" \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--region $(AWS_REGION)

.PHONY: publish
publish: package ## Re-package and deploy an AWS SAM application.
	@sam deploy \
		--template-file "$(OUTPUT_TEMPLATE_FILE)" \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--region $(AWS_REGION) || exit 0

##@ Cloudformation

.PHONY: describe
describe: ## Describes the deployed cloudformation stack.
	@aws cloudformation describe-stacks \
    	--stack-name $(STACK_NAME) \
		--region $(AWS_REGION)

.PHONY: outputs
outputs: ## Describes the outputs of the deployed cloudformation stack.
	@aws cloudformation describe-stacks \
    	--stack-name $(STACK_NAME) \
		--region $(AWS_REGION) \
		--query 'Stacks[].Outputs'

##@ Docker

.PHONY: docker
docker: ## Runs AWS SAM in docker.
	@docker build -t sam -f .github/environments/aws-sam/Dockerfile .github/environments/aws-sam/.
	@docker run \
		--rm -it \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
		-e AWS_REGION=${AWS_REGION} \
		-e SAM_CLI_TELEMETRY=0 \
		-v "/${PWD}":/cardboardci \
		sam bash

##@ Tests

.PHONY: chat
chat: ## Login to one of the chat sessions.
	@echo wscat -c '$$WSCAT_URI'
	@echo '{"message":"sendmessage", "data":"hello world"}'
	@cd docker/ && docker-compose up -d && docker exec -it docker_chat_1 bash

.PHONY: chat-stop
stop: ## Halt the existing chat services.
	@cd docker/ && docker-compose stop && docker-compose rm -fv

.PHONY: logs
logs: ## Dump the logs from the docker image.
	@echo Chat 1:
	@docker logs tests_chat_1