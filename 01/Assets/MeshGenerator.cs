using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshGenerator : MonoBehaviour
{
    // Start is called before the first frame update

    Mesh mesh;

    Vector3[] vertices;
    int[] triangles;

    public int xSize = 400;
    public int zSize = 400;

    public float noiseScaleA = 0.1f;
    public float noiseScaleB = 0.001f;

    public float noiseAmpA = 2f;
    public float noiseAmpB = 10f;

    void Start()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;

        CreateShape();
        UpdateMesh();
    }

    void CreateShape()
    {
        vertices = new Vector3[(xSize+1)*(zSize+1)];

        for (int i = 0, z = 0; z <= zSize; z++)
        {
            for (int x = 0; x <= xSize; x++) 
            {
                float y = Mathf.PerlinNoise(x * noiseScaleA, z * noiseScaleA) * noiseAmpA
                          + Mathf.PerlinNoise(x * noiseScaleB, z * noiseScaleB) * noiseAmpB;
                vertices[i] = new Vector3(x, y, z);
                i++;
            }
        }
        triangles = new int[xSize * zSize * 6];

        int vert = 0;
        int tris = 0;
        for (int z=0; z<zSize; z++)
            {
            for (int x=0; x<xSize; x++)
                {
                triangles[tris + 0] = vert + 0;
                triangles[tris + 1] = vert + xSize + 1;
                triangles[tris + 2] = vert + 1;
                triangles[tris + 3] = vert + 1;
                triangles[tris + 4] = vert + xSize + 1;
                triangles[tris + 5] = vert + xSize + 2;

                vert++;
                tris += 6;
                }
            vert++;
            }
    }
    
    void UpdateMesh()
    {
        mesh.RecalculateBounds();
        MeshCollider meshCollider = gameObject.AddComponent(typeof(MeshCollider)) as MeshCollider;
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        meshCollider.sharedMesh = mesh;
    }

}
