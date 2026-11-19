using UnityEngine;
using UnityEngine.UI;

public class NeonMissionDirector : MonoBehaviour
{
    [System.Serializable] public class Mission
    {
        public string title="A ride along the coast";
        [TextArea] public string description="Reach the marked location.";
        public Transform target;
        public float radius=5f;
    }
    public Mission[] missions;
    public Transform player;
    public Text missionText;
    int index;
    void Start(){Refresh();}
    void Update()
    {
        if(index>=missions.Length||!player)return;
        Mission m=missions[index];if(m.target&&Vector3.Distance(player.position,m.target.position)<=m.radius){index++;Refresh();}
    }
    void Refresh()
    {
        if(missionText)missionText.text=index<missions.Length?missions[index].title+"\n"+missions[index].description:"DISTRICT EXPLORED";
    }
}