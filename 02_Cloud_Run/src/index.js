const args = require('minimist')(process.argv.slice(2))
const express = require("express")

console.log(args._[0])
var app = express()

app.get("/", (req, rsp) => {
	rsp.send(`Hello ${args._[0]}`).status(200)
})

app.listen(8080, () => console.log("Listening on port 8080"))
