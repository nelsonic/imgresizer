port = process.env.PORT || 5000
http = require 'http' 
fs = require 'fs'
html = fs.readFileSync './resize.html', 'utf8'

# The Simplest Possible Web Server >> Performance! :-)
server = http.createServer( (req, res) ->
	res.writeHead(200, {"Content-Type": "text/html"})
	res.end(html);
).listen(port)

console.log "Image Resize Server Running on localhost:"+port

# PhantomJS Magic?


