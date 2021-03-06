const AWS = require("aws-sdk");
AWS.config.update({ region: process.env.AWS_REGION });

const ddb = new AWS.DynamoDB({ apiVersion: "2012-10-08" });
const ddbdc = new AWS.DynamoDB.DocumentClient({ apiVersion: "2012-08-10" });

const { TABLE_NAME } = process.env;

exports.connect = function(event, context, callback) {
  var putParams = {
    TableName: process.env.TABLE_NAME,
    Item: {
      connectionId: { S: event.requestContext.connectionId }
    }
  };

  ddb.putItem(putParams, function(err) {
    callback(null, {
      statusCode: err ? 500 : 200,
      body: err ? "Failed to connect: " + JSON.stringify(err) : "Connected."
    });
  });
};

exports.disconnect = function(event, context, callback) {
  var deleteParams = {
    TableName: process.env.TABLE_NAME,
    Key: {
      connectionId: { S: event.requestContext.connectionId }
    }
  };

  ddb.deleteItem(deleteParams, function(err) {
    callback(null, {
      statusCode: err ? 500 : 200,
      body: err
        ? "Failed to disconnect: " + JSON.stringify(err)
        : "Disconnected."
    });
  });
};

exports.message = async (event, context) => {
  let connectionData;

  try {
    connectionData = await ddbdc
      .scan({ TableName: TABLE_NAME, ProjectionExpression: "connectionId" })
      .promise();
  } catch (e) {
    return { statusCode: 500, body: e.stack };
  }

  const apigwManagementApi = new AWS.ApiGatewayManagementApi({
    apiVersion: "2018-11-29",
    endpoint: event.requestContext.domainName + "/" + event.requestContext.stage
  });

  const postData = JSON.parse(event.body).data;

  const postCalls = connectionData.Items.map(async ({ connectionId }) => {
    try {
      await apigwManagementApi
        .postToConnection({ ConnectionId: connectionId, Data: postData })
        .promise();
    } catch (e) {
      if (e.statusCode === 410) {
        console.log(`Found stale connection, deleting ${connectionId}`);
        await ddbdc
          .delete({ TableName: TABLE_NAME, Key: { connectionId } })
          .promise();
      } else {
        throw e;
      }
    }
  });

  try {
    await Promise.all(postCalls);
  } catch (e) {
    return { statusCode: 500, body: e.stack };
  }

  return { statusCode: 200, body: "Data sent." };
};
