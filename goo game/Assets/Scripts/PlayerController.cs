using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// todo: mass more accurately tracked based on volume, pushing objects that are too big to eat

public class PlayerController : MonoBehaviour
{   
    public float accel = 5f;
    public float damping = 0.05f;
    public float maxVelocity = 5f;
    public Vector3 velocity;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 input = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
        Vector3 direction = input.normalized;
        velocity += direction * accel * Time.deltaTime;
        if (velocity.magnitude >= maxVelocity) {
            velocity = velocity.normalized * maxVelocity;
        }
        transform.Translate(velocity * Time.deltaTime);

        if (Input.GetButtonDown("Fire1")) { // Disgorge
            for (int i=1; i<transform.childCount; i++) {
                // Generate a random disgorgement velocity
                float disgorgeSpeed = 3f + (Random.value * 2f);
                float disgorgeTheta = 10f + (Random.value * 15f) * Mathf.Deg2Rad;
                float disgorgePhi = Random.value * 360f * Mathf.Deg2Rad;
                Vector3 disgorgeVector = new Vector3(
                        Mathf.Cos(disgorgePhi)*Mathf.Sin(disgorgeTheta),
                        -Mathf.Cos(disgorgeTheta),
                        Mathf.Sin(disgorgePhi)*Mathf.Sin(disgorgeTheta)
                    );
                // Apply disgorgement velocity to child
                GameObject child = transform.GetChild(i).gameObject;
                Rigidbody rb = child.GetComponent<Rigidbody>();
                rb.velocity = disgorgeVector.normalized * disgorgeSpeed;
                child.transform.parent = null;
            }
        }

        if (Input.GetButton("Fire2")) // Digest
        {
            GameObject playerObject = transform.GetChild(0).gameObject;
            PlayerModel playerModel = playerObject.GetComponent<PlayerModel>();
            playerModel.Bob(20f);
            for (int i=0; i<transform.childCount; i++)
            {
                GameObject child = transform.GetChild(i).gameObject;
                if (child.tag == "Edible") {
                    CoinController childController = child.GetComponent<CoinController>();
                    print(childController.mass);
                    if (childController.mass >= 0f) {
                        childController.mass -= 1f * Time.deltaTime;
                        playerModel.mass += 1f * Time.deltaTime;
                    } else {
                        Destroy(child);
                    }
                }

            }
        }
    }

    void FixedUpdate()
    {
        if (velocity.magnitude >= damping) {
            velocity -= velocity.normalized * damping;
        }
    }
}
