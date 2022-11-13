using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainGrassSpawner : MonoBehaviour
{
    public int instanceCount = 10000;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public float instanceScale = 1.0f;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5];
    Vector4[] positions;
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

        for (int i = 0; i < instanceCount; i++)
        {
            // Generate position for the sprite
            float x = Random.Range(bounds.min.x, bounds.max.x);
            float z = Random.Range(bounds.min.z, bounds.max.z);
            float y = terrain.terrainData.GetInterpolatedHeight(x / (bounds.max.x - bounds.min.x), z / (bounds.max.z - bounds.min.z))+0.5f;
            float size = instanceScale;
            positions[i] = new Vector4(x - bounds.center.x, y-bounds.center.y, z - bounds.center.z, size);
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
