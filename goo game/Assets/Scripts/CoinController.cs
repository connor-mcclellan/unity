using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinController : MonoBehaviour
{
    Rigidbody rb;
    public float mass;
    public float density = 1f;
    float meshVolume;

    // Start is called before the first frame update
    void Start()
    {
        // Set rigidbody mass and mass parameter based on local scale
        // todo more accurately calculate mass based on volume of mesh

        meshVolume = Mathf.Pow(transform.localScale.x, 3f);

        rb = transform.GetComponent<Rigidbody>();
        rb.mass = density * meshVolume;
        mass = rb.mass;
    }

    // Update is called once per frame
    void Update()
    {
        // Update mass and scale if currently being digested
        // Keep density fixed, but mass may have changed. Update scale to match.
        if (mass >= 0f) {
            float newVolume = mass / density;
            Vector3 newScale = Vector3.one * Mathf.Pow(newVolume, 1f / 3f);
            transform.localScale = newScale;
            rb.mass = mass;
        }

        // Move toward center if in a stomach
        if (transform.parent != null) {
            float targetY = transform.parent.localScale.magnitude / 2f;
            Vector3 target = new Vector3(0f, targetY, 0f);

            Vector3 displacement = target - transform.localPosition;
            float stomachRadius = transform.parent.localScale.magnitude / 3f;
            if (displacement.magnitude > stomachRadius) {
                transform.localPosition += displacement.normalized
                                           * Time.deltaTime;
            }
        }
    }

    void OnTriggerEnter(Collider triggerCollider)
    {
        if (triggerCollider.tag == "Player") {
            GameObject pObject = triggerCollider.gameObject;
            PlayerModel pModel = pObject.GetComponent<PlayerModel>();
            PlayerController pCont = pObject.GetComponent<PlayerController>();
            if (pModel.mass > mass) {
                transform.parent = pObject.transform.parent;
            } //todo: else push the block away
        }
    }
}
