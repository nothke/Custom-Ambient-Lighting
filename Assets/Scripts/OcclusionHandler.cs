using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class OcclusionHandler : MonoBehaviour
{

    public Occluder point;


    void Update()
    {


        if (point)
        {
            Vector3 p = point.transform.position;
            Vector4 v4 = new Vector4(p.x, p.y, p.z, point.maxRadius);

            // pass values to shader
            Shader.SetGlobalVector("_OcclusionPosition", v4);
            Shader.SetGlobalFloat("_OcclusionMinRadius", point.minRadius);
        }
    }
}
