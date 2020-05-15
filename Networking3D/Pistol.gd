extends Spatial

var active = false
const DAMAGE = 100

const Bullet = preload("res://Bullet.tscn")

onready var raycast = get_node("../RayCast")

func _ready():
	active = true
	
func _process(_delta):
	if is_network_master():
		if Input.is_action_pressed("Shoot") and active and $Timer.is_stopped():
			rpc('_shoot')
			
func _on_Timer_timeout():
	$Timer.stop()
			
sync func _shoot():
	var bullet = Bullet.instance()
	bullet.set_translation(Vector3(5, 0, 5))
	add_child(bullet)
		
		
#			rpc('_shoot')
#sync func _shoot():
#	$AnimationPlayer.play("Shoot")
#	if raycast.is_colliding():
#		var collider = raycast.get_collider()
#		if collider.is_a_parent_of(self):
#			return
#		if not collider.is_in_group('players'):
#			return
#		if collider.has_method("remove_health"):
#			print("send")
#			collider.rpc_id(int(collider.name), 'remove_health', DAMAGE)



	
