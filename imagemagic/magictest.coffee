im = require 'imagemagick'
fs = require 'fs'
http = require 'http'
redis = require 'redis'
client = redis.createClient()

client.on("error", () ->
  console.log("REDIS FAIL")
)

allowedImageFormats = ['jpg','jpeg','gif','png']

getFilenameWithoutExtension = (filename,format) ->
  # strip any path data e.g. /mypics/sub/directory
  lastFowardSlash = filename.lastIndexOf('/')
  if lastFowardSlash != null && lastFowardSlash > 0
    filename = filename.substring(lastFowardSlash+1, filename.length)
  # remove image dimensions from filename
  filename = stripDimensionsFromSourceImageName(filename, format)
  # isolate the name of the file from the extension so we
  # can put the file dimensions in the resized filename
  lastOccurenceOfExtension = filename.lastIndexOf("."+format)
  # ensure we don't strip a file that includes the extension
  # in the filename e.g. myphoto.jpg.jpg (it happens! google it!)
  filenameWithoutExtension = filename.substring(0, lastOccurenceOfExtension)


getHeightFromWidthUsingAspectRatio = (oi, width, height) ->
  ri = {}
  # check if the resized image width is defined
  if typeof width != "undefined" && width != undefined && parseInt(width) > 0
    ri.width = parseInt(width)
    ri.height = Math.round(ri.width / oi.aspectRatio)
  else if typeof height != "undefined" && height != undefined && parseInt(height) > 0
    ri.height = parseInt(height)
    ri.width = Math.round(ri.height * oi.aspectRatio)
  else
    throw {name : "NoResizeWidthOrHeight", message : "No Resize Width Supplied!"}
  console.log "Ri W: #{ri.width}  /  H: #{ri.height}  =  A: #{oi.aspectRatio}"
  return ri

getImageFormatFromFilename = (filename) ->
  fileparts = filename.split('.')
  format    = fileparts[fileparts.length-1].toLowerCase()
  # confirm the file format is valid (otherwize halt processing)
  if format in allowedImageFormats
    return format
  else
    # console.log "#{format} is NOT a valid Image!"
    # consider using Winston here to avoid crashing the app
    throw {name : "BadFileFormat", message : "File format #{format} is invalid!"}
 
# Get Original Image Details (oi = original image)
getOriginalImageData = (filename, width, height, callback) ->
  im.identify(filename, (err, oi) ->
    if (err) 
      throw err
    # add the filename and format to the oi object
    # to simplify passing around the variables
    oi.filename = filename
    oi.format   = getImageFormatFromFilename(oi.filename)

    # we use aspect ratio to derive height from width or vice-versa
    oi.aspectRatio = (oi.width / oi.height)
    oi.filenameWithoutExtension = getFilenameWithoutExtension(filename,oi.format)
    ri = getHeightFromWidthUsingAspectRatio(oi,width, height)
    callback? oi,ri 
  )

# we don't want the sunset800x600.jpg to become sunset800x600400x300.jpg
# so we need to strip the 800x600 from the original filename
# and then call the re-sized image sunset400x300.jpg
# but not strip out the digits in andre3000.jpg or 2000ad.jpg
stripDimensionsFromSourceImageName = (filename, format) ->
  # this regular expression finds mypic3381_x_2468.jpg or mypic3381x2468.jpg
  # and even the obscure unicorns-28904999-1700-2339.png (where w=1700 and h=2339)
  # but misses our friends andre3000.jpg and 200ad.gif :-)
  # Its NOT perfect tho, and if I had time, I would like to write 
  # a few more test cases so we can avoid false positives
  # but since it was not in the spec I've left it for now...
  # in would prefer the file extensions to NOT be Hard Coded... 
  match = (/((\d+[x\-_]+\d+).(\bjpg\b|\bjpeg\b|\bpng\b|\bgif\b))/i).exec filename
  # console.log match
  if match != null && match.index > 0 
    nodimensions = filename.substring(0, match.index)
    # console.log "Substring 0,match.index #{nodimensions}"
    return filename = "#{nodimensions}.#{format}"
  else
    return filename


# parameter oi is an object of the original image
# parameter ri (resized image) contains width/height 
resizeImage = (oi, ri, existingData = {}) ->

  ri.path = __dirname+'/resized-images/'
  # resized image name
  ri.filename = "#{ri.path}#{oi.filenameWithoutExtension}-#{ri.width}x#{ri.height}.#{oi.format}"
  console.log ri.filename

  im.resize({
    srcPath: oi.filename,
    dstPath: ri.filename,
    width: ri.width
  }, (err, stdout, stderr) -> 
    if (err) 
      return console.error(err.stack || err)
    console.log "Time taken for resize: #{(new Date)-timeStarted} ms  - #{ri.filename}" 
    # save this to redis:
    saveResizeDataToRedis(oi, ri, existingData)

    im.identify(['-format', '%b', ri.filename], (err, r) ->
      if (err)
        throw err
      console.log ('\n')
      # console.log("identify('-format', '%b', #{ri.filename}) ->", r)
    )
  )

