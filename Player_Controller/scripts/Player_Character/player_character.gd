extends CharacterBody3D

@onready var Camera = get_node("%Camera")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var CameraRotation = Vector2(0.0,0.0)
var MouseSensitivity = 0.001

var shake_rotation = 0 
var Start_Shake_Rotation = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * MouseSensitivity
		CameraLook(MouseEvent)

func CameraLook(Movement: Vector2):
	CameraRotation += Movement
	
	transform.basis = Basis()
	Camera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0),-CameraRotation.x) # first rotate in Y
	Camera.rotate_object_local(Vector3(1,0,0), -CameraRotation.y) # then rotate in X
	CameraRotation.y = clamp(CameraRotation.y,-1.5,1.2)

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = move_toward(velocity.x, direction.x * SPEED, SPEED)
	velocity.z = move_toward(velocity.z, direction.z * SPEED, SPEED)

	move_and_slide()

func _on_camera_camera_reset(_x_rotation, _y_rotation):
	if (abs(shake_rotation-CameraRotation.y))<.05:
		Camera.Camera_Position_Tween_To_Zero()
		var rotation_x = Start_Shake_Rotation - (CameraRotation.y - Start_Shake_Rotation)
		Start_Shake_Rotation = 0
		var _tween = get_tree().create_tween().tween_property(Camera,"rotation:x",-rotation_x,.2)
		_tween.finished.connect(ResetShake)
	else:
		var rotation_x = CameraRotation.y - _x_rotation
		var rotation_y = CameraRotation.x - _y_rotation

		Camera.rotation.x = -rotation_x
		rotation.y = -rotation_y

		Camera.Camera_Position_To_Zero()
		ResetShake()

func ResetShake():
	shake_rotation = 0
	CameraRotation.y = -Camera.get_rotation().x
	CameraRotation.x = -get_rotation().y

func _on_camera_start_shake():
	Start_Shake_Rotation = -Camera.get_rotation().x
	shake_rotation = CameraRotation.y
	
