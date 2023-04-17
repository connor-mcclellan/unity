using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubeFloat : MonoBehaviour
{
    public float floatFrequency = 3.0f;
    public float floatAmplitude = 1.5f;
    private Vector3 startPosition;

    // Start is called before the first frame update
    void Start()
    {
        startPosition = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = startPosition + new Vector3(0.0f, floatAmplitude * Mathf.Sin(floatFrequency * Time.time), 0.0f);
    }
}
