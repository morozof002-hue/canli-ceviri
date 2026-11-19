using UnityEngine;

public class NeonSaveSystem : MonoBehaviour
{
    public Transform player;
    public float saveInterval=12f;
    float timer;
    const string X="NC_PLAYER_X",Y="NC_PLAYER_Y",Z="NC_PLAYER_Z",ROT="NC_PLAYER_ROT";
    void Start()
    {
        if(!player)return;
        if(PlayerPrefs.HasKey(X))
        {
            Vector3 p=new Vector3(PlayerPrefs.GetFloat(X),PlayerPrefs.GetFloat(Y),PlayerPrefs.GetFloat(Z));
            if(p.sqrMagnitude<15000f && p.y>-5f && p.y<100f) player.position=p;
            player.eulerAngles=new Vector3(0,PlayerPrefs.GetFloat(ROT),0);
        }
    }
    void Update()
    {
        if(!player)return;
        timer+=Time.deltaTime;
        if(timer>=saveInterval){timer=0;Save();}
    }
    void OnApplicationPause(bool paused){if(paused)Save();}
    void OnApplicationQuit(){Save();}
    public void Save()
    {
        if(!player)return;
        Vector3 p=player.position;
        PlayerPrefs.SetFloat(X,p.x);PlayerPrefs.SetFloat(Y,p.y);PlayerPrefs.SetFloat(Z,p.z);PlayerPrefs.SetFloat(ROT,player.eulerAngles.y);
        PlayerPrefs.Save();
    }
}