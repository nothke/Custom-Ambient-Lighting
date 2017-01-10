using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class OcclusionHandler : MonoBehaviour
{

    public Occluder[] points;

    Vector4[] posArray = new Vector4[64];
    Vector4[] dataArray = new Vector4[64];

    private void Awake()
    {

    }

    void Update()
    {
        if (points == null) return;

        if (points.Length != 0)
        {
            for (int i = 0; i < points.Length; i++)
            {
                Vector3 p = points[i].transform.position;

                posArray[i] = new Vector3(p.x, p.y, p.z);
                dataArray[i] = new Vector3(points[i].minRadius, points[i].maxRadius, 0);
            }
        }

        // pass values to shader
        Shader.SetGlobalInt("_OcclusionPointsLength", points.Length);
        Shader.SetGlobalVectorArray("_OcclusionPositions", posArray);
        Shader.SetGlobalVectorArray("_OcclusionData", dataArray);
    }
}
