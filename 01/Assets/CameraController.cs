using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target;
    public float smoothSpeed = 5f;
    public Vector3 offset;
    private float campan = 3.0f;
    public float r;
    private float camheight;
    public float sensitivity = 0.25f;

    void Update()
    {
        if (Input.GetMouseButton(0))
            {
            campan += sensitivity * -Input.GetAxis("Mouse X");
            camheight += sensitivity * -Input.GetAxis("Mouse Y");

            if (camheight < 0.0f)
            {
                camheight = 0.0f;
            }
            if (camheight > Mathf.PI/2.0f)
            {
                camheight = Mathf.PI/2.0f;
            }

            offset.x = r * Mathf.Cos(campan);
            offset.z = r * Mathf.Sin(campan);
            offset.y = r * Mathf.Sin(camheight);

            }
    }


    // Update is called once per frame
    void FixedUpdate()
    {
        Vector3 desiredPosition = target.position + offset;
        Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed*Time.deltaTime);
        transform.position = smoothedPosition;
        transform.LookAt(target);
    }
}
