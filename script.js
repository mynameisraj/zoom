(function() {
  var addLinkListeners, cacheImage, handleZoom, init;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  init = function() {
    console.log("loaded");
    window.zoom = new Zoom("z");
    return addLinkListeners();
  };
  addLinkListeners = function() {
    var a, fileTypes, type, _i, _len, _ref, _results;
    fileTypes = [".jpg", ".png", ".gif", ".jpeg", ".bmp", ".tiff", ".webm"];
    _ref = document.getElementsByTagName("a");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      _results.push((function() {
        var _j, _len2, _results2;
        _results2 = [];
        for (_j = 0, _len2 = fileTypes.length; _j < _len2; _j++) {
          type = fileTypes[_j];
          _results2.push((function() {
            if (a.getAttribute("href").match(type)) {
              try {
                if (a.firstChild === a.getElementsByTagName("img")[0]) {
                  a.addEventListener("mouseover", cacheImage, false);
                  return a.addEventListener("click", handleZoom, false);
                }
              } catch (e) {

              }
            }
          })());
        }
        return _results2;
      })());
    }
    return _results;
  };
  handleZoom = function(e) {
    var image;
    e.preventDefault();
    if (this.loaded) {
      return window.zoom.zoom(this);
    } else {
      image = document.createElement("img");
      image.onload = __bind(function() {
        this.loaded = true;
        window.zoom.cache[image.src] = image;
        return window.zoom.zoom(this);
      }, this);
      return image.src = this.getAttribute("href");
    }
  };
  cacheImage = function(e) {
    var image, url;
    image = document.createElement("img");
    url = this.getAttribute("href");
    image.onload = __bind(function() {
      this.loaded = true;
      window.zoom.cache[url] = image;
      return this.removeEventListener("mouseover", cacheImage, false);
    }, this);
    return image.src = url;
  };
  window.addEventListener("DOMContentLoaded", init, false);
}).call(this);
