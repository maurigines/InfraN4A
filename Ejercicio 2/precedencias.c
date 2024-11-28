#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>

#define NUM_MATERIAS 20

typedef struct {
    char *materia;
    int numPrecedencias;
    char *precedencias[2];
} Nodo;

Nodo grafo[NUM_MATERIAS] = {
    {"IP", 0, {}},
    {"M1", 0, {}},
    {"F1", 0, {}},
    {"ED", 1, {"IP"}},
    {"M2", 1, {"M1"}},
    {"F2", 1, {"F1"}},
    {"PA", 2, {"ED", "M2"}},
    {"BD", 1, {"ED"}},
    {"RC", 2, {"PA", "F2"}},
    {"SO", 2, {"PA", "RC"}},
    {"IS", 1, {"PA"}},
    {"SI", 2, {"RC", "BD"}},
    {"IA", 2, {"PA", "M2"}},
    {"CG", 2, {"F2", "PA"}},
    {"DW", 2, {"BD", "RC"}},
    {"SD", 2, {"SO", "RC"}},
    {"BG", 2, {"BD", "M2"}},  // BG es Big Data, lo cambiamos ya que BD es Base de Datos y se repetia.
    {"RO", 2, {"F2", "PA"}},
    {"CS", 2, {"SI", "SO"}},
    {"AA", 2, {"PA", "M2"}}
};

int completadas[NUM_MATERIAS] = {0};
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void *procesarMateria(void *arg) {
    Nodo *nodo = (Nodo *)arg;
    printf("Procesando %s\n", nodo->materia);
    return NULL;
}

int todasPrecedenciasCompletadas(Nodo *nodo) {
    for (int j = 0; j < nodo->numPrecedencias; j++) {
        int encontrada = 0;
        for (int k = 0; k < NUM_MATERIAS; k++) {
            if (strcmp(grafo[k].materia, nodo->precedencias[j]) == 0) {
                encontrada = 1;
                pthread_mutex_lock(&mutex);
                int completada = completadas[k];
                pthread_mutex_unlock(&mutex);
                if (completada != 1) {
                    return 0;
                }
                break;
            }
        }
               
    }
    return 1;
}

int main() {
    pthread_t threads[NUM_MATERIAS];
    int procesadas = 0;

    while (procesadas < NUM_MATERIAS) {
        int progreso = 0;

        // Crea los hilos para las materias que pueden procesarse
        for (int i = 0; i < NUM_MATERIAS; i++) {
            pthread_mutex_lock(&mutex);
            int estado = completadas[i];
            pthread_mutex_unlock(&mutex);

            if (estado == 0 && todasPrecedenciasCompletadas(&grafo[i])) {
                pthread_create(&threads[i], NULL, procesarMateria, (void *)&grafo[i]);
                pthread_mutex_lock(&mutex);
                completadas[i] = 2; 
                pthread_mutex_unlock(&mutex);
                progreso = 1;
            }
        }

        // Espera a que los hilos de esta iteración terminen
        for (int i = 0; i < NUM_MATERIAS; i++) {
            pthread_mutex_lock(&mutex);
            if (completadas[i] == 2) {
                pthread_mutex_unlock(&mutex);
                pthread_join(threads[i], NULL);
                pthread_mutex_lock(&mutex);
                completadas[i] = 1; 
                procesadas++;
                pthread_mutex_unlock(&mutex);
            } else {
                pthread_mutex_unlock(&mutex);
            }
        }

        
    }

    return 0;
}