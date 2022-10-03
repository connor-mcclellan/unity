using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinController : MonoBehaviour
{

    float mass;
    Rigidbody coinRigidBody;

    // Start is called before the first frame update
    void Start()
    {
        coinRigidBody = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        if (transform.parent != null) 
        {
            Vector3 targetDirection = (transform.parent.position - transform.position).normalized;
            transform.Translate(0.5f * targetDirection * Time.deltaTime);
        }
    }
    void OnTriggerEnter(Collider triggerCollider)
    {
        if (triggerCollider.tag == "Player")
        {
            transform.parent = triggerCollider.gameObject.transform;
        }
    }
}
