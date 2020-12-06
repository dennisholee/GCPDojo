const args = require('minimist')(process.argv.slice(2))
const express = require("express")
const {PubSub} = require('@google-cloud/pubsub')

console.log(args._[0])
var app = express()
const pubsub = new PubSub()


app.get("/", (req, rsp) => {
  rsp.send("OK").status(200)
})

app.post("/", async(req, rsp) => {
	if (!req.body.topic || !req.body.message) {
    res
      .status(400)
      .send(
        'Missing parameter(s); include "topic" and "message" properties in your request.'
      );
    return;
  }

  console.log(`Publishing message to topic ${req.body.topic}`);

  // References an existing topic
  const topic = pubsub.topic(req.body.topic);

  const messageObject = {
    data: {
      message: req.body.message,
    },
  };
  const messageBuffer = Buffer.from(JSON.stringify(messageObject), 'utf8');

  // Publishes a message
  try {
    await topic.publish(messageBuffer);
    res.status(200).send('Message published.');
  } catch (err) {
    console.error(err);
    res.status(500).send(err);
    return Promise.reject(err);
  }
	rsp.send(`Hello ${args._[0]}`).status(200)
})

app.listen(8080, () => console.log("Listening on port 8080"))
