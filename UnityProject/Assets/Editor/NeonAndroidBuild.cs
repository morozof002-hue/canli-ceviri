using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.Build;
using UnityEngine;

public static class NeonAndroidBuild
{
    [MenuItem("NEON COAST/Configure Android Build")]
    public static void Configure()
    {
        PlayerSettings.productName="NEON COAST";
        PlayerSettings.companyName="Neon Coast Studio";
        PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.Android,"com.neoncoast.mobile");
        PlayerSettings.defaultInterfaceOrientation=UIOrientation.LandscapeLeft;
        PlayerSettings.Android.minSdkVersion=AndroidSdkVersions.AndroidApiLevel26;
        PlayerSettings.Android.targetArchitectures=AndroidArchitecture.ARM64;
        PlayerSettings.SetScriptingBackend(NamedBuildTarget.Android,ScriptingImplementation.IL2CPP);
        EditorUserBuildSettings.buildAppBundle=false;
        Debug.Log("NEON COAST Android settings configured: ARM64, IL2CPP, min API 26, landscape.");
    }

    // Entry point used by GitHub Actions. Always generate the district before building.
    public static void BuildForCI()
    {
        Configure();
        NeonCoastSceneBuilder.Build();
        Build();
    }

    [MenuItem("NEON COAST/Build Android APK")]
    public static void Build()
    {
        Configure();
        if(EditorBuildSettings.scenes.Length==0)
        {
            EditorUtility.DisplayDialog("NEON COAST","Сначала создай сцену через Build First 3D District.","OK");
            return;
        }
        string output="Build/Android/NEON-COAST.apk";
        Directory.CreateDirectory("Build/Android");
        BuildPlayerOptions options=new BuildPlayerOptions
        {
            scenes=System.Array.ConvertAll(EditorBuildSettings.scenes,s=>s.path),
            locationPathName=output,
            target=BuildTarget.Android,
            options=BuildOptions.None
        };
        BuildReport report=BuildPipeline.BuildPlayer(options);
        if(report.summary.result==BuildResult.Succeeded)
            Debug.Log("APK created: "+Path.GetFullPath(output)+" ("+report.summary.totalSize+" bytes)");
        else
            Debug.LogError("Android build failed: "+report.summary.result+"; errors="+report.summary.totalErrors);
    }
}