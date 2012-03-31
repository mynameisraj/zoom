(function() {
  var getPosition;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  self.Zoom = (function() {
    function Zoom(id, boxShadow) {
      var ESCAPE;
      this.id = id;
      this.boxShadow = boxShadow != null ? boxShadow : "0 4px 15px rgba(0, 0, 0, 0.5)";
      this.checkClicked = __bind(this.checkClicked, this);
      ESCAPE = 27;
      this.TRANSITION_DURATION = 300;
      this.opened = false;
      this.cache = [];
      this.container = document.createElement("div");
      this.container.id = this.id;
      document.body.appendChild(this.container);
      document.body.addEventListener("keyup", __bind(function(e) {
        if (e.keyCode === ESCAPE && this.opened) {
          e.preventDefault();
          return this.close();
        }
      }, this));
    }
    Zoom.prototype.checkClicked = function(e) {
      if (e.srcElement.className !== "image" && this.opened) {
        return this.close();
      }
    };
    Zoom.prototype.showLoadingIndicator = function() {};
    Zoom.prototype.hideLoadingIndicator = function() {};
    Zoom.prototype.zoom = function(element) {
      var image;
      if (element.loaded) {
        return this.doZoom(element);
      } else {
        image = document.createElement("img");
        image.onload = __bind(function() {
          return this.doZoom(element);
        }, this);
        return image.src = element.getAttribute("href");
      }
    };
    Zoom.prototype.doZoom = function(element) {
      var big, finalScaleString, finalTranslateString, finalX, finalY, fullURL, height, image, posX, posY, position, scale, scrollTop, thumb, width, wrap;
      if (this.opened) {
        this.close();
      }
      this.opened = true;
      fullURL = element.getAttribute("href");
      image = this.cache[fullURL];
      width = image.width;
      height = image.height;
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
      wrap.addEventListener("click", __bind(function(e) {
        e.preventDefault();
        return this.close();
      }, this));
      wrap.className = "wrap";
      wrap.appendChild(big);
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
      return window.setTimeout(__bind(function() {
        console.log(finalTranslateString);
        wrap.style.opacity = "1";
        wrap.style.webkitTransform = finalTranslateString;
        big.style.webkitTransform = finalScaleString;
        return window.setTimeout(__bind(function() {
          wrap.style.margin = "-" + (height / 2 + finalY - scrollTop) + "px 0 0 -" + (width / 2 + finalX) + "px";
          wrap.style.top = "50%";
          wrap.style.left = "50%";
          wrap.style.width = "" + width + "px";
          wrap.style.height = "" + height + "px";
          wrap.style.boxShadow = this.boxShadow;
          return document.body.addEventListener("click", this.checkClicked, false);
        }, this), this.TRANSITION_DURATION);
      }, this), 0);
    };
    Zoom.prototype.close = function() {
      var wrap;
      document.body.removeEventListener("click", this.checkClicked, false);
      this.opened = false;
      wrap = document.getElementsByClassName("wrap")[0];
      wrap.style.boxShadow = "none";
      wrap.style.webkitTransform = this.translateString;
      wrap.style.opacity = "0";
      wrap.firstChild.style.webkitTransform = this.scaleString;
      return window.setTimeout(__bind(function() {
        return this.container.removeChild(wrap);
      }, this), this.TRANSITION_DURATION);
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
