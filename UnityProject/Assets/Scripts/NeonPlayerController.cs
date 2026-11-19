using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class NeonPlayerController : MonoBehaviour
{
    [Header("Movement")]
    public float walkSpeed = 4.8f;
    public float sprintSpeed = 7.2f;
    public float turnSharpness = 14f;
    public float gravity = -22f;
    public Transform cameraTransform;
    CharacterController motor;
    Vector3 verticalVelocity;
    Vector2 mobileMove;
    bool sprint;
    bool jumpRequested;

    void Awake() { motor = GetComponent<CharacterController>(); }
    public void SetMobileMove(Vector2 value) { mobileMove = Vector2.ClampMagnitude(value, 1f); }
    public void SetSprint(bool value) { sprint = value; }
    public void RequestJump() { jumpRequested = true; }

    void Update()
    {
        Vector2 input = mobileMove;
#if ENABLE_LEGACY_INPUT_MANAGER
        if (input.sqrMagnitude < .01f)
            input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
        sprint |= Input.GetKey(KeyCode.LeftShift);
        if (Input.GetButtonDown("Jump")) jumpRequested = true;
#endif
        Vector3 forward = cameraTransform ? Vector3.ProjectOnPlane(cameraTransform.forward, Vector3.up).normalized : Vector3.forward;
        Vector3 right = cameraTransform ? Vector3.ProjectOnPlane(cameraTransform.right, Vector3.up).normalized : Vector3.right;
        Vector3 direction = Vector3.ClampMagnitude(forward * input.y + right * input.x, 1f);
        if (direction.sqrMagnitude > .001f)
        {
            Quaternion target = Quaternion.LookRotation(direction, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, target, turnSharpness * Time.deltaTime);
        }
        float speed = sprint ? sprintSpeed : walkSpeed;
        motor.Move(direction * speed * Time.deltaTime);
        if (motor.isGrounded && verticalVelocity.y < 0) verticalVelocity.y = -2f;
        if (jumpRequested && motor.isGrounded) verticalVelocity.y = 7.2f;
        jumpRequested = false;
        verticalVelocity.y += gravity * Time.deltaTime;
        motor.Move(verticalVelocity * Time.deltaTime);
        sprint = false;
    }
}