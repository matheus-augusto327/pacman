extends AnimatedSprite

onready var tiles = get_parent().get_node("TileMap")

var posdisc

var dir
var destdisc
var destcont

var speed

var dead

signal pac

func _ready():
	spawn()
	
	set_process(true)
	
func spawn():
	posdisc = Vector2(9, 15)
	set_pos(posdisc * 32 + Vector2(16, 16))
	
	dir = Vector2(0, 0)
	destdisc = posdisc
	destcont = get_pos()
	
	speed = 150
	
	dead = false
	
	set_scale(Vector2(0.4, 0.4))
	set_flip_h(false)
	set_rotd(0)

func _process(delta):
	if dead: return
	var delcont = destcont - get_pos()
	if delcont != Vector2(0, 0):
		if delcont.length() < 2:
			set_pos(destdisc * 32 + Vector2(16, 16))
			posdisc = destdisc
			
			if tiles.get_cell(posdisc.x, posdisc.y) == 1:
				tiles.set_cell(posdisc.x, posdisc.y, -1)
				get_node("../../Hud").add_score(10)
				
			if tiles.get_cell(posdisc.x, posdisc.y) == 2:
				tiles.set_cell(posdisc.x, posdisc.y,-1)
				get_node("../../Hud").add_score(50)
				emit_signal("pac", "spec")
		else:
			set_pos(get_pos() + delta * speed * delcont.normalized())
	else:
		if dir != Vector2(0, 0):
			var destdiscaux = posdisc + dir
			if destdiscaux == Vector2(19, 9):
				destdiscaux = Vector2(0, 9)
				set_pos(Vector2(-1, 9) * 32 + Vector2(16, 16))
			elif destdiscaux == Vector2(-1, 9):
				destdiscaux = Vector2(18, 9)
				set_pos(Vector2(19, 9) * 32 + Vector2(16, 16))
			if tiles.get_cell(destdiscaux.x, destdiscaux.y) != 0 and destdiscaux != Vector2(9, 8):
				destdisc = destdiscaux
				destcont = get_pos() + 32 * dir
				emit_signal("pac","move")
	
	dir = Vector2(0, 0)
	if Input.is_action_pressed("left"):
		dir = Vector2(-1, 0)
		set_flip_h(true)
		set_rotd(0)
	elif Input.is_action_pressed("right"):
		dir = Vector2(1, 0)
		set_flip_h(false)
		set_rotd(0)
	elif Input.is_action_pressed("up"):
		dir = Vector2(0, -1)
		set_flip_h(false)
		set_rotd(90)
	elif Input.is_action_pressed("down"):
		dir = Vector2(0, 1)
		set_flip_h(false)
		set_rotd(-90)
		

func _on_Area_area_enter( area ):
	if dead: return
	if area.get_parent().state == area.get_parent().NORMAL:
		dead = true
		get_node("Anim").play("Die")
		emit_signal("pac", "die")
		get_node("../../Hud").save_high()
		yield(get_node("Anim"), "finished")
		spawn()
		emit_signal("pac", "reset")
	else:
		area.get_parent().respawn()
		get_node("../../Hud").add_score(200)





