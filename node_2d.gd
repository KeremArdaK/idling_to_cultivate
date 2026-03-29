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
	
	var tween = create_tween()
	# Sayı biraz daha yavaş ve süzülerek yukarı çıksın
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)
