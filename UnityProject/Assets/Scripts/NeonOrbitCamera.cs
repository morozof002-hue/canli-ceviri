using UnityEngine;

public class NeonOrbitCamera : MonoBehaviour
{
    public Transform target;
    public Vector3 offset = new Vector3(0, 2.8f, -5.8f);
    public float followSharpness = 10f;
    public float lookHeight = 1.45f;
    public float sensitivity = 0.18f;
    float yaw;
    float pitch = 12f;
    Vector2 lastPointer;
    bool dragging;

    void LateUpdate()
    {
#if ENABLE_LEGACY_INPUT_MANAGER
        if (Input.GetMouseButtonDown(0)) { lastPointer = Input.mousePosition; dragging = true; }
        if (Input.GetMouseButtonUp(0)) dragging = false;
        if (dragging && Input.GetMouseButton(0))
        {
            Vector2 now = Input.mousePosition;
            Vector2 delta = now - lastPointer;
            if (now.x > Screen.width * .35f) { yaw += delta.x * sensitivity; pitch -= delta.y * sensitivity; }
            lastPointer = now;
        }
#endif
        if (!target) return;
        pitch = Mathf.Clamp(pitch, -5f, 42f);
        Quaternion rotation = Quaternion.Euler(pitch, yaw + target.eulerAngles.y, 0);
        Vector3 desired = target.position + rotation * offset;
        transform.position = Vector3.Lerp(transform.position, desired, followSharpness * Time.deltaTime);
        transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(target.position + Vector3.up * lookHeight - transform.position), followSharpness * Time.deltaTime);
    }
}