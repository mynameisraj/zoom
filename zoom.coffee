class self.Zoom
	# Constructor
	constructor: (@id) ->
		# Constants
		ESCAPE = 27
		@BOX_SHADOW = "0 4px 15px rgba(0, 0, 0, 0.5)"
		@TRANSITION_DURATION = 300
		
		@opened = false
		@cache = []
		
		# Create a container for whole thing
		@container = document.createElement "div"
		@container.id = @id
		document.body.appendChild(@container)
		
		# Close listeners
		document.body.addEventListener "keyup", (e) =>
			if e.keyCode is ESCAPE and @opened
				e.preventDefault()
				@close()
	
	# Click listener for outside box
	checkClicked: (e) =>
		if e.srcElement.className isnt "image" and @opened
			@close()
			
	# Zoom selected image
	zoom: (element) ->
		if element.loaded
			@doZoom element
		else
			image = document.createElement "img"
			image.onload = =>
				@doZoom element
			image.src = element.getAttribute "href"
		
	doZoom: (element) ->
		# Close the zoomed image
		if @opened
			@close()
		@opened = true
		
		# Retrieve cached image
		fullURL = element.getAttribute "href"
		image = @cache[fullURL]
		width = image.width
		height = image.height
		
		# Figure out where our element is based on its thumbnail
		thumb = element.firstChild
		position = getPosition thumb
		posX = position.x - (width - thumb.offsetWidth)/2
		posY = position.y - (height - thumb.offsetHeight)/2
		
		# Create DOM image
		big = document.createElement "img"
		big.className = "image"
		big.setAttribute "src", fullURL
		
		# Create wrapping div
		wrap = document.createElement "div"
		wrap.addEventListener "click", (e) =>
			e.preventDefault()
			@close()
		wrap.className = "wrap"
		wrap.appendChild big
		
		# Find the scale
		scale = {
			x: thumb.offsetWidth / width,
			y: thumb.offsetHeight / height
		}
		
		# Make the wrapping div same as thumb
		@scaleString = "scale3d(#{scale.x}, #{scale.y}, 1)"
		@translateString = "translate3d(#{posX}px, #{posY}px, 0)"
		wrap.style.webkitTransform = "#{@translateString}"
		big.style.webkitTransform = "#{@scaleString}"
		wrap.style.opacity = "0"
		
		# Add to body
		@container.appendChild wrap
		
		# Find the place where the big version needs to be
		scrollTop = document.body.scrollTop
		finalX = window.innerWidth/2 - width/2
		finalY = window.innerHeight/2 - height/2 + scrollTop
		finalScaleString = "scale3d(1, 1, 1)"
		finalTranslateString = "translate3d(#{finalX}px, #{finalY}px, 0)"
		
		# Animate the big change
		window.setTimeout =>
			console.log finalTranslateString
			wrap.style.opacity = "1"
			wrap.style.webkitTransform = finalTranslateString
			big.style.webkitTransform = finalScaleString
			window.setTimeout =>
				# Set the margins so that it stays centered without js
				wrap.style.margin = "-#{height/2 + finalY - scrollTop}px 0 0 -#{width/2 + finalX}px"
				wrap.style.top = "50%"
				wrap.style.left = "50%"
				wrap.style.width = "#{width}px"
				wrap.style.height = "#{height}px"
				
				# Add a box shadow for flair
				wrap.style.boxShadow = @BOX_SHADOW
				
				# Add click listener
				document.body.addEventListener "click", @checkClicked, false
			, @TRANSITION_DURATION
		, 0
	
	# Close it	
	close: ->
		# Remove click listener
		document.body.removeEventListener "click", @checkClicked, false
		
		@opened = false
		
		# Remove styles, shrink, and delete wrap
		wrap = document.getElementsByClassName("wrap")[0]
		wrap.style.boxShadow = "none"
		wrap.style.webkitTransform = @translateString
		wrap.style.opacity = "0"
		wrap.firstChild.style.webkitTransform = @scaleString
		window.setTimeout =>
			@container.removeChild wrap
		, @TRANSITION_DURATION

###
Returns the absolute position of an element.
Adapted from quirksmode.org/js/findpos.html
###
getPosition = (el) ->
	left = 0
	top = 0
	
	if (el.offsetParent)
		left += el.offsetLeft
		top += el.offsetTop
		
		while el = el.offsetParent
			left += el.offsetLeft
			top += el.offsetTop
	
	{
		x: left,
		y: top
	}