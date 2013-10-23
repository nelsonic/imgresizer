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
    format = 'none'
  # confirm the file format is valid (otherwize halt processing)
  if IR.allowedImageFormats.indexOf(format) >= 0
    return format
  else
    # console.log "#{format} is NOT a valid Image!"
    # consider using Winston here to avoid crashing the app
    throw new Error("File format #{format} is invalid in #{filename}!")

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


# if typeof module != 'undefined'
#   module.exports = IR