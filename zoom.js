// Generated by CoffeeScript 1.3.1
(function() {
  var getPosition,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.verbose = false;

  self.Zoom = (function() {

    Zoom.name = 'Zoom';

    function Zoom(id, boxShadow, titleStyle) {
      this.id = id;
      this.boxShadow = boxShadow != null ? boxShadow : "0 4px 15px rgba(0, 0, 0, 0.5)";
      this.titleStyle = titleStyle != null ? titleStyle : "background-color: #fff; text-align: center; padding: 5px 0; font: 14px/1 Helvetica, sans-serif";
      this.checkClicked = __bind(this.checkClicked, this);

      this.checkKey = __bind(this.checkKey, this);

      this.ESCAPE = 27;
      this.TRANSITION_DURATION = 300;
      this.opened = false;
      this.cache = [];
      this.container = document.createElement("div");
      this.container.id = this.id;
      document.body.appendChild(this.container);
    }

    Zoom.prototype.checkKey = function(e) {
      if (e.keyCode === this.ESCAPE && this.opened) {
        e.preventDefault();
        return this.close();
      }
    };

    Zoom.prototype.checkClicked = function(e) {
      if (e.srcElement.className !== "image" && this.opened) {
        return this.close();
      }
    };

    Zoom.prototype.showLoadingIndicator = function() {};

    Zoom.prototype.hideLoadingIndicator = function() {};

    Zoom.prototype.zoom = function(element) {
      var image,
        _this = this;
      if (element.loaded) {
        return this.doZoom(element);
      } else {
        image = document.createElement("img");
        image.onload = function() {
          return _this.doZoom(element);
        };
        return image.src = element.getAttribute("href");
      }
    };

    Zoom.prototype.doZoom = function(element) {
      var big, finalScaleString, finalTranslateString, finalX, finalY, fullURL, height, image, posX, posY, position, scale, scrollTop, thumb, title, width, wrap,
        _this = this;
      if (this.opened) {
        this.close();
      }
      this.opened = true;
      fullURL = element.getAttribute("href");
      image = this.cache[fullURL];
      if (image === void 0) {
        image = document.createElement("img");
        image.setAttribute("src", fullURL);
        this.cache[fullURL] = image;
      }
      width = image.width;
      height = image.height;
      if (element.getAttribute("title")) {
        title = document.createElement("div");
        title.className = "title";
        title.innerHTML = element.getAttribute("title");
        title.setAttribute("style", this.titleStyle);
        /*
        			Little trick to get the offsetHeight
        			Quickly add and remove title
        */

        title.style.visibility = "hidden";
        document.body.appendChild(title);
        height += title.offsetHeight;
        document.body.removeChild(title);
      }
      thumb = element.firstChild;
      position = getPosition(thumb);
      posX = position.x - (width - thumb.offsetWidth) / 2;
      posY = position.y - (height - thumb.offsetHeight) / 2;
      big = document.createElement("img");
      big.className = "image";
      big.setAttribute("src", fullURL);
      big.style.webkitTransition = "-webkit-transform 0.3s";
      big.style.display = "block";
      wrap = document.createElement("div");
      wrap.className = "wrap";
      wrap.appendChild(big);
      if (element.getAttribute("title")) {
        wrap.appendChild(title);
      }
      wrap.style.webkitTransition = "-webkit-transform 0.3s, opacity 0.25s, box-shadow 0.2s";
      wrap.style.position = "absolute";
      wrap.style.left = "0";
      wrap.style.top = "0";
      scale = {
        x: thumb.offsetWidth / width,
        y: thumb.offsetHeight / height
      };
      this.scaleString = "scale3d(" + scale.x + ", " + scale.y + ", 1)";
      this.translateString = "translate3d(" + posX + "px, " + posY + "px, 0)";
      wrap.style.webkitTransform = "" + this.translateString;
      big.style.webkitTransform = "" + this.scaleString;
      wrap.style.opacity = "0";
      this.container.appendChild(wrap);
      scrollTop = document.body.scrollTop;
      finalX = window.innerWidth / 2 - width / 2;
      finalY = window.innerHeight / 2 - height / 2 + scrollTop;
      finalScaleString = "scale3d(1, 1, 1)";
      finalTranslateString = "translate3d(" + finalX + "px, " + finalY + "px, 0)";
      return window.setTimeout(function() {
        if (window.verbose) {
          console.log(finalTranslateString);
        }
        wrap.style.opacity = "1";
        wrap.style.webkitTransform = finalTranslateString;
        big.style.webkitTransform = finalScaleString;
        return window.setTimeout(function() {
          wrap.style.margin = "-" + (height / 2 + finalY - scrollTop) + "px 0 0 -" + (width / 2 + finalX) + "px";
          wrap.style.top = "50%";
          wrap.style.left = "50%";
          wrap.style.width = "" + width + "px";
          wrap.style.height = "" + height + "px";
          wrap.style.boxShadow = _this.boxShadow;
          if (element.getAttribute("title")) {
            title.style.visibility = "visible";
          }
          document.body.addEventListener("click", _this.checkClicked, false);
          wrap.addEventListener("click", function(e) {
            e.preventDefault();
            return _this.close();
          });
          return document.body.addEventListener("keyup", _this.checkKey, false);
        }, _this.TRANSITION_DURATION);
      }, 0);
    };

    Zoom.prototype.close = function() {
      var closeDelay, newTransitionDuration, wrap,
        _this = this;
      document.body.removeEventListener("click", this.checkClicked, false);
      document.body.removeEventListener("keyup", this.checkKey, false);
      this.opened = false;
      closeDelay = 50;
      newTransitionDuration = closeDelay + this.TRANSITION_DURATION;
      wrap = document.getElementsByClassName("wrap")[0];
      wrap.style.webkitTransition = wrap.style.webkitTransition.replace(", box-shadow 0.2s", "");
      window.setTimeout(function() {
        return wrap.style.boxShadow = "none";
      }, 0);
      window.setTimeout(function() {
        wrap.style.webkitTransform = _this.translateString;
        wrap.style.opacity = "0";
        return wrap.firstChild.style.webkitTransform = _this.scaleString;
      }, closeDelay);
      return window.setTimeout(function() {
        try {
          return _this.container.removeChild(wrap);
        } catch (error) {
          if (window.verbose) {
            return console.log(error);
          }
        }
      }, newTransitionDuration);
    };

    return Zoom;

  })();

  /*
  Returns the absolute position of an element.
  Adapted from quirksmode.org/js/findpos.html
  */


  getPosition = function(el) {
    var left, top;
    left = 0;
    top = 0;
    if (el.offsetParent) {
      left += el.offsetLeft;
      top += el.offsetTop;
      while (el = el.offsetParent) {
        left += el.offsetLeft;
        top += el.offsetTop;
      }
    }
    return {
      x: left,
      y: top
    };
  };

}).call(this);
