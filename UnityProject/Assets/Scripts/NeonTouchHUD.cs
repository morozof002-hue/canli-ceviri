using UnityEngine;
using UnityEngine.EventSystems;

public class NeonTouchHUD : MonoBehaviour
{
    public NeonPlayerController player;
    public NeonVehicleInteraction interaction;
    Rect stick = new Rect(28, 0, 164, 164);
    Rect sprintButton = new Rect(0, 0, 104, 62);
    Rect jumpButton = new Rect(0, 0, 92, 62);
    Rect enterButton = new Rect(0, 0, 112, 62);
    int stickFinger = -1;
    Vector2 stickCenter, stickValue;
    GUIStyle panel, button, small;
    void ApplyMove(Vector2 value) { if(interaction) interaction.DriveInput(value); else if(player) player.SetMobileMove(value); }
    void OnGUI()
    {
        float s = Mathf.Clamp(Screen.height / 760f, .78f, 1.25f);
        stick.width = stick.height = 150*s; stick.x = 26*s; stick.y = Screen.height - stick.height - 28*s;
        sprintButton.width=106*s; sprintButton.height=60*s; sprintButton.x=Screen.width-250*s; sprintButton.y=Screen.height-102*s;
        jumpButton.width=92*s; jumpButton.height=60*s; jumpButton.x=Screen.width-126*s; jumpButton.y=Screen.height-102*s;
        enterButton.width=112*s; enterButton.height=54*s; enterButton.x=Screen.width-132*s; enterButton.y=Screen.height-174*s;
        if(panel==null){ panel=new GUIStyle(GUI.skin.box){fontSize=Mathf.RoundToInt(18*s),alignment=TextAnchor.MiddleCenter}; button=new GUIStyle(GUI.skin.button){fontSize=Mathf.RoundToInt(17*s),fontStyle=FontStyle.Bold}; small=new GUIStyle(GUI.skin.label){fontSize=Mathf.RoundToInt(13*s),normal={textColor=Color.white}}; }
        GUI.Box(new Rect(18*s,18*s,190*s,54*s),"NEON COAST  /  FREE ROAM",panel);
        GUI.Label(new Rect(24*s,74*s,260*s,26*s),"Explore the coast  •  1980s",small);
        GUI.Box(stick,"");
        GUI.Label(new Rect(stick.x+26*s,stick.y+stick.height+4*s,160*s,22*s),"MOVE",small);
        if(GUI.RepeatButton(sprintButton,"SPRINT")) player.SetSprint(true);
        if(GUI.Button(jumpButton,"JUMP")) { if(interaction && interaction.InVehicle) interaction.ToggleVehicle(); else player.RequestJump(); }
        if(interaction && GUI.Button(enterButton,interaction.InVehicle?"EXIT":"ENTER")) interaction.ToggleVehicle();
        HandleStick();
    }
    void HandleStick()
    {
        Event e=Event.current;
        if(e.type==EventType.Touch)
        {
            Touch t=e.touch;
            Vector2 p=new Vector2(t.position.x,Screen.height-t.position.y);
            if(t.phase==TouchPhase.Began && stick.Contains(p)) { stickFinger=t.fingerId; stickCenter=stick.center; }
            if(t.fingerId==stickFinger)
            {
                if(t.phase==TouchPhase.Ended || t.phase==TouchPhase.Canceled){stickFinger=-1;stickValue=Vector2.zero;ApplyMove(Vector2.zero);}
                else {Vector2 d=(p-stickCenter)/(stick.width*.38f);stickValue=Vector2.ClampMagnitude(d,1);ApplyMove(stickValue);}
            }
        }
        if(e.type==EventType.MouseDown && stick.Contains(e.mousePosition)){stickCenter=stick.center;stickFinger=-2;}
        if(e.type==EventType.MouseDrag && stickFinger==-2){stickValue=Vector2.ClampMagnitude((e.mousePosition-stickCenter)/(stick.width*.38f),1);ApplyMove(stickValue);}
        if(e.type==EventType.MouseUp && stickFinger==-2){stickFinger=-1;ApplyMove(Vector2.zero);}
    }
}