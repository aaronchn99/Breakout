extends TextureRect

func set_color(color: Color):
	texture.gradient.colors[0] = color

var color : Color:
	set(color):
		set_color(color)
	get:
		return texture.gradient.colors[0]
