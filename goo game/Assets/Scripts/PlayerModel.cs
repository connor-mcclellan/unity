using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerModel : MonoBehaviour
{
    public float maxBobbingAmplitude = 0.25f;
    public float mass;
    public float density = 0.5f;

    float bobbingPosition = 1f;
    float bobbingFrequency;
    float bobbingPhase;
    Vector3 originalScale;

    GameObject playerObject;
    PlayerController playerController;

    // Start is called before the first frame update
    void Start()
    {
        float meshVolume = 2f / 3f * Mathf.PI * Mathf.Pow(transform.localScale.x / 2f, 3f);
        mass = density * meshVolume;

        originalScale = transform.localScale;
        playerObject = transform.parent.gameObject;
        playerController = playerObject.GetComponent<PlayerController>();
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = playerObject.transform.position;
        float newVolume = mass / density;
        Vector3 newScale = Vector3.one * 2f * Mathf.Pow(3f/2f * newVolume / Mathf.PI, 1f / 3f);
        transform.localScale = newScale;
        //todo: update originalScale in a way that doesn't break bobbing or digesting anim
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
