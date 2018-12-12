package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"time"
)

func main() {
	lambda.Start(GetHandler)
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
		return events.APIGatewayProxyResponse{Body: fmt.Sprintf("Hello, %s! Happy birthday!", name), StatusCode: 200}, nil
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

	return events.APIGatewayProxyResponse{Body: fmt.Sprintf("Hello, %s! Your birthday is in %d days", name, days), StatusCode: 200}, nil
}
