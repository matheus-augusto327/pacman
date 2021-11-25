extends AnimatedSprite

onready var tilemap = get_parent().get_node("TileMap")
onready var pacman = get_node("../Pacman")

export var iniposdisc = Vector2()
export var color = ""
export var points = 0

var posdisc
var destdisc
var destcont

var speed

var state
enum {NORMAL, BLUE, DEAD}

var path

var bluedir

func _ready():
	spawn()
	set_process(true)

func spawn():
	posdisc = iniposdisc
	destdisc = posdisc
	
	set_pos(posdisc * 32 + Vector2(16, 16))
	destcont = get_pos()
	
	speed = 140
	
	set_animation(color)
	
	state = NORMAL
	
	path = []
	
	bluedir = Vector2(0, -1)
	

func _process(delta):
	if state == DEAD or get_node("../../Hud").score < points: return
	
	var delcont = destcont - get_pos()
	if delcont != Vector2(0, 0):
		if delcont.length() < 2:
			set_pos(destdisc * 32 + Vector2(16, 16))
			posdisc = destdisc
			
			calc_move()
		else:
			set_pos(get_pos() + delta * speed * delcont.normalized())
	else:
		go_to_next()

func calc_move():
	if state == NORMAL:
		calc_move_normal()
	elif state == BLUE:
		calc_move_blue()

func go_to_next():
	if path == null or path.size() == 0:
		return
		
	destdisc = path[0]
	destcont = destdisc * 32 + Vector2(16, 16)
	
	path.remove(0)
	
func calc_move_blue():
	path = []
	
	var aux = bluedir
	
	while(true):
		var calcdest = destdisc + aux
		
		if aux + bluedir != Vector2(0, 0) and tilemap.get_cell(calcdest.x, calcdest.y) != 0:
			bluedir = aux
			path.append(calcdest)
			return 
		else:
			randomize()
			var rand = int(rand_range(0, 4))
			if rand == 0:
				aux = Vector2(0, 1)
			elif rand == 1:
				aux = Vector2(0, -1)
			elif rand == 2:
				aux = Vector2(1, 0)
			elif rand == 3:
				aux = Vector2(-1, 0)

func respawn():
	get_node("SpecTimer").stop()
	
	state = DEAD
	
	get_node("Anim").play("Respawn")

func _on_Pacman_pac(mode):
	if mode == "die":
		speed = 0
		get_node("SpecTimer").stop()
		get_node("Anim").play("Hide")
		
	elif mode == "spec":
		if get_node("../../Hud").score < points: return
		
		if state == BLUE:
			get_node("SpecTimer").stop()
			get_node("Anim").stop()
			set_modulate(Color(1, 1, 1, 1))
		
		state = BLUE
		speed = 70
		get_node("SpecTimer").start()
		set_animation("spec")
		
	elif mode == "move":
		if destcont - get_pos() == Vector2(0, 0):
			calc_move()
	elif mode == "reset":
		get_node("Anim").stop()
		set_modulate(Color(1, 1, 1, 1))
		spawn()
		

func _on_SpecTimer_timeout():
	get_node("Anim").play("GoToNormal")
	yield(get_node("Anim"), "finished")
	
	state = NORMAL
	speed = 140
	set_color()

func set_color():
	set_animation(color)