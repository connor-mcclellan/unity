using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinController : MonoBehaviour
{
    Rigidbody rb;
    public float mass;

    // Start is called before the first frame update
    void Start()
    {
        rb = transform.GetComponent<Rigidbody>();
        rb.mass = transform.localScale.magnitude;
        mass = rb.mass;
    }

    // Update is called once per frame
    void Update()
    {
        transform.localScale = transform.localScale * mass / rb.mass;
        rb.mass = mass;

        if (transform.parent != null) 
        {
            Vector3 target = new Vector3(0f, 0.25f, 0f); //todo make into a parameter
            Vector3 displacement = target - transform.localPosition;
            if (displacement.magnitude > 0.3f) { //todo make into a parameter
                transform.localPosition += displacement.normalized * Time.deltaTime;
            }
        }
    }
    void OnTriggerEnter(Collider triggerCollider)
    {
        if (triggerCollider.tag == "Player")
        {
            PlayerModel playerModel = triggerCollider.gameObject.GetComponent<PlayerModel>();
            print(playerModel.mass);
            print(mass);
            if (playerModel.mass > mass) {
                transform.parent = triggerCollider.gameObject.transform.parent;
            }
        }
    }
}
