const {PubSub}   = require('@google-cloud/pubsub')

exports.healthz = (req, res) => {
  res.status(200).send("hello")
}

exports.process = async(data, context) => {
  const pubSubMessage = data;
  const payload = JSON.parse(Buffer.from(pubSubMessage.data, 'base64').toString())
  console.log(`Payload: ${JSON.stringify(payload)}`)
}
