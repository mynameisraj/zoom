window.verbose = false

class self.Zoom
	# Constructor
	constructor: (@id, @boxShadow = "0 4px 15px rgba(0, 0, 0, 0.5)", @titleStyle = "background-color: #fff; text-align: center; padding: 5px 0; font: 14px/1 Helvetica, sans-serif") ->
		# Constants
		@ESCAPE = 27
		@TRANSITION_DURATION = 300
		
		@opened = false
		@cache = []
		
		# Create a container for whole thing
		@container = document.createElement "div"
		@container.id = @id
		document.body.appendChild(@container)
			
	# Key listener for escape
	checkKey: (e) =>
		if e.keyCode is @ESCAPE and @opened
			e.preventDefault()
			@close()
	
	# Click listener for outside box
	checkClicked: (e) =>
		if e.srcElement.className isnt "image" and @opened
			@close()
			
	# Shows the loading indicator
	showLoadingIndicator: ->
		# You can fill out this function if you need a loading indicator to be displayed
	
	# Hides the loading indicator
	hideLoadingIndicator: ->
		# Here is where you hide the loading indicator that you created above
			
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
		if image is undefined
			image = document.createElement "img"
			image.setAttribute "src", fullURL
			@cache[fullURL] = image
		width = image.width
		height = image.height
		
		# Create title, recompute height
		if element.getAttribute "title"
			title = document.createElement "div"
			title.className = "title"
			title.innerHTML = element.getAttribute "title"
			title.setAttribute("style", @titleStyle)
			
			###
			Little trick to get the offsetHeight
			Quickly add and remove title
			###
			title.style.visibility = "hidden"
			document.body.appendChild title
			height += title.offsetHeight
			document.body.removeChild title
		
		# Figure out where our element is based on its thumbnail
		thumb = element.firstChild
		position = getPosition thumb
		posX = position.x - (width - thumb.offsetWidth)/2
		posY = position.y - (height - thumb.offsetHeight)/2
		
		# Create DOM image
		big = document.createElement "img"
		big.className = "image"
		big.setAttribute "src", fullURL
		
		# Add styles to DOM image
		big.style.webkitTransition = "-webkit-transform 0.3s"
		big.style.display = "block" # For more accurate placement
		
		# Create wrapping div
		wrap = document.createElement "div"
		wrap.className = "wrap"
		wrap.appendChild big
		if element.getAttribute "title"
			wrap.appendChild title
		
		# Add styles to wrapping div
		wrap.style.webkitTransition = "-webkit-transform 0.3s, opacity 0.25s, box-shadow 0.2s"
		wrap.style.position = "absolute"
		wrap.style.left = "0"
		wrap.style.top = "0"
		
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
			if window.verbose then console.log finalTranslateString
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
				wrap.style.boxShadow = @boxShadow
				
				# Show title
				if element.getAttribute "title"
					title.style.visibility = "visible"
				
				# Add close listeners
				document.body.addEventListener "click", @checkClicked, false
				wrap.addEventListener "click", (e) =>
					e.preventDefault()
					@close()
				document.body.addEventListener "keyup", @checkKey, false
			, @TRANSITION_DURATION
		, 0
	
	# Close it	
	close: ->
		# Remove click listener
		document.body.removeEventListener "click", @checkClicked, false
		document.body.removeEventListener "keyup", @checkKey, false
		
		@opened = false
		
		closeDelay = 50
		newTransitionDuration = closeDelay + @TRANSITION_DURATION
		
		# Remove styles, shrink, and delete wrap
		wrap = document.getElementsByClassName("wrap")[0]
		wrap.style.boxShadow = "none"
		window.setTimeout =>
			wrap.style.webkitTransform = @translateString
			wrap.style.opacity = "0"
			wrap.firstChild.style.webkitTransform = @scaleString
		, closeDelay
		
		# This throws an error sometimes, but I am not sure how to fix
		window.setTimeout =>
			try	
				@container.removeChild wrap			
			catch error
				if window.verbose then console.log error
		, newTransitionDuration

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