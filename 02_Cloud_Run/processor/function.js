const {PubSub}   = require('@google-cloud/pubsub')
const {Firestore} = require('@google-cloud/firestore')

const firestore = new Firestore()


exports.healthz = (req, res) => {
  res.status(200).send("hello")
}

exports.process = async(data, context) => {
  const pubSubMessage = data;
  const payload = JSON.parse(Buffer.from(pubSubMessage.data, 'base64').toString())

  let collectionRef = firestore.collection('pokemon')
  let documentRef  = await collectionRef.add({'foo','bar'})

  console.log(`Added document at ${documentRef.path})`);

  console.log(`Payload: ${JSON.stringify(payload)}`)
}
