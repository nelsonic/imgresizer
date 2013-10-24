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

    it("getImageFormatFromFilename returns false for file incorrect extension e.g: document.doc", function() {
        var filename = 'document.doc';
        assert.equal(IR.getImageFormatFromFilename(filename), false);
        // assert.throws( function() { IR.getImageFormatFromFilename(filename) } , Error );
        // http://stackoverflow.com/questions/4144686/how-to-write-a-test-which-expects-an-error-to-be-thrown
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

});
