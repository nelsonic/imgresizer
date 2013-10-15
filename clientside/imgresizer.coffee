# example url: http://localhost:1337/resize?width=400&url=http://www.wollemipine.co.uk/acatalog/Wallpaper_CollectorsEdition800x600.jpg

getUrlParameters = () ->
	params = {}
	urlParams = {}
	console.log 'href: '+location.href
	query = location.href.split('?')
	console.log 'Query length: ' +query.length
	if query.length > 1 && query[1] != 'undefined'
		urlParams = query[1].split('&')
	if urlParams.length > 0
		for p in urlParams
			parts = p.split('=')
			key = parts[0]
			value = parts[1]
			params[key] = value
	return params

displayError = (msg) ->
		errMsg = document.createElement('h1')
		errMsg.innerHTML = msg
		errMsg.style.color = 'red'
		errMsg.style.fontFamily = 'sans-serif'
		document.body.appendChild(errMsg)

displayScaledImage = (urlParams) ->
	oi = oi || {} 	# Original Image info
	img = new Image()
	fail = "http://i.imgur.com/gvAz9At.jpg" # fail image
	if urlParams.url != 'undefined' && typeof urlParams.url != 'undefined'
		img.src = urlParams.url # imgsrc # 
	else 
		# displayError('No url parameter supplied! :-( <br />')
		img.src = fail

	# check we have a valid image url
	# display error message if image fails to load:
	img.onerror = () ->
		console.log 'Image Load Error!! :-('
		# displayError('Image Failed to Load! :-( <br />' +img.src)
		# img.src = fail

	# if the image sucessfully loads we apply the desired width/height:
	img.onload = (ir) ->
		oi.width = this.width
		oi.height = this.height
		oi.aspectRatio = Math.floor((this.width / this.height) * 100)/100
		console.log "Original Image Width: #{oi.width}"
		console.log "Original Height: #{oi.height}"
		console.log "Original Aspect Ratio: #{oi.aspectRatio}"

		# check a valid width was supplied
		if urlParams.width != 'undefined' && urlParams.width > 0
			img.width = parseInt(urlParams.width)

		# check a valid height was supplied
		else if urlParams.height != 'undefined' && urlParams.height > 0
			img.height = parseInt(urlParams.height)

		# check aspect ratio in cases where width and height specified
		# if urlParams.width && urlParams.height
		# 	if Math.floor((urlParams.width / urlParams.height)*100)/100 != oi.aspectRatio
		#		console.log 'Aspect Ratio FAIL! Use only width.'



		document.body.appendChild(img)

urlParams = getUrlParameters()

if (typeof urlParams.url != "undefined" && urlParams.url != undefined)
	document.getElementById('imgurl').value = urlParams.url
	console.log "URL:"+urlParams.url

console.log 'url: '+urlParams.url
console.log 'w: '+urlParams.width
console.log 'h: '+urlParams.height
window.onload = () -> displayScaledImage(urlParams)

# work around to have a submit button outside the main form element:
submit2 = document.getElementById('uploadbtn2')
submit2.addEventListener('click', () ->
	document.getElementById('uploadbtn').click() # trigger original button
, false);


console.log 'imgresizer finished'