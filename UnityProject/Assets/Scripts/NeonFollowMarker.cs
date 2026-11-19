using UnityEngine;

public class NeonFollowMarker : MonoBehaviour
{
    public Transform target;
    public float height=2.2f;
    public float spin=65f;
    void Update()
    {
        transform.Rotate(Vector3.up,spin*Time.deltaTime,Space.World);
        if(target)transform.position=target.position+Vector3.up*height;
    }
}