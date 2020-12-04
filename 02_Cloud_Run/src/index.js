const express = require("express")

var app = express()

app.get("/", (req, rsp) => {
	rsp.send("Hello world").status(200)
})

app.listen(8080, () => console.log("Listening on port 8080"))
