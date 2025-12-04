using UnityEngine;

public class MoverObjeto : MonoBehaviour
{
    public Vector3[] posiciones;  // Array de posiciones (Vector3)
    public float velocidad = 5f;    // Velocidad de movimiento
    public float velocidadRotacion = 700f; // Velocidad de rotación

    private int indiceActual = 0;   // Índice para seguir la posición actual
    private bool rotando = false;   // Para saber si estamos rotando

    void Update()
    {
        if (posiciones.Length == 0)
            return;  // Si no hay posiciones en el array, no hace nada

        // Mueve el objeto hacia la posición actual en el array
        Vector3 objetivo = posiciones[indiceActual];

        // Rotación hacia la próxima posición
        if (rotando)
        {
            // Rotamos suavemente hacia la dirección
            Vector3 direccion = objetivo - transform.position;
            Quaternion rotacionObjetivo = Quaternion.LookRotation(direccion);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rotacionObjetivo, velocidadRotacion * Time.deltaTime);
        }

        // Mueve el objeto hacia la posición
        transform.position = Vector3.MoveTowards(transform.position, objetivo, velocidad * Time.deltaTime);

        // Si el objeto ha llegado a la posición actual, pasamos a la siguiente
        if (transform.position == objetivo)
        {
            rotando = false;  // Deja de rotar cuando llega
            indiceActual++;
            if (indiceActual >= posiciones.Length)  // Si llegó al final del array, vuelve al principio
            {
                indiceActual = 0;
            }
        }
        else
        {
            rotando = true;  // Si no ha llegado, empieza a rotar hacia el objetivo
        }
    }
}
