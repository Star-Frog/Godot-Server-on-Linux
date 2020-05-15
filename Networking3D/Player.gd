extends KinematicBody

var velocity = Vector3()
var head_x_rotation = 0
var mouse_visible = false
var get_vector_from_player = self.get_rotation_degrees()

var translation_x
var translation_y
var translation_z
var translation_xyz = Vector3()

var hide = false

const MAX_HP = 50
const FOLLOW_SPEED = 4

var health_points = MAX_HP

export var speed = 10
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3

onready var body = $Body
onready var head = $Body/Head

###################### SLAVE VARIABLES ########################
puppet var slave_position = Vector3()
puppet var slave_direction = Vector3()
puppet var is_slave

##################### Back to Main-Menu ########################
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		#get_tree().change_scene("res://MainMenu/Main_Menu.tscn")
		#get_tree().quit()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
###################### Set Mouse captured ##########################
func _ready():
	$UI/ProgressBar.value = 50
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
###################### Head Movement ##########################
func _input(event):
	if event is InputEventMouseMotion:
		body.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var x_delta = event.relative.y * mouse_sensitivity
		if head_x_rotation + x_delta > -90 and head_x_rotation + x_delta < 90:
			head.rotate_x(deg2rad(-x_delta))
			head_x_rotation += x_delta

###################### Walk and Physik ##########################
func _physics_process(delta):
	if is_network_master():
		var body_basis = body.get_global_transform().basis # Body = mode_walk oder head = mode_fly
		var direction = Vector3()
		
		if Input.is_action_pressed("movement_forward"):
			direction -= body_basis.y
		elif Input.is_action_pressed("movement_backward"):
			direction += body_basis.y
			
		if Input.is_action_pressed("movement_left"):
			direction -= body_basis.x
		elif Input.is_action_pressed("movement_right"):
			direction += body_basis.x
			
		################## further physics calculation ###################
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
		velocity.y -= gravity
		
		#################### JUMP ##########################
		if Input.is_action_just_pressed("movement_jump") and is_on_floor():
			velocity.y += jump_power
			
		############## MOVE AND SLIDE ###################
		velocity = move_and_slide(velocity, Vector3.UP)
		
		############ SHARE POSITION #############

		rset_unreliable('slave_position', get_translation())
		rset_unreliable('slave_direction', get_rotation_degrees())
		
	############# Enemy #############
	else:
		set_translation(slave_position)
		set_rotation_degrees(slave_direction)
		
	############## The position will updated if a new player is joining... #############
	if get_tree().is_network_server():
		Network.update_position(int(name), slave_position, slave_direction)
		
#	############## REMOVE HEALTH ################

func _update_health_bar():
	$GUI/HealthBar.value = health_points

func damage(value):
	health_points -= value
	_update_health_bar()

func init(nickname, start_position, slave_direction, is_slave):
	if !is_slave:
		return
	print(nickname)
	set_translation(start_position)
	set_rotation_degrees(slave_direction)
