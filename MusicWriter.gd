extends Object
class_name MusicWriter

enum Scale {MAJOR, MINOR}

enum Cadence {P_AUTHENTIC, I_AUTHENTIC, HALF, PHRYGIAN, PLAGAL, DECEPTIVE}

enum ChordQuality {MAJOR, MINOR, DIMINISHED, DOMINANT7, MINOR7, HALF_DIMINISHED7}

class Chord:
	const NUMERALS = ["I", "II", "III", "IV", "V", "VI", "VII"]
	
	var numeral: int #Roman numeral used to represent the chord, where 1 is I, 2 is ii etc.
	var secondary_resolution: int = 0 #Numeral that the chord resolves to, for example V/V is 5
	var quality: ChordQuality
	var bass: int # -1 for not yet defined, 0 for root position, 1 for first inversion etc.
	
	@warning_ignore("shadowed_variable")
	func _init(numeral: int, quality: ChordQuality, bass: int = -1, secondary_resolution: int = 0):
		self.numeral = numeral
		self.quality = quality
		self.bass = bass
		self.secondary_resolution = secondary_resolution
	
	func _to_string(): #TODO: Implement symbols for secondary dominants
		var string: String = NUMERALS[numeral-1]
		
		match quality:
			ChordQuality.MAJOR, ChordQuality.DOMINANT7:
				string = string.to_upper()
			ChordQuality.MINOR, ChordQuality.MINOR7:
				string = string.to_lower()
			ChordQuality.DIMINISHED:
				string = string.to_lower()
				string += "-dim"
			ChordQuality.HALF_DIMINISHED7:
				string = string.to_lower()
				string += "-/dim"
		
		string += _generate_figured_bass()
		
		return string
	
	func _generate_figured_bass() -> String:
		const TRIAD = ["", "6", "6/4", "ERROR"]
		const SEVENTH = ["7", "6/5", "4/3", "4/2"]
		
		if (quality <= 2):
			return TRIAD[bass]
		else:
			return SEVENTH[bass]

static func write_harmonic(key:int = 60, scale:Scale = Scale.MAJOR, chord_count:int = 9):# -> Array[int]:
	#Initialize SATB and chord lines
	var soprano: Array[int] = []
	var alto: Array[int] = []
	var tenor: Array[int] = []
	var bass: Array[int] = []
	
	var chords: Array[Chord] = []
	
	soprano.resize(chord_count)
	alto.resize(chord_count)
	tenor.resize(chord_count)
	bass.resize(chord_count)
	
	chords.resize(chord_count)
	
	#Define starting chord
	match scale:
		Scale.MAJOR:
			chords[0] = Chord.new(1, ChordQuality.MAJOR, 0)
		Scale.MINOR:
			chords[0] = Chord.new(1, ChordQuality.MINOR, 0)
	
	#Pick a cadence
	var cadence: Cadence = randi_range(0, 4) as Cadence
	
	if (scale == Scale.MAJOR && cadence == Cadence.PHRYGIAN): cadence = Cadence.HALF #Phrygian half not in major
	
	match cadence:
		Cadence.P_AUTHENTIC: #TODO: Soprano must be tonic
			chords[chord_count-1] = Chord.new(1, _get_chord_quality(scale, 1), 0)
			chords[chord_count-2] = Chord.new(5, ChordQuality.MAJOR, 0)
		Cadence.I_AUTHENTIC:
			chords[chord_count-1] = Chord.new(1, _get_chord_quality(scale, 1))
			chords[chord_count-2] = Chord.new(5, ChordQuality.MAJOR)
		Cadence.HALF:
			chords[chord_count-1] = Chord.new(5, ChordQuality.MAJOR, 0)
		Cadence.PHRYGIAN:
			chords[chord_count-1] = Chord.new(5, ChordQuality.MAJOR, 0)
			chords[chord_count-2] = Chord.new(4, ChordQuality.MINOR, 1)
		Cadence.PLAGAL:
			chords[chord_count-1] = Chord.new(1, _get_chord_quality(scale, 1), 0)
			chords[chord_count-2] = Chord.new(4, _get_chord_quality(scale, 4), 0)
		Cadence.DECEPTIVE:
			chords[chord_count-1] = Chord.new(6, _get_chord_quality(scale, 6), 0)
			chords[chord_count-2] = Chord.new(5, ChordQuality.MAJOR, 0)
	
	for chord in chords:
		if (chord == null):
			print("X")
		else:
			print(chord)

static func _get_chord_quality(scale: Scale, numeral: int) -> ChordQuality:
	var major: Array[ChordQuality] = [	ChordQuality.MAJOR, ChordQuality.MINOR, 
										ChordQuality.MAJOR, ChordQuality.MAJOR,
										ChordQuality.MAJOR, ChordQuality.MINOR,
										ChordQuality.DIMINISHED]
	var minor: Array[ChordQuality] = [	ChordQuality.MINOR, ChordQuality.DIMINISHED,
										ChordQuality.MAJOR, ChordQuality.MINOR,
										ChordQuality.MAJOR, ChordQuality.MAJOR,
										ChordQuality.DIMINISHED]
	match scale:
		Scale.MAJOR:
			return major[numeral-1]
		Scale.MINOR:
			return minor[numeral-1]
		_:
			push_error("Invalid scale type.")
			return ChordQuality.MAJOR
