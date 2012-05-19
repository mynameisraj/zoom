# Called when page is loaded
init = ->
	if window.verbose then console.log "loaded"
	window.zoom = new Zoom "z"
	addLinkListeners()
	
# Add listeners to each link
addLinkListeners = ->
	fileTypes = [
		".jpg",
		".png",
		".gif",
		".jpeg",
		".bmp",
		".tiff",
		".webp"
	]
	
	# Run through every link on the page
	for a in document.getElementsByTagName("a")
		# Check if link contains a filetype
		for type in fileTypes
			if a.getAttribute("href").match(type)
				# See if the link has any children, and if it's an image
				if a.childNodes.length isnt 0 and a.firstChild is a.getElementsByTagName("img")[0]
					# Add the listeners (finally!)
					a.addEventListener "mouseover", cacheImage, false
					a.addEventListener "click", handleZoom, false
					
# Handles zoom on click
handleZoom = (e) ->
	e.preventDefault()
	
	# Check to see if the image is cached
	if @loaded
		window.zoom.zoom this
	else
		window.zoom.showLoadingIndicator()
		image = document.createElement "img"
		image.onload = =>
			window.zoom.cache[image.src] = image
			window.zoom.hideLoadingIndicator()
			@loaded = true
			window.zoom.zoom this
		image.src = @getAttribute "href"		
	
# Caches image
cacheImage = (e) ->
	# Create an image, set its src, you know the rest
	image = document.createElement "img"
	url = @getAttribute "href"
	image.onload = =>
		@loaded = true
		window.zoom.cache[url] = image
		@removeEventListener "mouseover", cacheImage, false
	image.src = url
	
window.addEventListener "DOMContentLoaded", init, false