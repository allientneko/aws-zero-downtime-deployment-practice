include .env

clean:
		@rm -rf deployments/serverless/dist
		@mkdir -p deployments/serverless/dist

build: clean
		GOOS=linux go build -o deployments/serverless/dist/handler/getHandler aws/event/apigateway/getHandler.go aws/event/apigateway/dynamodb.go
		GOOS=linux go build -o deployments/serverless/dist/handler/putHandler aws/event/apigateway/putHandler.go aws/event/apigateway/dynamodb.go
		GOOS=linux go build -o deployments/serverless/dist/handler/healthCheck aws/event/apigateway/healthCheck.go

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
			--bucket $(AWS_REGION_1)-$(AWS_BUCKET_NAME) \
			--region $(AWS_REGION_1) \
			--create-bucket-configuration LocationConstraint=$(AWS_REGION_1)
		aws s3api create-bucket \
			--bucket $(AWS_REGION_2)-$(AWS_BUCKET_NAME) \
			--region $(AWS_REGION_2) \
			--create-bucket-configuration LocationConstraint=$(AWS_REGION_2)
dynamodb:
		aws cloudformation deploy \
			--template-file deployments/dynamodb.yaml \
			--region $(AWS_REGION_1) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_DATABASE_STACK_NAME) \
			--parameter-overrides DataTable=$(AWS_DATATABLE_NAME)
		aws cloudformation deploy \
			--template-file deployments/dynamodb.yaml \
			--region $(AWS_REGION_2) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_DATABASE_STACK_NAME) \
			--parameter-overrides DataTable=$(AWS_DATATABLE_NAME)
		aws dynamodb create-global-table \
			--global-table-name $(AWS_DATATABLE_NAME) \
			--replication-group RegionName=$(AWS_REGION_1) RegionName=$(AWS_REGION_2) \
			--region $(AWS_REGION_1)

package: build
		@aws cloudformation package \
			--template-file deployments/serverless/serverless-template.yaml \
			--s3-bucket $(AWS_REGION_1)-$(AWS_BUCKET_NAME) \
			--region $(AWS_REGION_1) \
			--output-template-file $(AWS_REGION_1)_serverless_package.yml
		@aws cloudformation package \
			--template-file deployments/serverless/serverless-template.yaml \
			--s3-bucket $(AWS_REGION_2)-$(AWS_BUCKET_NAME) \
			--region $(AWS_REGION_2) \
			--output-template-file $(AWS_REGION_2)_serverless_package.yml

deploy:
		@aws cloudformation deploy \
			--template-file $(AWS_REGION_1)_serverless_package.yml \
			--region $(AWS_REGION_1) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_LAMBDA_STACK_NAME) \
			--parameter-overrides DataTable=$(AWS_DATATABLE_NAME)
		@aws cloudformation deploy \
			--template-file $(AWS_REGION_2)_serverless_package.yml \
			--region $(AWS_REGION_2) \
			--capabilities CAPABILITY_IAM \
			--stack-name $(AWS_LAMBDA_STACK_NAME) \
			--parameter-overrides DataTable=$(AWS_DATATABLE_NAME)

url:
		@aws cloudformation describe-stacks \
			--region $(AWS_REGION_1) \
			--stack-name $(AWS_LAMBDA_STACK_NAME) \
			| jq -r ".Stacks[0].Outputs[0].OutputValue" -j
		@echo "\n"
		@aws cloudformation describe-stacks \
			--region $(AWS_REGION_2) \
			--stack-name $(AWS_LAMBDA_STACK_NAME) \
			| jq -r ".Stacks[0].Outputs[0].OutputValue" -j

dns:
		@aws cloudformation deploy \
			--template-file deployments/serverless/cross-region-dns.yaml \
			--region $(AWS_REGION_1) \
			--stack-name $(AWS_LAMBDA_STACK_NAME)_DNS \
			--parameter-overrides Region1=$(AWS_REGION_1) Region2=$(AWS_REGION_2) HostedZoneId=$(AWS_HOSTED_ZONE_ID) MultiregionEndpoint=$(AWS_CROSSREGION_DOMAIN) Region1Endpoint=$(AWS_REGION1_ENDPOINT) Region2Endpoint=$(AWS_REGION2_ENDPOINT) Region1HealthEndpoint=$(AWS_REGION1_HEALTHCHECK_ENDPOINT) Region2HealthEndpoint=$(AWS_REGION2_HEALTHCHECK_ENDPOINT)