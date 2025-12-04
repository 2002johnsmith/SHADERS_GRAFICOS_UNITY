using UnityEngine;
using UnityEngine.UI;

public class TextureControl : MonoBehaviour
{
    public Material material; // Material que usa el shader
    public Slider tilingXSlider;  // Slider para controlar el Tiling en X
    public Slider tilingYSlider;  // Slider para controlar el Tiling en Y

    void Start()
    {
        // Establecer los valores iniciales de los sliders
        tilingXSlider.value = material.GetFloat("_TilingX");
        tilingYSlider.value = material.GetFloat("_TilingY");

        // Conectar los sliders con sus respectivas funciones
        tilingXSlider.onValueChanged.AddListener(UpdateMaterial);
        tilingYSlider.onValueChanged.AddListener(UpdateMaterial);
    }

    void UpdateMaterial(float value)
    {
        // Actualizar los valores de Tiling en el material
        material.SetFloat("_TilingX", tilingXSlider.value);
        material.SetFloat("_TilingY", tilingYSlider.value);
    }
}
