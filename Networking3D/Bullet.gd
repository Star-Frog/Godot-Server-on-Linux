extends KinematicBody

export(float) var SPEED = 1500
export(float) var DAMAGE = 15

var direction = 0

func _ready():
	set_as_toplevel(true)

#func _process(delta):
#	translation.x += direction * SPEED * delta

func _on_Area_body_entered(body):
	if body.is_a_parent_of(self):
		return
	if not body.is_in_group('players'):
		return
	body.damage(DAMAGE)
	queue_free()
