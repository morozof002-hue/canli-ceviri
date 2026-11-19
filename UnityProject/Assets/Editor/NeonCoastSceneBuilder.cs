using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

public static class NeonCoastSceneBuilder
{
    static Material matRoad, matSide, matSand, matSea, matGlass, matWhite, matWarm, matPalm, matAsphalt;
    [MenuItem("NEON COAST/Build First 3D District")]
    public static void Build()
    {
        Scene scene=EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects,NewSceneMode.Single);
        if(!AssetDatabase.IsValidFolder("Assets/Scenes")) AssetDatabase.CreateFolder("Assets","Scenes");
        RenderSettings.ambientMode=AmbientMode.Trilight;
        RenderSettings.ambientSkyColor=new Color(.42f,.55f,.68f);
        RenderSettings.ambientEquatorColor=new Color(.28f,.31f,.34f);
        RenderSettings.ambientGroundColor=new Color(.12f,.13f,.15f);
        RenderSettings.fog=true; RenderSettings.fogColor=new Color(.55f,.64f,.69f); RenderSettings.fogMode=FogMode.Linear; RenderSettings.fogStartDistance=85; RenderSettings.fogEndDistance=260;
        matRoad=Mat("Road",new Color(.095f,.11f,.13f)); matSide=Mat("Concrete",new Color(.48f,.48f,.44f)); matSand=Mat("Beach sand",new Color(.76f,.65f,.46f));
        matSea=Mat("Mediterranean water",new Color(.025f,.31f,.39f)); matGlass=Mat("Blue glass",new Color(.10f,.24f,.29f),.55f);
        matWhite=Mat("Warm white",new Color(.83f,.78f,.66f)); matWarm=Mat("Terracotta",new Color(.62f,.29f,.18f));
        matPalm=Mat("Palm green",new Color(.10f,.24f,.12f)); matAsphalt=Mat("Building cream",new Color(.69f,.61f,.48f));
        Cube("Ground",new Vector3(0,-.6f,0),new Vector3(220,1,220),matSand);
        Cube("Sea",new Vector3(0,-.3f,105),new Vector3(220,.5f,55),matSea);
        Cube("Beach",new Vector3(0,-.05f,73),new Vector3(220,.3f,13),matSand);
        Cube("Coastal promenade",new Vector3(0,.05f,61),new Vector3(220,.35f,5),matSide);
        // street grid with two main avenues
        for(int x=-90;x<=90;x+=30){Cube("Avenue",new Vector3(x,.02f,0),new Vector3(10,.22f,130),matRoad); Cube("Sidewalk",new Vector3(x+6,.12f,0),new Vector3(2,.3f,130),matSide);}
        for(int z=-60;z<=60;z+=30) Cube("Cross street",new Vector3(0,.03f,z),new Vector3(190,.22f,9),matRoad);
        // painted lane lines and crossings
        for(int x=-90;x<=90;x+=30) for(int z=-55;z<=55;z+=12) Cube("Lane dash",new Vector3(x,.145f,z),new Vector3(.22f,.025f,4),matWhite);
        for(int z=-60;z<=60;z+=30) for(int x=-84;x<=84;x+=12) Cube("Lane dash",new Vector3(x,.145f,z),new Vector3(4,.025f,.2f),matWhite);
        // architectural blocks, varied heights and facade rhythm
        for(int x=-75;x<=75;x+=30) for(int z=-48;z<=42;z+=30)
        {
            if(z>28 && Mathf.Abs(x)<46) continue;
            float h=Random.Range(13f,28f); Vector3 p=new Vector3(x+Random.Range(-3f,3f),h/2,z+Random.Range(-3f,3f));
            Material facade=Random.value>.5f?matWhite:matAsphalt;
            Cube("Coastal apartment",p,new Vector3(Random.Range(15f,20f),h,Random.Range(15f,19f)),facade);
            for(int floor=1;floor<h/3.2f;floor++) for(int wx=-1;wx<=1;wx++)
            {
                Vector3 w=p+new Vector3(wx*4.5f,-h/2+floor*3.2f,-9.55f);
                Cube("Window",w,new Vector3(2.3f,1.55f,.12f),matGlass);
                Cube("Balcony",w+new Vector3(0,-.95f,-.45f),new Vector3(2.8f,.12f,1),matSide);
            }
            Cube("Roof cap",p+Vector3.up*(h/2+.35f),new Vector3(20,.7f,19),matWarm);
        }
        // streetlights and palms along waterfront
        for(int x=-96;x<=96;x+=16){Cylinder("Palm trunk",new Vector3(x,3.2f,55),.28f,6.4f,matWarm); for(int a=0;a<6;a++){GameObject leaf=Cube("Palm frond",new Vector3(x+Mathf.Cos(a*Mathf.PI/3)*2.4f,6.2f,55+Mathf.Sin(a*Mathf.PI/3)*2.4f),new Vector3(.55f,.18f,5.2f),matPalm);leaf.transform.rotation=Quaternion.Euler(0,a*60,25);}}
        for(int x=-90;x<=90;x+=15){Cylinder("Lamp post",new Vector3(x,3,48),.09f,6,matAsphalt);Cube("Lamp head",new Vector3(x,6,48),new Vector3(.8f,.22f,.4f),matWarm);}
        // parked cars as readable low-poly vehicle silhouettes
        for(int x=-78;x<=78;x+=26){Car(new Vector3(x,.8f,42),x%2==0?matWarm:matGlass);}
        // Player capsule + controller
        GameObject player=GameObject.CreatePrimitive(PrimitiveType.Capsule);player.name="Player";player.transform.position=new Vector3(0,1.15f,25);
        Object.DestroyImmediate(player.GetComponent<Collider>());
        var cc=player.AddComponent<CharacterController>();cc.height=1.9f;cc.radius=.38f;cc.center=new Vector3(0,.95f,0);
        var controller=player.AddComponent<NeonPlayerController>();
        var camera=Camera.main;camera.name="Third Person Camera";var orbit=camera.gameObject.AddComponent<NeonOrbitCamera>();orbit.target=player.transform;controller.cameraTransform=camera.transform;
        var hud=new GameObject("Mobile HUD").AddComponent<NeonTouchHUD>();hud.player=controller;
        camera.transform.position=new Vector3(0,4,18);camera.transform.LookAt(player.transform.position+Vector3.up*1.3f);
        // sunset key light
        var sun=GameObject.Find("Directional Light");sun.transform.rotation=Quaternion.Euler(35,-28,0);sun.GetComponent<Light>().intensity=1.25f;
        EditorSceneManager.SaveScene(scene,"Assets/Scenes/NeonCoast_District01.unity");
        AssetDatabase.SaveAssets();AssetDatabase.Refresh();
        Debug.Log("NEON COAST district generated. Press Play to test. Mobile HUD and keyboard controls are included.");
    }
    static Material Mat(string n,Color c,float metallic=0){Shader s=Shader.Find("Universal Render Pipeline/Lit");if(!s)s=Shader.Find("Standard");var m=new Material(s){name=n,color=c};m.SetFloat("_Metallic",metallic);return m;}
    static void Cube(string n,Vector3 p,Vector3 scale,Material m){var g=GameObject.CreatePrimitive(PrimitiveType.Cube);g.name=n;g.transform.position=p;g.transform.localScale=scale;g.GetComponent<Renderer>().sharedMaterial=m;}
    static void Cylinder(string n,Vector3 p,float r,float h,Material m){var g=GameObject.CreatePrimitive(PrimitiveType.Cylinder);g.name=n;g.transform.position=p;g.transform.localScale=new Vector3(r*2,h/2,r*2);g.GetComponent<Renderer>().sharedMaterial=m;}
    static void Car(Vector3 p,Material paint){Cube("Parked coupe",p,new Vector3(4.2f,1.1f,2),paint);Cube("Car cabin",p+new Vector3(-.2f,.8f,0),new Vector3(2.3f,.8f,1.7f),matGlass);foreach(float x in new float[]{-1.35f,1.35f})foreach(float z in new float[]{-.95f,.95f}){var w=GameObject.CreatePrimitive(PrimitiveType.Cylinder);w.name="Wheel";w.transform.position=p+new Vector3(x,-.35f,z);w.transform.rotation=Quaternion.Euler(90,0,0);w.transform.localScale=new Vector3(.65f,.18f,.65f);w.GetComponent<Renderer>().sharedMaterial=matRoad;}}
}