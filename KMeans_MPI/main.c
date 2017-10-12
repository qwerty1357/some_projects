#include "utils.h"
#include "metrics.h"
#include <mpi.h>



int main(int argc, char** argv) {

    if (argc != 2) {
        fprintf(stderr, "Ops, wrong number of parameters\n");
        exit(2);
    }

    /* k - liczba klastrów, na które zostanie podzielony zbiór użytkowników */
    int k;
    k = atoi(argv[1]);

    int iter_numb = 0, i;

    int *number_of_users_in_cluster, *global_sum_users;
    number_of_users_in_cluster = malloc(k * sizeof(int));

    float *sum_of_distances_in_cluster, *current_centroids, *global_sum_dist;

    MPI_Init(NULL, NULL);

    int size;
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    sum_of_distances_in_cluster = malloc(k * DIM * sizeof(float));
    current_centroids = malloc(DIM * k * sizeof(int));


    if (rank == 0) {
        reading_init_centroids(current_centroids, k);
        global_sum_users = malloc(k * sizeof(int));
        global_sum_dist = malloc(k * DIM * sizeof(float));
    }

    while (iter_numb < MAX_ITERATIONS) {

        iter_numb++;

        /* Rozgłoszenie obecnych centroidów do wszystkich procesów */
        MPI_Bcast(current_centroids, DIM * k, MPI_FLOAT, 0, MPI_COMM_WORLD);

        if (rank == 0) {
            print_current_centroids(current_centroids, k);
        }

        for (i = 0; i < k; i++) {
            number_of_users_in_cluster[i] = 0;
        }

        for (i = 0; i < k * DIM; i++) {
            sum_of_distances_in_cluster[i] = 0;
        }

        if (rank != 0) {
            read_and_preprocess_data(current_centroids, k, rank, sum_of_distances_in_cluster, number_of_users_in_cluster);
        }

        /* Zebranie danych od wszystkich procesów. Służy do późniejszego wyznaczenia nowych centroidów. */
        MPI_Reduce(sum_of_distances_in_cluster, global_sum_dist, k * DIM, MPI_FLOAT, MPI_SUM, 0, MPI_COMM_WORLD);
        MPI_Reduce(number_of_users_in_cluster, global_sum_users, k, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

        if (rank == 0) {
            set_new_clusters(current_centroids, global_sum_dist, global_sum_users, k);
        }

    }

    if (rank == 0) {
        print_current_centroids(current_centroids, k);
    }

    /* Wypisanie userów, ich współrzędnych i klastrów, do których należą */
    MPI_Bcast(current_centroids, DIM * k, MPI_FLOAT, 0, MPI_COMM_WORLD);

    if (rank != 0) {
        print_users_assigned_to_clusters(current_centroids, k, rank);
    }


    /* Sprzatanie pamięci. */
    free(number_of_users_in_cluster);
    free(sum_of_distances_in_cluster);
    free(current_centroids);
    if (rank == 0) {
        free(global_sum_users);
        free(global_sum_dist);
    }

    MPI_Finalize();

}
