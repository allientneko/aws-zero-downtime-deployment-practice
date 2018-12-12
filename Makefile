include .env

clean:
		@rm -rf deployments/dist
		@mkdir -p deployments/dist

build: clean
		GOOS=linux go build -o deployments/dist/handler/getHandler aws/event/apigateway/getHandler.go aws/event/apigateway/dynamodb.go
		GOOS=linux go build -o deployments/dist/handler/putHandler aws/event/apigateway/putHandler.go aws/event/apigateway/dynamodb.go


run:
		aws-sam-local local start-api

install:
		go get github.com/aws/aws-lambda-go/events
		go get github.com/aws/aws-lambda-go/lambda
		go get github.com/stretchr/testify/assert

install-dev:
		go get github.com/awslabs/aws-sam-local

install-mod:
		go mod download

test:
		go test ./... --cover

configure:
		aws s3api create-bucket \
			--bucket $(AWS_BUCKET_NAME) \
			--region $(AWS_REGION) \
			--create-bucket-configuration LocationConstraint=$(AWS_REGION)

package: build
		@aws cloudformation package \
			--template-file deployments/serverless-template.yaml \
			--s3-bucket $(AWS_BUCKET_NAME) \
			--region $(AWS_REGION) \
			--output-template-file package.yml

deploy:
		@aws cloudformation deploy \
			--template-file package.yml \
			--region $(AWS_REGION) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_STACK_NAME)

describe:
		@aws cloudformation describe-stacks \
			--region $(AWS_REGION) \
			--stack-name $(AWS_STACK_NAME) \

outputs:
		@make describe | jq -r '.Stacks[0].Outputs'

url:
		@make describe | jq -r ".Stacks[0].Outputs[0].OutputValue" -j
