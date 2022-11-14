using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BillboardSpriteSpawner : MonoBehaviour
{
    public int instanceCount = 10000;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public Bounds bounds;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5];
    Vector4[] positions;

    // Start is called before the first frame update
    void Start()
    {
        SetArgsBuffer();
        SetLocBuffer();
    }

    // Update is called once per frame
    void Update()
    {
        Graphics.DrawMeshInstancedIndirect(instanceMesh, 0, instanceMaterial,
                                           bounds, argsBuffer);
    }

    void SetArgsBuffer()
    {
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint),
                               ComputeBufferType.IndirectArguments);
        args[0] = instanceMesh.GetIndexCount(0);
        args[1] = (uint)instanceCount;
        args[2] = instanceMesh.GetIndexStart(0);
        args[3] = instanceMesh.GetBaseVertex(0);
        argsBuffer.SetData(args);
    }

    void SetLocBuffer()
    {
        positionBuffer = new ComputeBuffer(instanceCount, 4 * sizeof(float));
        positions = new Vector4[instanceCount];

        for (int i = 0; i < instanceCount; i++)
        {
            // Generate position for the sprite
            float x = Random.Range(0.0f, 50.0f);
            float z = Random.Range(0.0f, 50.0f);
            float size = 1.0f;
            float y = 0.5f*size;
            positions[i] = new Vector4(x, y, z, size);
        }
        // Fill buffers with the data
        positionBuffer.SetData(positions);
        instanceMaterial.SetBuffer("positionBuffer", positionBuffer);
    }

    void OnDisable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;
        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = null;

    }
}
