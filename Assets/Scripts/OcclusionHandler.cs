using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class OcclusionHandler : MonoBehaviour
{

    public Transform point;


    void Update()
    {


        if (point)
        {
            Vector4 v4 = new Vector4(point.position.x, point.position.y, point.position.z, 10);
            Shader.SetGlobalVector("_OcclusionPosition", v4);
        }
    }
}
