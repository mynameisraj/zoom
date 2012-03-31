# Zoom
Zoom is an easy way to zoom images on a page. It uses CSS3 transforms and transitions to get its job done.

**NOTE**: At this time, Zoom is only supported on Webkit browsers. I'm working on the others, though.

## Usage
You need to include a few basic styles to use zoom. These are found in style.css.

After including zoom.js and script.js, you can simply have linked images in the following format and Zoom will pick them up automatically:

`<a href="FULL SIZE"><img src="THUMBNAIL"></a>`

Zoom will cache the images on mouseover, and it will wait before loading the image.

If you want to use Zoom in a more customized way, though, you can.

#### Creating a new `Zoom` object
When you create a `Zoom`, the only parameter you need to specify is an ID for the container that holds it.
#### Zooming an image
Simply make the image call the function `zoom(element)` on the object you have created. `element` refers to a link with an image as its first child.
#### Caching images manually
The included file script.js will take care of this for you, but simply use the following snippet on your `Zoom` object to add to the cache (images must be cached beforehand!).

`myZoom.cache[IMAGE URL] = IMAGE OBJECT;`

## To do list:
Zoom is not perfect. I made it for me, so I can't guarantee that it will work for you. I am planning to fix the following things, however:

- Add cross-browser support
- Add titles for images
- Disable requirement for images to be cached beforehand
- Combine script.js and zoom.js into one
- Enable custom box shadow
- Auto include CSS