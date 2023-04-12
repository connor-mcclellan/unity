using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float rotationSpeed = 10f; // Speed of rotation
    public float smoothness = 2f; // Smoothness of motion between viewpoints
    public float maxRotation = 90f; // Maximum rotation angle between viewpoints
    public Transform pivotPoint; // Pivot point for camera rotation

    private Quaternion targetRotation; // Target rotation for smoothing
    private Vector3[] viewpoints; // Array of viewpoints
    private int currentViewpointIndex = 0; // Index of current viewpoint

    void Start()
    {
        // Initialize viewpoints array
        viewpoints = new Vector3[4];
        viewpoints[0] = transform.eulerAngles;
        viewpoints[1] = transform.eulerAngles + new Vector3(0f, 90f, 0f);
        viewpoints[2] = transform.eulerAngles + new Vector3(0f, 180f, 0f);
        viewpoints[3] = transform.eulerAngles + new Vector3(0f, 270f, 0f);

        // Set initial target rotation to current rotation
        targetRotation = transform.rotation;
    }

    void Update()
    {
        // Detect input from player
        if (Input.GetKeyDown(KeyCode.Q))
        {
            currentViewpointIndex = (currentViewpointIndex + 3) % 4; // Cycle to previous viewpoint
            targetRotation = Quaternion.Euler(viewpoints[currentViewpointIndex]); // Set target rotation to previous viewpoint
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            currentViewpointIndex = (currentViewpointIndex + 1) % 4; // Cycle to next viewpoint
            targetRotation = Quaternion.Euler(viewpoints[currentViewpointIndex]); // Set target rotation to next viewpoint
        }

        // Smoothly rotate camera towards target rotation around pivot point
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, smoothness * Time.deltaTime);
    }
}
