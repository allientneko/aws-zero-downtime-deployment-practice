package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"time"
)

func main() {
	lambda.Start(GetHandler)
}

type respond struct {
	Message string `json:"message"`
}

func GetHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	nextYear := true
	birthdayString := ""
	name := req.PathParameters["name"]
	queryResult, err := Get(name)

	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Bad Request", StatusCode: 400}, err
	}

	currentDate := time.Now()
	birthdayMonth := queryResult.DateOfBirth.Month()
	birthdayDay := queryResult.DateOfBirth.Day()

	if currentDate.Month() == birthdayMonth && currentDate.Day() == birthdayDay {
		body, err := json.Marshal(respond{ Message: fmt.Sprintf("Hello, %s! Happy birthday!", name) })
		if err != nil {
			return events.APIGatewayProxyResponse{StatusCode: 500}, err
		}
		return events.APIGatewayProxyResponse{Body: string(body), StatusCode: 200, Headers: map[string]string{"Content-Type": "application/json"} }, nil
	}

	if currentDate.Month() < birthdayMonth {
		nextYear = false
	} else if currentDate.Month() == birthdayMonth {
		if currentDate.Day() < birthdayDay {
			nextYear = false
		}
	}

	if nextYear {
		birthdayString = fmt.Sprintf("%d-%d-%d", currentDate.Year()+1, birthdayMonth, birthdayDay)
	} else {
		birthdayString = fmt.Sprintf("%d-%d-%d", currentDate.Year(), birthdayMonth, birthdayDay)
	}

	birthday, err := time.Parse("2006-1-2", birthdayString)

	days := int(time.Until(birthday).Hours() / 24)

	body, err := json.Marshal(respond{ Message: fmt.Sprintf("Hello, %s! Your birthday is in %d days", name, days) })
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	return events.APIGatewayProxyResponse{Body: string(body), StatusCode: 200, Headers: map[string]string{"Content-Type": "application/json"}}, nil
}
