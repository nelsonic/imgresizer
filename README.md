imgresizer
==========

Resize images to a specific height + width using a 
GET request and return a url to the resized image.

- - -

If we could rely on the clients visiting our app/site to be using a modern
(HTML5 Canvas enabled) browser, we could skip the node.js resizing and just
do all the image manipulation on the client-side.

But since the brief states we have to build a node.js web service, I will 
demonstrate solutions using node.js first. 

**Note**: This app runs on EC2+S3.
If you do not yet have an AWS EC2 instance set up,
follow my simple tutorial: https://github.com/nelsonic/EC2Setup

I'm also using Redis to store the meta-data as per the brief (see below)
so if you don't already have redis installed on your machine,
do so now: 

Mac & Ubuntu: 

```terminal
curl -O http://download.redis.io/releases/redis-2.6.16.tar.gz
tar xzf redis-2.6.16.tar.gz
cd redis-2.6.16
make
```

Once its installed, start the server by running the command:

```terminal
redis-server
```

I highly recommend [Redis Commander](http://nearinfinity.github.io/redis-commander/)
for managing your Redis data. 

```terminal
npm install -g redis-commander
redis-commander
```

now visit: 127.0.0.1:8081 [local]
or 
http://54.229.220.192:8081  [remote]


## Solution 1 - ImageMagic

If you are new to ImageMagic see: imagemagick.org

#### Install ImageMagic

On a Ubuntu server (ec2) enter the following installation command:

```terminal
sudo apt-get install imagemagick
```

If you are running this app on your Mac dev machine,

```terminal
brew install imagemagick
```

Next install the 
[node-imagemagic](https://github.com/rsms/node-imagemagick) module

```terminal
npm install imagemagick
```

If you need to test if your ImageMagic module installed correctly,
execute the following command:

```terminal
node magictest
```

Once you've confirmed its working, start the server:

```terminal
nodemon app
```





I could use [Image Magic](https://github.com/rsms/node-imagemagick) 
but in addition to the Node module this would require 
installing/maintaining the library on all machines that 
are going to run image resizer (one more package to maintain...)

Instead I'm going to try something *different*.

I've challenged myself to use as few lines of code and modules as possible.

What about re-sizing the image *client side* and uploading 
it *directly to Amazon S3* without going through 
*any* web server thus **eliminate processing bottleneck**?
http://aws.amazon.com/articles/1434


Steps:

load the resize.html (or /resize) page
if the there are url parameters set we check to see if the image has been uploaded:

>> file://localhost/Users/n/code/imgresizer/resize.html
>> file:///Users/n/code/imgresizer/resize.html?width=700&url=http://www.wollemipine.co.uk/acatalog/Wallpaper_CollectorsEdition800x600.jpg
>> http://localhost:5000/resize.html?width=700&url=http://www.wollemipine.co.uk/acatalog/Wallpaper_CollectorsEdition800x600.jpg





### Original Brief

Create a **Node.js web service** for **image resizing**. 
The service should accept up to **3 params**: 
**width**, **height**, **url** and *respond* with **image resized** 
(keeping proportions) to fit in width ✕ height.
 
For example:
http://localhost:1337/resize?width=400&url=http://www.wollemipine.co.uk/acatalog/Wallpaper_CollectorsEdition800x600.jpg
will resize the given image to 400 ✕ 300.
 
Please take into account that one picture with dimensions 
(n ✕ m) can be requested multiple times, so caching is a 
smart feature. Ideally we would also like the **metadata** 
(url, filename, width, height, resized sizes etc) from this 
service to be stored in and queried from Redis, since this 
is what we use for our products.

Use whatever modules from npm you like for this task, and 
feel free to make and/or use your own. Coding style is of 
course arbitrary, but try to stick with Crockford-like 
formatting and follow best Node practices. 

Bonus points for any other funky features or your own 
ideas you want to add.

### Research

#### Potential Modules

- ImageMagic Ubuntu Install: https://help.ubuntu.com/community/ImageMagick
- Winston Error Logging: https://github.com/flatiron/winston

#### Existing Image Resizers

- canvasResize: https://github.com/gokercebeci/canvasResize
- Simgr (A not-so-simple image resizer): https://github.com/funraiseme/simgr
- JS-Resize: https://github.com/nicam/js-resize
- PhantomJS Screen Capture: https://github.com/ariya/phantomjs/wiki/Screen-Capture
- node-imagemagic: https://github.com/rsms/node-imagemagick
- node-canvas (reqires Cairo): https://github.com/learnboost/node-canvas
- Graphics Magic (for node): http://aheckmann.github.io/gm/
- ZombieJS (to drive the Client): http://zombie.labnotes.org/

#### Blog Posts & Articles

- **JS Image Resize** (Canvas): http://blog.liip.ch/archive/2013/05/28/resizing-images-with-javascript.html
demo: http://clientside-resize.labs.liip.ch/
- Maintaining Aspect Ratio: http://stackoverflow.com/questions/1186414/whats-the-algorithm-to-calculate-aspect-ratio-i-need-an-output-like-43-169
- Draw image from url to Canvas: http://stackoverflow.com/questions/4773966/drawing-an-image-from-a-data-url-to-a-canvas
- Save Canvas Drawing as Image: http://www.html5canvastutorials.com/advanced/html5-canvas-save-drawing-as-an-image/
- Get Canvas Image Data: http://www.html5canvastutorials.com/advanced/html5-canvas-get-image-data-url/
- Upload image (or any other file!) to S3 directly: http://aws.amazon.com/articles/1434

http://scriptular.com/#%5Cd%2B%5Cw%2B%5Cd%2B.(%5Cbjpg%5Cb%7C%5Cbpng%5Cb%7C%5Cbgif%5Cb)%7C%7C%7C%7Ci%7C%7C%7C%7C%5B%22sunset400x300.jpg%22%2C%22unset400x5xyz300.png%22%2C%22unset400x300.gif%22%5D

>> Similar problem: http://stackoverflow.com/questions/17644576/uploading-image-to-s3-and-then-resizing-in-node-js
(add answer to get points!)

If you are unfamilar with Redis (the datastore used in this example)
see: http://redis.io/topics/quickstart
and: http://redis.io/topics/data-types-intro