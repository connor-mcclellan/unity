using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseLook : MonoBehaviour
{

    public float mouseSensitivity = 100f;
    public Transform playerBody;
    public Transform bothArms;
    public Transform rightArm;
    float xRotation = 0f;

    public float attackSpeed = 0.001f;
    bool isAttacking;
    bool strikeTrigger;
//    float smoothedRotation;
    public float rotationTarget = 0f;
    public float smoothedRotation;
    float mouseX;
    float mouseY;

    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        isAttacking = false;
        strikeTrigger = false;
    }

    // Update is called once per frame
    void Update()
    {
        mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        transform.localRotation = Quaternion.Euler(xRotation, mouseY, 0f);
        playerBody.Rotate(Vector3.up * mouseX);
        rightArm.Rotate(Vector3.up * mouseY * 2f);
    }

}
