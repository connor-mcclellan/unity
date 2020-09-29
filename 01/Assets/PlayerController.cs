using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private Rigidbody rb;
    public float speed;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        float moveForwardBackward = Input.GetAxis("Vertical");
        float moveLeftRight = Input.GetAxis("Horizontal");

        Vector3 movement = new Vector3(moveLeftRight, 0.0f, moveForwardBackward);

        // Movement in direction of camera --- potentially weaker at high camera angles
        Vector3 projectedMovement = Camera.main.transform.rotation * movement;
        Debug.Log(projectedMovement);
        rb.AddForce(speed * projectedMovement);
    }
}
