package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"time"
)

func main() {
	lambda.Start(PutHandler)
}

type putRequest struct {
	DateOfBirth string `json:"dateOfBirth"`
}

func PutHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	name := req.PathParameters["name"]

	var reqBody putRequest
	err := json.Unmarshal([]byte(req.Body), &reqBody)

	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Bad Request", StatusCode: 400}, err
	}

	birthday, err := time.Parse("2006-01-02", reqBody.DateOfBirth)

	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Bad Request", StatusCode: 400}, err
	}

	_, err = Put(name, birthday)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Bad Request", StatusCode: 400}, err
	}

	return events.APIGatewayProxyResponse{Body: string(""), StatusCode: 204}, nil
}
