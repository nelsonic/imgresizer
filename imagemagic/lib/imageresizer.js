// Generated by CoffeeScript 1.6.3
var IR;

IR = {};

IR.allowedImageFormats = 'jpg jpeg gif png';

/*
Given an image file e.g: kittens.jpg
extract just the file/image format e.g: jpg
@param filename   the filename
@return format 
or throw error "File format #{format} is invalid!"
so we don't try to process a non-image file!
*/


IR.getImageFormatFromFilename = function(filename) {
  var fileparts, format;
  fileparts = filename.split('.');
  if (fileparts.length > 1) {
    format = fileparts[fileparts.length - 1].toLowerCase();
  } else {
    format = false;
  }
  if (IR.allowedImageFormats.indexOf(format) >= 0) {
    return format;
  } else {
    return false;
  }
};

/*
we don't want the sunset800x600.jpg to become sunset800x600-400x300.jpg
so we need to strip the 800x600 from the original filename
and then call the re-sized image sunset-400x300.jpg
but not strip out the digits in andre3000.jpg or 2000ad.jpg 
@param file    the filename of the original file
@param format  the file format e.g. 'jpg' or 'png'
@return nodimensions + format or simply the original file
*/


IR.stripDimensionsFromSourceImageName = function(file, format) {
  var match, nodimensions;
  match = /((\d+[x\-_]+\d+).(\bjpg\b|\bjpeg\b|\bpng\b|\bgif\b))/i.exec(file);
  if (match !== null && match.index > 0) {
    nodimensions = file.substring(0, match.index);
    return file = "" + nodimensions + "." + format;
  } else {
    return file;
  }
};

module.exports = IR;
