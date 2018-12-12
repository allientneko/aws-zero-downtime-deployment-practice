package main

import (
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

// person has field name as key
type person struct {
	Name        string    `json:"name"`
	DateOfBirth time.Time `json:"dateOfBirth"`
}

// Put extracts the person JSON and writes it to DynamoDB
func Put(name string, birthday time.Time) (*person, error) {
	// Create the dynamo client object
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	// Marshall the request body
	thisPerson := &person{Name: name, DateOfBirth: birthday}

	// Marshall a person into a Map DynamoDB can deal with
	av, err := dynamodbattribute.MarshalMap(*thisPerson)
	if err != nil {
		fmt.Println("Got error marshalling map:")
		fmt.Println(err.Error())
		return thisPerson, err
	}

	// Create person in table and return
	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(os.Getenv("TABLE_NAME")),
	}
	_, err = svc.PutItem(input)
	return thisPerson, err

}

func Get(name string) (*person, error) {
	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)
	queryResult := new(person)

	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(os.Getenv("TABLE_NAME")),
		Key: map[string]*dynamodb.AttributeValue{
			"name": {
				S: aws.String(name),
			},
		},
	})

	if err != nil {
		return nil, err
	}

	err = dynamodbattribute.UnmarshalMap(result.Item, queryResult)
	if err != nil {
		return nil, err
	}

	return queryResult, nil
}
