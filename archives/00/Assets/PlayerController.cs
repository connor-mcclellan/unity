using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{


    private Rigidbody rb;
    public float speed;
    private bool brakesOn;
    public bool isGrounded;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        isGrounded = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (isGrounded)
        {
            if (Input.GetButtonDown("Jump")) 
            {
                rb.velocity = new Vector3(rb.velocity.x, 10f, rb.velocity.z);
                isGrounded = false;
            }

            float moveHorizontal = Input.GetAxis("Horizontal");
            float moveVertical = Input.GetAxis("Vertical");
            Vector3 movement = new Vector3(moveHorizontal, 0.0f, moveVertical);
            rb.AddForce(speed*movement);

            if (Input.GetButtonDown("Fire1"))
            {
                brakesOn = true;
            }
            if (Input.GetButtonUp("Fire1"))
            {
                brakesOn = false;
            }
            if (brakesOn)
            {
                rb.velocity = rb.velocity / 2.0f;
            }
        }

    }

    void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Ground"))
        {
            isGrounded = true;
        }
    }

}


