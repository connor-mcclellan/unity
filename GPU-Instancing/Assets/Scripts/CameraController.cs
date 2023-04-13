using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform pivotPoint; // Pivot point for camera rotation

    private float targetRotation; // Target rotation for smoothing
    private float startTime = 0f;
    private Vector3 offset;

    void Start()
    {
        // Set initial target rotation to current rotation
        targetRotation = transform.rotation.eulerAngles.y;
        offset = transform.position - pivotPoint.transform.position;
    }

    void Update()
    {
        // Detect input from player
        if (Input.GetKeyDown(KeyCode.Q))
        {
            targetRotation += 90f;
            startTime = Time.time;
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            targetRotation -= 90f;
            startTime = Time.time;
        }
        if (Time.time - startTime < 2f)
        {
            transform.RotateAround(pivotPoint.transform.position, Vector3.up, targetRotation * (Time.time - startTime)/2f);
            targetRotation -= targetRotation * (Time.time - startTime)/2f;
        }
        //transform.position = offset + pivotPoint.transform.position;
    }
}
