extends Node2D

@onready var label = $Label

func setup(amount_text: String, is_crit: bool = false, is_heal:bool = false):
	label.text = amount_text
	
	if is_heal:
		label.text = "+" + amount_text
		label.modulate = Color.GREEN
	if is_crit:
		label.modulate = Color.RED
		label.scale = Vector2(1.5, 1.5)
	
	# Tween ile yukarı süzülme ve kaybolma efekti
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -50), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func setup_dot(amount_text: String, color: Color):
	$Label.text = amount_text
	$Label.modulate = color
	$Label.scale = Vector2(1.1, 1.1)
	
	#konfeti gibi random bir şekilde fırlayacak bir komut
	var direction = 1.0 if randf() > 0.5 else -1.0
	var horizontal_spread = randf_range(20.0, 40.0) * direction
	#arkın tepe noktası
	var arc_peak_height = randf_range(-50.0, -70.0)
	var duration = randf_range(1.0, 1.4)
	
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + horizontal_spread, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var vertical_tween = create_tween().set_parallel(false)
	
	vertical_tween.tween_property(self, "position:y", position.y + arc_peak_height, duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	vertical_tween.tween_property(self, "position:y", position.y + (arc_peak_height * -1.5), duration * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration * 0.8).set_delay(duration * 0.2).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
	
	
	
	
