# Zoom
Zoom is an easy way to zoom images on a page. It uses CSS3 transforms and transitions to get its job done.

**NOTE**: At this time, Zoom is only supported on Webkit browsers. I'm working on the others, though.

## Usage
After including zoom.js and script.js, you can simply have linked images in the following format and Zoom will pick them up automatically:

`<a href="FULL SIZE"><img src="THUMBNAIL"></a>`

Zoom will cache the images on mouseover, and it will wait before loading the image.

## Advanced Usage
If you want to use Zoom in a more customized way, though, you can.

#### Creating a new `Zoom` object
When you create a `Zoom`, the only parameter you need to specify is an ID for the container that holds it. You can, however, add a second, optional parameter with the string for a `box-shadow` CSS property (just the values, not the actual property) and a third, optional parameter with the strong for all the styles to be applied to the titles.
#### Zooming an image
Simply make the image call the function `zoom(element)` on the object you have created. `element` refers to a link with an image as its first child.
#### Caching images manually
The included file script.js will take care of this for you, but simply use the following snippet on your `Zoom` object to add to the cache (images must be cached beforehand!).

`myZoom.cache[IMAGE URL] = IMAGE OBJECT;`

## To do list:
Zoom is not perfect. I made it for me, so I can't guarantee that it will work for you. I am planning to fix the following things, however:

- Add cross-browser support
- Combine script.js and zoom.js into one