saveResizeDataToRedis = (oi, ri, existingData = {}) ->
    lastFowardSlash = oi.filename.lastIndexOf('/')
    # if lastFowardSlash != null && lastFowardSlash > 0
    originalFile = oi.filename.substring(lastFowardSlash+1, oi.filename.length)
    
    # originalFile = "#{oi.filenameWithoutExtension}.#{oi.format}"
    # width = ri.width
    resizeData = {
      aspectRatio : oi.aspectRatio
    }
    resizeData[ri.width] = {
      localFilename : ri.filename,
      created : new Date()
    }
    # if data already exists for this file we want to preserve it:
    if existingData != null && existingData.length > 0
      console.log "                            >>  attempt merge existingData"
      for obj in existingData
        resizeData[k] = v for k, v of obj
    # write data to Redis 
    client.set(originalFile, JSON.stringify(resizeData), redis.print)



findOrDownloadImageFile = (filename, width, height, callback) ->
  # console.log "Searching for: #{filename}"

  # first lets strip any path data e.g. /mypics/sub/directory
  lastFowardSlash = filename.lastIndexOf('/')
  # if lastFowardSlash != null && lastFowardSlash > 0
  originalFile = filename.substring(lastFowardSlash+1, filename.length)
  
  # try fetch from redis
  client.get(originalFile, (err, reply) ->
    if (err)
      console.log("File not in Redis: " + err);
    else
      data = JSON.parse(reply)
      if data != null
        console.log "- - - - - - - - - - - - - - Redis HIT for Original File: #{originalFile}"
        console.log data
        # lookup the dimensions in the redis reply:
        oi = {aspectRatio : data.aspectRatio}
        ri = getHeightFromWidthUsingAspectRatio(oi,width, height)
        console.log "ri.width = #{ri.width}"
        console.log "            typeof  data[ri.width] : #{typeof data[ri.width]}"
        # console.dir data[ri.width]
        if data[ri.width] != null && typeof data[ri.width] != "undefined" # && data[ri.width].length > 0
          console.log "data[ri.width] length : #{data[ri.width].length}"
          console.log data[ri.width]
          return data[ri.width]
        else
          console.log "                                                          Resize image"
        # else we need to create a new re-sized image
        # but send on the existing data so it can be preserved
          # add properties to oi to allow resizeImage to do its thing:
          oi.filename = filename
          oi.format = getImageFormatFromFilename(oi.filename)
          oi.filenameWithoutExtension = getFilenameWithoutExtension(filename,oi.format)
          resizeImage(oi,ri,data)

      # else
      #   return callback? localFilename
      # check if we already have the desired dimensions:

  )

  if filename.indexOf('http://') == -1
  # try and open the file on the local filesystem
    if fs.existsSync(filename)
      return callback? filename

  # if the file has http:// in the url we try and download it 
  # first lets strip any path data e.g. /mypics/sub/directory
  lastFowardSlash = filename.lastIndexOf('/')
  # if lastFowardSlash != null && lastFowardSlash > 0
  localFilename = filename.substring(lastFowardSlash+1, filename.length)
  path = __dirname+'/downloaded-images/'
  localFilename = path + localFilename
  file = fs.createWriteStream(localFilename)
  request = http.get(filename, (response) ->
    response.pipe(file)
    file.on('close', () ->
      # file.close()
      callback? localFilename
    )
  )


remoteFile = 'http://www.wollemipine.co.uk/acatalog/Wallpaper_CollectorsEdition800x600.jpg'
findOrDownloadImageFile(remoteFile,0,650, (localFilename) ->
  console.log "Local Filename: #{localFilename}"
  getOriginalImageData(localFilename,0,650, (oi,ri) -> resizeImage(oi,ri) )
)

path     = __dirname+'/sample-images/'
localKittens = path + 'kittens.jpg'
findOrDownloadImageFile(localKittens, 0,200,  (localFilename) ->
  console.log "Local Filename: #{localFilename}"
  getOriginalImageData(localFilename,0,200, (oi,ri) -> resizeImage(oi,ri) )
)

# remoteFile2 = 'http://www.dvdsreleasedates.com/posters/800/0/300-movie-poster.jpg'
# findOrDownloadImageFile(remoteFile2, 0,300,  (localFilename) ->
#   console.log "Local Filename: #{localFilename}"
#   getOriginalImageData(localFilename,0,300, (oi,ri) -> resizeImage(oi,ri) )
# )

# stripDimensionsFromSourceImageName('bunny3381x2468.jpg')

timeStarted = new Date
path     = __dirname+'/sample-images/'

# getOriginalImageData(path+'kittens.jpg',0,300, (oi,ri) -> resizeImage(oi,ri) )

# getOriginalImageData('pom.jpg',400,0, (oi,ri) -> resizeImage(oi,ri) )

# getOriginalImageData('bunny3381x2468.jpg',262,0, (oi,ri) -> resizeImage(oi,ri) )

# getOriginalImageData('unicorn-28904999-1700-2339.png',0,486, (oi,ri) -> resizeImage(oi,ri) )


exports.getOriginalImageData = getOriginalImageData
exports.resizeImage = resizeImage
