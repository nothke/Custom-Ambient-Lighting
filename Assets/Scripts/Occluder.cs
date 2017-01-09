using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Occluder : MonoBehaviour
{

    public float minRadius = 5;
    public float maxRadius = 10;

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0, 0.5f, 1, 0.2f);
        Gizmos.DrawWireSphere(transform.position, minRadius);
        Gizmos.color = new Color(1, 0.3f, 0, 0.2f);
        Gizmos.DrawWireSphere(transform.position, maxRadius);
    }
}
