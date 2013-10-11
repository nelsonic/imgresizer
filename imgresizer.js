// Generated by CoffeeScript 1.6.3
(function() {
  var displayError, displayScaledImage, getUrlParameters, urlParams;

  getUrlParameters = function() {
    var key, p, params, parts, query, urlParams, value, _i, _len;
    params = {};
    urlParams = {};
    console.log('href: ' + location.href);
    query = location.href.split('?');
    console.log('Query length: ' + query.length);
    if (query.length > 1 && query[1] !== 'undefined') {
      urlParams = query[1].split('&');
    }
    if (urlParams.length > 0) {
      for (_i = 0, _len = urlParams.length; _i < _len; _i++) {
        p = urlParams[_i];
        parts = p.split('=');
        key = parts[0];
        value = parts[1];
        params[key] = value;
      }
    }
    return params;
  };

  displayError = function(msg) {
    var errMsg;
    errMsg = document.createElement('h1');
    errMsg.innerHTML = msg;
    errMsg.style.color = 'red';
    errMsg.style.fontFamily = 'sans-serif';
    return document.body.appendChild(errMsg);
  };

  displayScaledImage = function(urlParams) {
    var fail, img, oi;
    oi = oi || {};
    img = new Image();
    fail = "http://i.imgur.com/gvAz9At.jpg";
    if (urlParams.url !== 'undefined') {
      img.src = urlParams.url;
    } else {
      displayError('No url parameter supplied! :-( <br />');
      img.src = fail;
    }
    img.onerror = function() {
      console.log('Image Load Error!! :-(');
      displayError('Image Failed to Load! :-( <br />' + img.src);
      return img.src = fail;
    };
    return img.onload = function(ir) {
      oi.width = this.width;
      oi.height = this.height;
      oi.aspectRatio = Math.floor((this.width / this.height) * 100) / 100;
      console.log("Original Image Width: " + oi.width);
      console.log("Original Height: " + oi.height);
      console.log("Original Aspect Ratio: " + oi.aspectRatio);
      if (urlParams.width !== 'undefined' && urlParams.width > 0) {
        img.width = parseInt(urlParams.width);
      } else if (urlParams.height !== 'undefined' && urlParams.height > 0) {
        img.height = parseInt(urlParams.height);
      }
      return document.body.appendChild(img);
    };
  };

  urlParams = getUrlParameters();

  console.log('url: ' + urlParams.url);

  console.log('w: ' + urlParams.width);

  console.log('h: ' + urlParams.height);

  displayScaledImage(urlParams);

  console.log('imgresizer finished');

}).call(this);
