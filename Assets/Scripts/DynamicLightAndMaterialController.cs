using System.Collections.Generic;
using UnityEngine;

public class DynamicLightAndMaterialController : MonoBehaviour
{
    [Header("Render Objects")]
    public List<Renderer> renderObject = new List<Renderer>();
    public List<Material> materias = new List<Material>();

    [Header("Light Settings")]
    public Light luzDireccional;
    public AnimationCurve curvaIntensidad;
    public float intensidadMaxima = 1f;

    [Header("Time Settings")]
    public float tiempoActual = 0f;
    public float velocidadTiempo = 1f;

    void Start()
    {
        GetMaterialRender();
    }

    void Update()
    {
        tiempoActual += Time.deltaTime * velocidadTiempo;

        // Calcular intensidad de luz
        float intensity = curvaIntensidad.Evaluate(tiempoActual) * intensidadMaxima;
        luzDireccional.intensity = intensity;

        // Enviar intensidad al shader
        foreach (var item in materias)
        {
            item.SetFloat("_Intensity", Mathf.Clamp01(1 - intensity));
        }
    }

    void GetMaterialRender()
    {
        materias.Clear();

        foreach (var item in renderObject)
        {
            // Crear copia del material
            Material mat = new Material(item.sharedMaterial);

            // Asignar esta copia al Renderer
            item.material = mat;

            // Guardar en la lista
            materias.Add(mat);
        }
    }
}
