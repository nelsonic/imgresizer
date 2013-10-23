describe("IR - Image Resizer", function() {

  // beforeEach(function () {
  //   IR = require('../../imageresizer.js');
  // });

  xit("should compute the square root of 4 as 2", function() {
    expect(IR.sqrt(4)).toEqual(2);
  });

  xit("should throw an exception if given a negative number", function() {
    expect(function(){ IR.sqrt(-1); }).toThrow(new Error("sqrt can't work on negative number"));
  });

    it("getImageFormatFromFilename format should be jpg for Wallpaper800x600.jpg", function() {
        var filename = 'http://www.wollemipine.co.uk/acatalog/Wallpaper800x600.jpg';
        format = IR.getImageFormatFromFilename(filename);
        expect(format).toEqual('jpg');
    });

    it("getImageFormatFromFilename format should be png for rainbow.png", function() {
        var filename = 'http://www.wollemipine.co.uk/acatalog/rainbow.png';
        var format = IR.getImageFormatFromFilename(filename);
        expect(format).toEqual('png');
    });

    it("getImageFormatFromFilename should throw error for file without extension e.g: rainbow", function() {
        var filename = 'rainbow';
        expect(function(){ 
            IR.getImageFormatFromFilename(filename)
        }).toThrow(new Error("File format none is invalid in rainbow!"));
    });

    it("getImageFormatFromFilename should throw error for file incorrect extension e.g: document.doc", function() {
        var filename = 'document.doc';
        expect(function(){ 
            IR.getImageFormatFromFilename(filename)
        }).toThrow(new Error("File format doc is invalid in document.doc!"));
    });


    it("stripDimensionsFromSourceImageName Should strip dimensions from Wallpaper800x600.jpg", function() {
        var originalImage = 'http://www.wollemipine.co.uk/acatalog/Wallpaper800x600.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        expect(stripped).toEqual('http://www.wollemipine.co.uk/acatalog/Wallpaper.jpg');
    });

    it("stripDimensionsFromSourceImageName Should strip dimensions from mypic3381_x_2468.jpg", function() {
        var originalImage = 'mypic3381_x_2468.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        expect(stripped).toEqual('mypic.jpg');
    });

    it("stripDimensionsFromSourceImageName Should NOT strip numbers from andre3000.jpg", function() {
        var originalImage = 'andre3000.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        expect(stripped).toEqual(originalImage);
    });

    it("stripDimensionsFromSourceImageName Should NOT strip numbers from 2000ad.jpg", function() {
        var originalImage = '2000ad.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        expect(stripped).toEqual(originalImage);
    });

    it("stripDimensionsFromSourceImageName Should NOT strip anything from kittens.jpg", function() {
        var originalImage = 'kittens.jpg';
        var stripped = IR.stripDimensionsFromSourceImageName(originalImage, 'jpg');
        expect(stripped).toEqual(originalImage);
    });

});
