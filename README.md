imgresizer
==========

 Resize images to a specific height + width using a simple GET request and return a url to the resized image.


### Original Brief

Create a Node.js web service for image resizing. 
The service should accept up to 3 params: 
width, height, url and respond with image resized 
(keeping proportions) to fit in width ✕ height.
 
For example:
http://localhost:1337/resize?width=400&url=http://www.wollemipine.co.uk/acatalog/Wallpaper_CollectorsEdition800x600.jpg
will resize the given image to 400 ✕ 300.
 
Please take into account that one picture with dimensions 
(n ✕ m) can be requested multiple times, so caching is a 
smart feature. Ideally we would also like the metadata 
(url, filename, width, height, resized sizes etc) from this 
service to be stored in and queried from Redis, since this 
is what we use for our products.

Use whatever modules from npm you like for this task, and 
feel free to make and/or use your own. Coding style is of 
course arbitrary, but try to stick with Crockford-like 
formatting and follow best Node practices. 

Bonus points for any other funky features or your own 
ideas you want to add.