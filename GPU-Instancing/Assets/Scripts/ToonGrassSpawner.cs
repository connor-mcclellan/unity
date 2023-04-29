using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToonGrassSpawner : MonoBehaviour
{
    public int instanceCount = 10000;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public float instanceScale = 1.0f;
    public float scaleVariance = 0.5f;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer normBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5];
    Vector4[] positions;
    Vector3[] norms;
    private Terrain terrain;
    private Bounds bounds;

    // Start is called before the first frame update
    void Start()
    {
        terrain = this.gameObject.GetComponent<Terrain>();
        bounds = terrain.terrainData.bounds;
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
        normBuffer = new ComputeBuffer(instanceCount, 3 * sizeof(float));
        norms = new Vector3[instanceCount];

//        for (int i = 0; i < instanceCount; i++)
        for (int i = instanceCount-1; i >= 0; i--)
        {
            // Generate position for the sprite
            float x = Random.Range(bounds.min.x, bounds.max.x);
            float normx = x / (bounds.max.x - bounds.min.x);

            float z = Random.Range(bounds.min.z, bounds.max.z);
            float normz = z / (bounds.max.z - bounds.min.z);

            float size = instanceScale + Random.Range(-scaleVariance, scaleVariance);

            float y = terrain.terrainData.GetInterpolatedHeight(normx, normz)+size*0.5f;

            positions[i] = new Vector4(x - bounds.center.x + terrain.transform.position.x, y-bounds.center.y, z - bounds.center.z + terrain.transform.position.z, size);
            norms[i] = terrain.terrainData.GetInterpolatedNormal(normx, normz);
        }
        // Fill buffers with the data
        positionBuffer.SetData(positions);
        instanceMaterial.SetBuffer("positionBuffer", positionBuffer);
        normBuffer.SetData(norms);
        instanceMaterial.SetBuffer("normBuffer", normBuffer);
    }

    void OnDisable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;
        if (normBuffer != null)
            normBuffer.Release();
        normBuffer = null;
        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = null;

    }
}
