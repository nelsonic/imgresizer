redis = require 'redis'
client = redis.createClient()

client.on("error", () ->
  console.log("REDIS FAIL")
)

originalFile = 'Wallpaper_CollectorsEdition800x600.jpg'
# a re-sized image:
ri = {
  aspectRatio : (648/486),
  '648x486' : {
    localFilename : '/Users/n/code/imgresizer/imagemagic/resized-images/Wallpaper_CollectorsEdition-648x486.jpg',
    width : 648,
    height : 486
  },
  '343x257' : {
    localFilename : '/Users/n/code/imgresizer/imagemagic/resized-images/Wallpaper_CollectorsEdition-343x257.jpg',
    width : 343,
    height : 257
  }
}

client.set(originalFile, JSON.stringify(ri), redis.print)

client.get(originalFile, (err, reply) ->
  if (err)
    console.log("Get error: " + err);
  else
    data = JSON.parse(reply)
    console.log data['343x257']
    # fs.writeFile("duplicate_" + filename, reply, (err) ->
    # if (err)
    #   console.log("Error on write: " + err)
    # else
    #   console.log("File written.");
    #   client.end();
    # )
)

client.quit( (err, res) ->
  console.log "Exiting from quit command" 
)