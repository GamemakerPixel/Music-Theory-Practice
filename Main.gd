extends Control



func _ready():
	MusicWriter.write_harmonic(60, MusicWriter.Scale.MINOR)

