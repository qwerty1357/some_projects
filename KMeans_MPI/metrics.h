#include <math.h>


/* Wymiar danych, liczba "współrzędnych", które określają usera */
#define DIM 2

/* Bardzo prosta metryka - suma kwadratów różnic odległości */
float distance(float *coords, int cluster, float *current_centroids);

float distance_users(float *coords1, float *coords2);
