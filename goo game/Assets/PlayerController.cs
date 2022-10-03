using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{

    public float accel = 0.05f;
    public float damping = 0.05f;
    public float maxBobbingAmplitude = 0.25f;
    public float maxVelocity = 5f;
    
    Vector3 velocity;

    float bobbingPosition = 1f;
    float bobbingFrequency;
    float bobbingPhase;
    float originalYScale;

    // Start is called before the first frame update
    void Start()
    {
        originalYScale = transform.localScale.y;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 input = new Vector3(Input.GetAxisRaw("Horizontal"),
                                    0,
                                    Input.GetAxisRaw("Vertical"));
        Vector3 direction = input.normalized;
        velocity += direction * accel * Time.deltaTime;
        if (velocity.magnitude >= maxVelocity) 
        {
            velocity = velocity.normalized * maxVelocity;
        }
        transform.Translate(velocity * Time.deltaTime);

        if (Input.GetButtonDown("Fire1")) 
        {
            for (int i=0; i<transform.childCount; i++)
            {
                GameObject child = transform.GetChild(i).gameObject;
                child.transform.Translate(0f, 5f, 0f);
            }
            transform.DetachChildren();
        }
    }

    void FixedUpdate()
    {
        if (velocity.magnitude >= damping) {
            velocity -= velocity.normalized * damping;
        }
        
        Bob(velocity.magnitude);
    }
    void Bob(float speed)
    {
        float originalFrequency = bobbingFrequency;
        bobbingFrequency = Mathf.PI * speed;
        bobbingPhase += Time.time * (originalFrequency - bobbingFrequency);
        float bobbingAmplitude = Mathf.Min(speed / 4f, maxBobbingAmplitude);
        bobbingPosition = originalYScale + bobbingAmplitude*Mathf.Sin(bobbingFrequency*Time.time + bobbingPhase);
        transform.localScale = new Vector3(1, bobbingPosition, 1);
    }

}
