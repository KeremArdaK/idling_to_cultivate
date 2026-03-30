extends CanvasLayer

@onready var panel = $PanelContainer # Kendi hiyerarşine göre yolları ayarla
@onready var title_lbl = $PanelContainer/VBoxContainer/TitleLabel
@onready var msg_lbl = $PanelContainer/VBoxContainer/MessageLabel

var active_tween: Tween

func _ready() -> void:
	panel.modulate.a = 0.0 # Başlangıçta görünmez yap
	panel.visible = false

# Herhangi bir scriptten direkt çağrılacak fonksiyon
func show_notify(title: String, message: String) -> void:
	# Eğer halihazırda çalışan bir animasyon varsa durdur (üst üste binmeyi engeller)
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	title_lbl.text = title
	msg_lbl.text = message
	panel.position.y = 50 # Başlangıç pozisyonu (Ekranın biraz üstü)
	panel.visible = true
	
	active_tween = create_tween()
	
	# Belirme animasyonu
	active_tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	active_tween.parallel().tween_property(panel, "position:y", 100, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Ekranda kalma süresi (2 saniye)
	active_tween.tween_interval(2.0)
	
	# Kaybolma animasyonu
	active_tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	active_tween.tween_callback(func(): panel.visible = false)
	
