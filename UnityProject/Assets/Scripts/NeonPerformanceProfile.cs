using UnityEngine;

public class NeonPerformanceProfile : MonoBehaviour
{
    [Range(30,60)] public int targetFps=30;
    public bool allow60FpsOnFastDevices=true;
    void Awake()
    {
        Application.targetFrameRate=targetFps;
        QualitySettings.vSyncCount=0;
        QualitySettings.antiAliasing=2;
        QualitySettings.lodBias=1.15f;
        QualitySettings.maximumLODLevel=0;
        Screen.sleepTimeout=SleepTimeout.NeverSleep;
        if(Application.isMobilePlatform && SystemInfo.systemMemorySize<4000)
        {
            QualitySettings.antiAliasing=0;
            QualitySettings.lodBias=.8f;
        }
        else if(allow60FpsOnFastDevices && SystemInfo.graphicsMemorySize>=2048)
            Application.targetFrameRate=60;
    }
}