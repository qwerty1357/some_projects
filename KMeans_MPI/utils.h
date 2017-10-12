#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "metrics.h"



/* Jeśli norma przemieści się o < 0.001, to obliczenia zostaną przerwane */
#define LOWER_LIMIT 0.001
/* Maksymalna liczba iteracji, jaką wykona algorytm */
#define MAX_ITERATIONS 100



/* [TODO] Sprawdzenie, czy nowe centroidy zmieniły położenie, aby kontynuować obbliczenia */
float count_norm(float *old, float *new, int k);


/* Przypisanie userowi kontretnego klastra, tego, którego jest najbliżej */
int assign_user_to_cluster(float *current_centroids, float *coords, int k, float *sum_of_distances_in_cluster);


/* Proces '0' czyta początkowe centroidy z pliku */
void reading_init_centroids(float *current_centroids, int k);


/* Każdy proces czyta z pliku, który jest nazwany numerem danego procesu.
   Tzn. proces któ®ego rank = 1 czyta z pliku '1',
   proces, którego rank = 2 czyta z pliku '2', itd...
   Funkcja zwraca fd dla procesu o określonym numerze */
FILE* get_fd(int rank);


/* Pomocnicza funkcja, wypisująca aktualne centroidy po każdej iteracji */
void print_current_centroids(float *current_centroids, int k);


/* Wyznaczenie nowych centroidów, po zebraniu danych od wszystkich procesów */
void set_new_clusters(float* current_centroids, float *global_sum_dist, int *global_sum_users, int k);


/* Ostateczne wypisanie userów i klastrów, do których należą */
void print_users_assigned_to_clusters(float *current_centroids, int k, int rank);


/* Każdy proces czyta dane z pliku i przyporządkowywuje usera do najbliższego klastra */
void read_and_preprocess_data(float *current_centroids, int k, int rank, float *sum_of_distances_in_cluster, int* number_of_users_in_cluster);
