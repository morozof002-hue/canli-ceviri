using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class NeonVehicleController : MonoBehaviour
{
    public float acceleration = 22f;
    public float reverseAcceleration = 12f;
    public float maxSpeed = 31f;
    public float steering = 92f;
    public float lateralGrip = 7f;
    public Transform cameraTarget;
    Rigidbody body;
    Vector2 mobileInput;
    bool controlled;
    public bool IsControlled => controlled;
    void Awake()
    {
        body=GetComponent<Rigidbody>();
        body.mass=1250f; body.drag=.08f; body.angularDrag=2.4f;
        body.centerOfMass=new Vector3(0,-.45f,0);
        body.interpolation=RigidbodyInterpolation.Interpolate;
        body.collisionDetectionMode=CollisionDetectionMode.Continuous;
    }
    public void SetControlled(bool value){controlled=value; if(!value)mobileInput=Vector2.zero;}
    public void SetInput(Vector2 value){mobileInput=Vector2.ClampMagnitude(value,1f);}
    void FixedUpdate()
    {
        if(!controlled) return;
        Vector2 input=mobileInput;
#if ENABLE_LEGACY_INPUT_MANAGER
        if(input.sqrMagnitude<.01f) input=new Vector2(Input.GetAxisRaw("Horizontal"),Input.GetAxisRaw("Vertical"));
#endif
        float forward=Vector3.Dot(body.velocity,transform.forward);
        if(input.y>0 && forward<maxSpeed) body.AddForce(transform.forward*input.y*acceleration,ForceMode.Acceleration);
        else if(input.y<0) body.AddForce(transform.forward*input.y*reverseAcceleration,ForceMode.Acceleration);
        float speedFactor=Mathf.Clamp01(body.velocity.magnitude/3f);
        float steer=input.x*steering*speedFactor*Time.fixedDeltaTime*Mathf.Sign(Mathf.Abs(forward)<.4f?1:forward);
        body.MoveRotation(body.rotation*Quaternion.Euler(0,steer,0));
        Vector3 local=transform.InverseTransformDirection(body.velocity);
        Vector3 grip=-transform.right*local.x*lateralGrip;
        body.AddForce(grip,ForceMode.Acceleration);
        if(body.velocity.magnitude>maxSpeed) body.velocity=body.velocity.normalized*maxSpeed;
    }
    public void SetCameraTarget(NeonOrbitCamera cam){if(cam)cam.target=cameraTarget?cameraTarget:transform;}
}