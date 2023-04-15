using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour
{
    public Transform pivotPoint; // Pivot point for camera rotation

    private float targetRotation = 0f; // Target rotation for smoothing
    private float startTime = -2f;
    private Vector3 offset;

    void Start()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
        offset = transform.position - pivotPoint.transform.position;
    }

    void Update()
    {
        // Detect input from player
        if (Input.GetKeyDown(KeyCode.Q))
        {
            targetRotation += 45f;
            startTime = Time.time;
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            targetRotation -= 45f;
            startTime = Time.time;
        }
        if ((Time.time - startTime < 2f) & (Mathf.Abs(targetRotation) > 0.00001f))
        {
            transform.RotateAround(pivotPoint.transform.position, Vector3.up, targetRotation * (Time.time - startTime) / 2f);
            targetRotation -= targetRotation * (Time.time - startTime) / 2f;
        }
        else if (Mathf.Abs(targetRotation) < 0.00001f)
        {
            transform.RotateAround(pivotPoint.transform.position, Vector3.up, targetRotation);
            startTime = -2.0f;
            targetRotation = 0.0f;
        }
        //transform.position = offset + pivotPoint.transform.position;
    }
}
