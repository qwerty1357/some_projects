#include "metrics.h"
#include "utils.h"



void print_current_centroids(float *current_centroids, int k) {
    int i, j;
    printf("------------------------new_centroids------------------------------------A\n");
    for (i = 0; i < k; i++) {
        for (j = i * DIM; j < i * DIM + DIM; j++) {
            printf("%f ", current_centroids[j]);
        }
        printf(" | ");
    }
    printf("\n");
    printf("-------------------------------------------------------------------------B\n\n\n");
}



FILE* get_fd(int rank) {
    FILE *input;
    char filename[4];

    sprintf(filename, "%d", rank);
    input = fopen(filename, "r");
    if (input == NULL) {
        fprintf(stderr, "Ops, something wrong with file (Doesn't exist?) (%s)\n", filename);
        exit(2);
    }
    return input;
}



void reading_init_centroids(float *current_centroids, int k) {
    FILE *input;
    int i;
    input = fopen("0.in", "r");
    if (input == NULL) {
        fprintf(stderr, "Ops, something wrong with file (Doesn't exist?).\n");
        exit(2);
    }
    for (i = 0; i < DIM * k; i++) {
        fscanf(input, "%f\n", &current_centroids[i]);
    }
}



float count_norm(float *old, float *new, int k) {
    //float dist =0.0;
    //int i;
    return 1;
}



int assign_user_to_cluster(float *current_centroids, float *coords, int k, float *sum_of_distances_in_cluster) {
    int best = 0, i, j;
    float best_dist, tmp_dist, tmp_coords[DIM];

    best_dist = distance(coords, 0, current_centroids);
    for (j = 0; j < DIM; j++) {
        tmp_coords[j] = coords[j];
    }

    for (i = DIM; i < k * DIM; i += DIM) {
        tmp_dist = distance(coords, i / DIM, current_centroids);
        if (tmp_dist < best_dist) {
            best = i / DIM;
            best_dist = tmp_dist;
            for (j = 0; j < DIM; j++) {
                tmp_coords[j] = coords[j];
            }
        }
    }

    for (i = 0; i < DIM; i++) {
        sum_of_distances_in_cluster[best * DIM + i] += tmp_coords[i];
    }
    return best;
}



void set_new_clusters(float* current_centroids, float *global_sum_dist, int *global_sum_users, int k) {
    int i, j;
    for (i = 0; i < k; i++) {
        for (j = 0; j < DIM; j++) {
            if (global_sum_users[i] != 0) {
                current_centroids[i * DIM + j] = global_sum_dist[i * DIM + j] / global_sum_users[i];
            }
        }
    }
}



int get_best_cluster(float *current_centroids, float *coords, int k){
    int best = 0, i, j;
    float best_dist, tmp_dist, tmp_coords[DIM];

    best_dist = distance(coords, 0, current_centroids);
    for (j = 0; j < DIM; j++) {
        tmp_coords[j] = coords[j];
    }

    for (i = DIM; i < k * DIM; i += DIM) {
        tmp_dist = distance(coords, i / DIM, current_centroids);
        if (tmp_dist < best_dist) {
            best = i / DIM;
            best_dist = tmp_dist;
            for (j = 0; j < DIM; j++) {
                tmp_coords[j] = coords[j];
            }
        }
    }
    return best;
}



void read_and_preprocess_data(float *current_centroids, int k, int rank, float *sum_of_distances_in_cluster, int* number_of_users_in_cluster) {
    FILE *input;
    size_t len = 0;
    int best_cluster, i, read;
    char *line = NULL, *token;
    char delimit[] = " \t\r\n\v\f";

    float *coords;
    coords = malloc(DIM * sizeof(float));

    input = get_fd(rank);

    while ((read = getline(&line, &len, input)) != -1) {

        token = strtok(line, delimit);
        for (i = 0; i < DIM; i++) {
            coords[i] = atoi(strtok(NULL, delimit));
        }

        best_cluster = assign_user_to_cluster(current_centroids, coords, k, sum_of_distances_in_cluster);

        number_of_users_in_cluster[best_cluster]++;
    }

    free(coords);
}



void print_users_assigned_to_clusters(float *current_centroids, int k, int rank) {
    FILE *input;
    size_t len = 0;
    int best_cluster, i, read;
    char *line = NULL, *token;
    char delimit[]=" \t\r\n\v\f";
    float *coords;
    coords = malloc(DIM * sizeof(float));

    input = get_fd(rank);

    while ((read = getline(&line, &len, input)) != -1) {

        token = strtok(line, delimit);
        for (i = 0; i < DIM; i++) {
            coords[i] = atoi(strtok(NULL, delimit));
        }

        printf("%s ", token);
        for (i = 0; i < DIM; i++) {
            printf("%f ", coords[i]);
        }
        best_cluster = get_best_cluster(current_centroids, coords, k);
        printf("%d\n", best_cluster);
    }

    free(coords);
}
