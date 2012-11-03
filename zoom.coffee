window.verbose = false

class self.Zoom
	# Constructor
	constructor: (@id, @boxShadow = "0 4px 15px rgba(0, 0, 0, 0.5)", @titleStyle = "background-color: #fff; text-align: center; padding: 5px 0; font: 14px/1 Helvetica, sans-serif") ->
		# Keyboard Constants
		@ESCAPE = 27
		@SHIFT = 16

		# Transition stuff
		@TRANSITION_DURATION = 300
		@SLOW_MODE_MULTIPLIER = 3
		@BOX_SHADOW_OFFSET = 100
		@OPACITY_OFFSET = 50
		@ACTIVE_DURATION = @TRANSITION_DURATION
		@computeDurations()
		
		# Close delay (needed for choppiness fix)
		# EDIT: not needed. Keeping it anyways
		@CLOSE_DELAY = 0
		
		# Various other initializations
		@opened = false
		@cache = []
		@slowModeState = false
		
		# Create a container for whole thing
		@container = document.createElement "div"
		@container.id = @id
		document.body.appendChild(@container)
		
		# Add slow listeners
		document.body.addEventListener "keydown", @startSlowMode, false
		document.body.addEventListener "keyup", @endSlowMode, false
		
	# Computes durations for animations
	computeDurations: ->
		@TRANSFORM_DURATION = @ACTIVE_DURATION
		@BOX_SHADOW_DURATION = Math.abs(@ACTIVE_DURATION - @BOX_SHADOW_OFFSET)
		@OPACITY_DURATION = Math.abs(@ACTIVE_DURATION - @OPACITY_OFFSET)

		# If the box is opened, we need to re-assign transitions
		if @opened
			big = @container.getElementsByClassName("image")[0]
			big.style.webkitTransition = "-webkit-transform #{@TRANSFORM_DURATION}ms"
			wrap = @container.getElementsByClassName("wrap")[0]
			wrap.style.webkitTransition = "-webkit-transform #{@TRANSFORM_DURATION}ms, opacity #{@OPACITY_DURATION}ms, box-shadow #{@BOX_SHADOW_DURATION}ms"
			
	# Key listener for escape
	checkKeyClosed: (e) =>
		if e.keyCode is @ESCAPE and @opened
			e.preventDefault()
			@close()

	# Enter slow mode
	startSlowMode: (e) =>
		if e.keyCode is @SHIFT
			@ACTIVE_DURATION = @TRANSITION_DURATION * @SLOW_MODE_MULTIPLIER
			@computeDurations()
	
	# Exit slow mode
	endSlowMode: (e) =>
		if e.keyCode is @SHIFT
			@ACTIVE_DURATION = @TRANSITION_DURATION
			@computeDurations()

	# Click listener for outside box
	checkClicked: (e) =>
		if e.srcElement.className isnt "image" and @opened
			@close()
			
	# Shows the loading indicator
	showLoadingIndicator: ->
		console.log "loading indicator being shown"
		# You can fill out this function if you need a loading indicator to be displayed
	
	# Hides the loading indicator
	hideLoadingIndicator: ->
		# Here is where you hide the loading indicator that you created above
			
	# Zoom selected image
	zoom: (element, thumb) ->
		if not thumb then thumb = element.firstChild
		
		if element.loaded
			@doZoom element, thumb
		else
			# If the element isn't loaded, create it
			image = document.createElement "img"
			image.onload = =>
				@doZoom element, thumb
			image.src = if element.getAttribute "data-url" then element.getAttribute "data-url" else element.getAttribute "href"
		
	doZoom: (element, thumb) ->
		# Close the zoomed image
		if @opened
			@close()
		@opened = true
		
		# Retrieve cached image
		fullURL = if element.getAttribute "data-url" then element.getAttribute "data-url" else element.getAttribute "href"
		image = @cache[fullURL]

		# Sometimes the image didn't get put the cache
		if image is undefined
			image = document.createElement "img"
			image.setAttribute "src", fullURL
			@cache[fullURL] = image
		originalHeight = image.height
		width = image.width
		height = image.height
		if window.devicePixelRatio > 1
			width *= .5
			height *= .5
			originalHeight *= .5
		
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
		position = getPosition thumb
		posX = position.x - (width - thumb.offsetWidth)/2
		posY = position.y - (height - thumb.offsetHeight)/2
		
		# Create DOM image
		big = document.createElement "img"
		big.className = "image"
		big.setAttribute "src", fullURL
		
		# Add styles to DOM image
		big.style.webkitTransition = "-webkit-transform #{@TRANSFORM_DURATION}ms"
		big.style.display = "block" # For more accurate placement
		big.style.width = width + "px"
		big.style.height = originalHeight + "px"
		
		# Create wrapping div
		wrap = document.createElement "div"
		wrap.className = "wrap"
		wrap.appendChild big
		if element.getAttribute "title"
			wrap.appendChild title
		
		# Add styles to wrapping div
		wrap.style.webkitTransition = "-webkit-transform #{@TRANSFORM_DURATION}ms, opacity #{@OPACITY_DURATION}ms, box-shadow #{@BOX_SHADOW_DURATION}ms"
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
		wrap.style.webkitTransform = @translateString
		big.style.webkitTransform = @scaleString
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
				document.body.addEventListener "keyup", @checkKeyClosed, false
			, @ACTIVE_DURATION
			
			@hideLoadingIndicator()
		, 0
	
	# Close it
	close: ->
		# Remove click listener
		document.body.removeEventListener "click", @checkClicked, false
		document.body.removeEventListener "keyup", @checkKeyClosed, false
		
		@opened = false
		
		newTransitionDuration = @CLOSE_DELAY + @ACTIVE_DURATION
		
		# Remove styles, shrink, and delete wrap
		wrap = document.getElementsByClassName("wrap")[0]
		wrap.style.webkitTransition = wrap.style.webkitTransition.replace ", box-shadow #{@BOX_SHADOW_DURATION}ms", ""
		window.setTimeout =>
			wrap.style.boxShadow = "none"
		, 0
		
		# Close delay needed to avoid box shadow glitch
		window.setTimeout =>
			wrap.style.webkitTransform = @translateString
			wrap.style.opacity = "0"
			wrap.firstChild.style.webkitTransform = @scaleString
		, @CLOSE_DELAY
		
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