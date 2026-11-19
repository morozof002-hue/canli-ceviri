using UnityEngine;

public class NeonVehicleInteraction : MonoBehaviour
{
    public float enterDistance=3.2f;
    public NeonPlayerController player;
    public NeonOrbitCamera orbitCamera;
    NeonVehicleController current;
    CharacterController character;
    void Awake(){player=GetComponent<NeonPlayerController>();character=GetComponent<CharacterController>();if(Camera.main)orbitCamera=Camera.main.GetComponent<NeonOrbitCamera>();}
    public bool InVehicle=>current!=null;
    public void ToggleVehicle()
    {
        if(current){ExitVehicle();return;}
        NeonVehicleController[] cars=FindObjectsByType<NeonVehicleController>(FindObjectsSortMode.None);
        NeonVehicleController nearest=null;float best=enterDistance;
        foreach(var car in cars){float d=Vector3.Distance(transform.position,car.transform.position);if(d<best&&!car.IsControlled){best=d;nearest=car;}}
        if(nearest)EnterVehicle(nearest);
    }
    void EnterVehicle(NeonVehicleController car)
    {
        current=car;player.enabled=false;character.enabled=false;
        transform.SetParent(car.transform);transform.localPosition=new Vector3(0,.7f,0);
        car.SetControlled(true);if(orbitCamera)orbitCamera.target=car.cameraTarget?car.cameraTarget:car.transform;
    }
    void ExitVehicle()
    {
        Transform car=current.transform;
        transform.SetParent(null);transform.position=car.position+car.right*2.2f+Vector3.up*.2f;
        current.SetControlled(false);current=null;character.enabled=true;player.enabled=true;
        if(orbitCamera)orbitCamera.target=transform;
    }
    public void DriveInput(Vector2 value){if(current)current.SetInput(value);else if(player)player.SetMobileMove(value);}
}