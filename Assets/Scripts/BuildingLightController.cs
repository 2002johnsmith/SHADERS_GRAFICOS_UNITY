using System.Collections.Generic;
using UnityEngine;

public class BuildingLightController : MonoBehaviour
{
    [Header("Renderers del edificio (ventanas)")]
    public List<Renderer> windowRenderers = new List<Renderer>();

    [Header("Configuración de emisión")]
    public Color emissionNightColor = new Color(1f, 0.85f, 0.6f); // Color cálido
    public float emissionIntensity = 2f;

    [Header("Estado del Día")]
    public bool isNight = false; // Cambiar desde otro script (día/noche)

    // Lista interna de materiales instanciados
    private List<Material> materials = new List<Material>();


    void Start()
    {
        CacheMaterials();
        UpdateEmissionState();
    }

    void Update()
    {
        // Si otro sistema cambia isNight en tiempo real,
        // actualizamos las ventanas automáticamente.
        UpdateEmissionState();
    }

    void CacheMaterials()
    {
        materials.Clear();

        foreach (var r in windowRenderers)
        {
            if (r == null) continue;

            // Crear copia del material
            Material mat = new Material(r.sharedMaterial);
            r.material = mat;

            materials.Add(mat);
        }
    }

    void UpdateEmissionState()
    {
        foreach (var mat in materials)
        {
            if (mat == null) continue;

            if (isNight)
            {
                // Activar la palabra clave de emisión
                mat.EnableKeyword("_EMISSION");

                // Color final (color * intensidad)
                Color finalEmission = emissionNightColor * emissionIntensity;

                // Asignar color de emisión
                if (mat.HasProperty("_EmissionColor"))
                    mat.SetColor("_EmissionColor", finalEmission);
            }
            else
            {
                // Desactivar emisión
                mat.DisableKeyword("_EMISSION");

                if (mat.HasProperty("_EmissionColor"))
                    mat.SetColor("_EmissionColor", Color.black);
            }
        }
    }
    public void SetNight(bool night)
    {
        isNight = night;
        UpdateEmissionState();
    }
}
