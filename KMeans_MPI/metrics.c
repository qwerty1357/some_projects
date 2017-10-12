#include "metrics.h"



float distance(float *coords, int cluster, float *current_centroids) {
    return distance_users(coords, current_centroids + cluster * DIM);
}

float distance_users(float *coords1, float *coords2) {
    float dist = 0.0, temp;
    int i;
    for (i = 0; i < DIM; i++) {
        temp = fabs(coords1[i] - coords2[i]);
        dist += temp * temp;
    }
    return dist;
}
