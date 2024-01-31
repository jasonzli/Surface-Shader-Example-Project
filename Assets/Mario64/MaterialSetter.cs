using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSetter : MonoBehaviour
{
    [SerializeField] private List<Material> materialsToSet;

    void Start()
    {
        foreach (Material mat in materialsToSet)
        {
            mat.SetVector("_FlagPivot",transform.position);
        }
    }
}
