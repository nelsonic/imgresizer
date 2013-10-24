# im = require 'imagemagick'
# fs = require 'fs'
# http = require 'http'
# redis = require 'redis'
IR = {}
# IR.sqrt = (x) ->
#   throw new Error("sqrt can't work on negative number")  if x < 0
#   Math.exp Math.log(x) / 2
IR.allowedImageFormats = 'jpg jpeg gif png'

###
Given an image file e.g: kittens.jpg
extract just the file/image format e.g: jpg
@param filename   the filename
@return format 
or throw error "File format #{format} is invalid!"
so we don't try to process a non-image file!
###
IR.getImageFormatFromFilename = (filename) ->
  fileparts = filename.split('.')
  if fileparts.length > 1
    format = fileparts[fileparts.length-1].toLowerCase()
  else
    format = false
  # confirm the file format is valid (otherwize halt processing)
  if IR.allowedImageFormats.indexOf(format) >= 0
    return format
  else
    # console.log "#{format} is NOT a valid Image!"
    # consider using Winston here to avoid crashing the app
    # throw new Error("Wrong format")
    # throwing an error is lame so returning false instead.
    return false


# getFilenameWithoutExtension = (filename,format) ->
#   # strip any path data e.g. /mypics/sub/directory
#   lastFowardSlash = filename.lastIndexOf('/')
#   if lastFowardSlash != null && lastFowardSlash > 0
#     filename = filename.substring(lastFowardSlash+1, filename.length)
#   # remove image dimensions from filename
#   filename = stripDimensionsFromSourceImageName(filename, format)
#   # isolate the name of the file from the extension so we
#   # can put the file dimensions in the resized filename
#   lastOccurenceOfExtension = filename.lastIndexOf("."+format)
#   # ensure we don't strip a file that includes the extension
#   # in the filename e.g. myphoto.jpg.jpg (it happens! google it!)
#   filenameWithoutExtension = filename.substring(0, lastOccurenceOfExtension)

###
we don't want the sunset800x600.jpg to become sunset800x600-400x300.jpg
so we need to strip the 800x600 from the original filename
and then call the re-sized image sunset-400x300.jpg
but not strip out the digits in andre3000.jpg or 2000ad.jpg 
@param file    the filename of the original file
@param format  the file format e.g. 'jpg' or 'png'
@return nodimensions + format or simply the original file
###
IR.stripDimensionsFromSourceImageName = (file, format) ->
  # this regular expression finds mypic3381_x_2468.jpg or mypic3381x2468.jpg
  # and even the obscure unicorns-28904999-1700-2339.png (where w=1700 and h=2339)
  # but misses our friends andre3000.jpg and 200ad.gif :-)
  # Its NOT perfect tho, and with time, I would like to write 
  # a few more test cases so we can avoid false positives
  # but since it was not in the spec I've left it for now...
  # in would prefer the file extensions to NOT be Hard Coded... 
  match = (/((\d+[x\-_]+\d+).(\bjpg\b|\bjpeg\b|\bpng\b|\bgif\b))/i).exec file
  # console.log match
  if match != null && match.index > 0 
    nodimensions = file.substring(0, match.index)
    # console.log "Substring 0,match.index #{nodimensions}"
    return file = "#{nodimensions}.#{format}"
  else
    return file

###
  returns just the filename e.g. 'kitten.jpg' >> 'kitten'
  we use this to apply the dimmensions to re-sized image filename
  e.g. kitten.jpg >> 'kitten' + '-400x300' .'jpg'
  the reason we have a method for this instead of just stripping the 
  format off the filename is for the instances where people call their
  file kitten.jpg.jpg don't laugh, it happens more often than you think!
  @param filename the name of the file e.g. 'kitten.jpg'
  @param format the file format e.g. '.jpg'
  @return filenameWithoutExtension e.g. 'kitten'
###

IR.getFilenameWithoutExtension = (filename,format) ->
  # console.log "Filename : #{filename} | Format: #{format}"
  # strip any path data e.g. /mypics/sub/directory
  lastFowardSlash = filename.lastIndexOf('/')
  if lastFowardSlash != null && lastFowardSlash > 0
    filename = filename.substring(lastFowardSlash+1, filename.length)
  # remove image dimensions from filename
  filename = IR.stripDimensionsFromSourceImageName(filename, format)
  # isolate the name of the file from the extension so we
  # can put the file dimensions in the resized filename
  lastOccurenceOfExtension = filename.lastIndexOf("."+format)
  # ensure we don't strip a file that includes the extension
  # in the filename e.g. myphoto.jpg.jpg (it happens! google it!)
  # console.log "filename before strip extension: #{filename}"

  filenameWithoutExtension = filename.substring(0, lastOccurenceOfExtension)
  # console.log "filenameWithoutExtension : #{filenameWithoutExtension}"
  return filenameWithoutExtension

### 
  if only spplied with either width or height we can calculate 
  width from height or height from width using the original image's (oi)
  aspect ratio. (which we expect to be a property oi.aspectRatio)
  @param oi an object containing properties of the original image (aspectRatio)
  @param width (optional) the width of the image
  @param height (optional) the height of the image
  @return ri an object containing the width & height of the re-sized image (ri)
###

IR.getHeightFromWidthUsingAspectRatio = (oi, width, height) ->
  ri = {}
  # check if the resized image width is defined
  if typeof width != "undefined" && width != undefined && parseInt(width) > 0
    ri.width = parseInt(width)
    ri.height = Math.round(ri.width / oi.aspectRatio)
  else if typeof height != "undefined" && height != undefined && parseInt(height) > 0
    ri.height = parseInt(height)
    ri.width = Math.round(ri.height * oi.aspectRatio)
  else
    return false
  return ri

# if typeof module != 'undefined'
module.exports = IR 