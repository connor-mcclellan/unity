using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerModel : MonoBehaviour
{
    public float maxBobbingAmplitude = 0.25f;
    public float mass;

    float bobbingPosition = 1f;
    float bobbingFrequency;
    float bobbingPhase;
    Vector3 originalScale;

    GameObject playerObject;
    PlayerController playerController;

    // Start is called before the first frame update
    void Start()
    {
        mass = transform.localScale.magnitude/2f;
        originalScale = transform.localScale;
        print(originalScale);
        playerObject = transform.parent.gameObject;
        playerController = playerObject.GetComponent<PlayerController>();
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = playerObject.transform.position;

        float oldMass = originalScale.magnitude/2f;
        originalScale *= mass / oldMass;
        transform.localScale *= mass / oldMass;
    }

    void FixedUpdate()
    {
        Bob(playerController.velocity.magnitude);
    }

    public void Bob(float speed)
    {
        float originalFrequency = bobbingFrequency;
        bobbingFrequency = Mathf.PI * speed;
        bobbingPhase += Time.time * (originalFrequency - bobbingFrequency);
        float bobbingAmplitude = Mathf.Min(speed / 4f, maxBobbingAmplitude);
        bobbingPosition = originalScale.y + bobbingAmplitude * Mathf.Sin(bobbingFrequency * Time.time + bobbingPhase);
        transform.localScale = new Vector3(originalScale.x, bobbingPosition, originalScale.z);
    }
}
