package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestPut(t *testing.T) {
	res, err := PutHandler(events.APIGatewayProxyRequest{})

	require.NoError(t, err)
	assert.Equal(t, 200, res.StatusCode)
}
