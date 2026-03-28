extends Control



func _on_button_pressed() -> void:
	SaveManager.save_game()


func _on_load_btn_pressed() -> void:
	SaveManager.load_game()


func _on_button_2_pressed() -> void:
	SaveManager.hard_reset()
