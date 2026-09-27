# GPUTrail

GPUTrail is a GPU-based trail plugin for Godot 4, offering an efficient alternative to CPU-based trails for creating ribbon trail effects in your games and applications.
![heart](https://github.com/celyk/GPUTrail/assets/50609684/a190fee3-682b-42b9-9bef-cd49a5e3b99c)

## Features

- GPU-accelerated trail rendering for improved performance
- Customizable trail length, texture, and color
- Support for color ramps and width curves
- Options for texture orientation and alpha channel handling
- Billboard mode for camera-facing trails
- Dewiggle and clip overlaps features for improved trail appearance

## Installation

1. Clone or download this repository
2. Copy the folder into your `addons/`, so that the root of this repo is located at `res://addons/GPUTrail`
3. Enable the plugin in your project settings: Project -> Project Settings -> Plugins -> GPUTrail

## Usage

1. Add a new `GPUTrail3D` node to your scene
2. Customize the trail properties in the Inspector panel
3. Attach the `GPUTrail3D` node to the object you want to trail

## Properties
- `active`: Turn on or off the trail
- `length`: Number of steps in the trail
- `texture`: Main texture of the trail
- `mask`: A texture used to modify the alpha of trail. Uses the red channel of the texture to determine what is visible.
- `mask_strength`: A float value from 0.0 to 1.0 for determing how intense the mask texture is
- `color_ramp`: Color gradient along the trail's length
- `curve`: Width modulation along the trail's length
- `vertical_texture`: Adjust texture orientation
- `use_red_as_alpha`: Use the red channel of the texture as alpha
- `alpha`: Determines the overall alpha value of the trail. Is modified if using fade in and out parameters
- `fade_curve`: Curve to control the alpha along the trail's lifetime
- `fade_curve_intensity`: Value to control the strength of the fade curve value
- `fade_in_seconds`: Value to determine how quickly the whole trail fades in if active is set from false to true
- `fade_in_alpha`: Value to determine what alpha value the whole trail fades to if active is set from false to true
- `fade_out_seconds`: Value to determine how quickly the whole trail fades out if active is set from true to false
- `fade_out_alpha`: Value to determine what alpha value the whole trail fades to if active is set from true to false
- `billboard`: Make the trail face the camera (experimental)
- `dewiggle`: Improve texture mapping to the trail
- `clip_overlaps`: Prevent trail self-intersectionis
- `snap_to_transform`: Snap the trail start to the node's position, and regardless of the particles own framerate

## Example

```gdscript
var trail = GPUTrail3D.new()
trail.length = 100
trail.texture = preload("res://trail_texture.png")
add_child(trail)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Tutorial by Le Lu: [YouTube Video](https://www.youtube.com/watch?v=0VsEfP4XFCM)

## TODO

- Add flipbook support
- Hide the actual GPUParticles3D node
- Restructure code, use enums for flags
- Add more polygons, make trail smoother
- Add an acceleration parameter
- Port to Godot 3.5
- Port to 2D
- Allow custom material
