chai = require('chai')
assert = chai.assert

describe("IR - Image Resizer", function() {

    beforeEach(function () {
        IR = require('../lib/imageresizer.js');
    });

    it("getImageFormatFromFilename format should be jpg for Wallpaper800x600.jpg", function() {
        var filename = 'http://www.wollemipine.co.uk/acatalog/Wallpaper800x600.jpg';
        format = IR.getImageFormatFromFilename(filename);
        assert.equal(format, 'jpg');
    });

    it("getImageFormatFromFilename format should be png for rainbow.png", function() {
        var filename = 'http://www.wollemipine.co.uk/acatalog/rainbow.png';
        var format = IR.getImageFormatFromFilename(filename);
        assert.equal(format, 'png');
    });

    it("getImageFormatFromFilename returns false for file without extension e.g: rainbow", function() {
        var filename = 'rainbow';
        assert.equal(IR.getImageFormatFromFilename(filename), false);
        // expect(IR.getImageFormatFromFilename(filename)).toThrow(new Error('File format none is invalid in rainbow!'));
        // would prefer to throw an error here but unable to for some reason... :-(
    });

    it("stripDimensionsFromSourceImageName Should strip dimensions from Wallpaper800x600.jpg", function() {
        var originalImage = 'http://www.wollemipine.co.uk/acatalog/Wallpaper800x600.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        // expect(stripped).toEqual('http://www.wollemipine.co.uk/acatalog/Wallpaper.jpg');
        assert.equal(stripped, 'http://www.wollemipine.co.uk/acatalog/Wallpaper.jpg');
    });

    it("stripDimensionsFromSourceImageName Should strip dimensions from mypic3381_x_2468.jpg", function() {
        var originalImage = 'mypic3381_x_2468.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        // expect(stripped).toEqual('mypic.jpg');
        assert.equal(stripped, 'mypic.jpg');
    });

    it("stripDimensionsFromSourceImageName Should NOT strip numbers from andre3000.jpg", function() {
        var originalImage = 'andre3000.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        // expect(stripped).toEqual(originalImage);
        assert.equal(stripped, originalImage);
    });

    it("stripDimensionsFromSourceImageName Should NOT strip numbers from 2000ad.jpg", function() {
        var originalImage = '2000ad.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        assert.equal(stripped, originalImage);
    });

    it("stripDimensionsFromSourceImageName Should NOT strip anything from kittens.jpg", function() {
        var originalImage = 'kittens.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        assert.equal(stripped, originalImage);
    });

    it("getFilenameWithoutExtension returns kittens for kittens.jpg", function() {
        var filename = 'kittens.jpg';
        var format = IR.getImageFormatFromFilename(filename);
        var filenameWithoutExtension = IR.getFilenameWithoutExtension(filename,format);
        // console.log('filenameWithoutExtension: '+filenameWithoutExtension);
        assert.equal(filenameWithoutExtension,'kittens')
    });

    it("getFilenameWithoutExtension returns selfie for http://fb.me/pix/selfie800x600.jpg", function() {
        var filename = 'http://fb.me/pix/selfie800x600.jpg';
        var format = IR.getImageFormatFromFilename(filename);
        var filenameWithoutExtension = IR.getFilenameWithoutExtension(filename,format);
        // console.log('filenameWithoutExtension: '+filenameWithoutExtension);
        assert.equal(filenameWithoutExtension,'selfie')
    });


    it("getHeightFromWidthUsingAspectRatio returns both width and height given either + aspectRatio", function() {
        var oi = {aspectRatio : 800/600}
        var desiredWidth = null
        var desiredHeight = 300
        ri = IR.getHeightFromWidthUsingAspectRatio(oi, desiredWidth, desiredHeight)
        assert.equal(ri.width,400)
    });

    it("getHeightFromWidthUsingAspectRatio returns both width and height given either + aspectRatio", function() {
        var oi = {aspectRatio : 900/1200}
        var desiredWidth = 600
        var desiredHeight = 0
        ri = IR.getHeightFromWidthUsingAspectRatio(oi, desiredWidth, desiredHeight)
        assert.equal(ri.height,800)
    });

    it("getHeightFromWidthUsingAspectRatio returns false if BOTH width and height NOT supplied", function() {
        var oi = {aspectRatio : 900/1200}
        var desiredWidth = 0
        var desiredHeight = 0
        ri = IR.getHeightFromWidthUsingAspectRatio(oi, desiredWidth, desiredHeight)
        assert.equal(ri,false)
    });

    it("getHeightFromWidthUsingAspectRatio returns false if oi.aspectRatio NOT supplied", function() {
        var oi = {},
            desiredWidth = 600,
            desiredHeight = 400,
        ri = IR.getHeightFromWidthUsingAspectRatio(oi, desiredWidth, desiredHeight);
        assert.equal(ri,false);
    });


    xit("getOriginalImageAttributes returns oi object (original image attributes)", function() {
        var parentDir = __dirname.substring(0, __dirname.lastIndexOf('/'));
        // console.log(parentDir);
        var filename = parentDir+'/sample-images/kittens.jpg';
        // IR.getOriginalImageAttributes(filename, function(oi) {
        //     console.log(oi);
        //     assert.equal(oi.width,1600);
        // })
        console.log(IR.im);
        IR.im.identify(filename, function(err,ia) {
            if(err) console.log(err);
            console.log(ia.width);
        });



    });



});
