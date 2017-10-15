#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pthread.h>
#include <string.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

#include "err.h"
#include "mesg.h"

#define MAX_TYPES_NUMBER 100
#define MAX_RESOURCES_NUMBER 9999


/* Number of types of reqources */
int K;

/* Number of each type of resources */
int N;

/* Message */
Msg rcv, snd, msg;

/* Variables to store ids to individual queues */
int request_id;
int finish_id;
int confirmation_id;

/* Array with current number of resources in each field */
int resources[MAX_TYPES_NUMBER];

/* Array with current PID number of first proces if registered,
   otherwise value in k-field is equal 0 */
int resources_PID[MAX_TYPES_NUMBER];

/* Array stores number of resources booked by first proces which is waiting
   for partner */
int resources_booking[MAX_TYPES_NUMBER];

/* Mutex for resources table */
pthread_mutex_t mutex;

/* Table of cond to protect each type of field in resources array */
pthread_cond_t types[MAX_TYPES_NUMBER];

/* Variable says if sigint was catched, if so keepRunning = 0
   otherwise keepRunning = 1 */
int keepRunning = 1;

pthread_mutex_t resources_mutex;

int threadNumber = 0;

pthread_cond_t final_cond;

pthread_attr_t th_attr;


void initialize_resources_table(int N, int K) {
    int i;

    for (i = 0; i < K; i++) {
        resources[i] = N;
        resources_PID[i] = 0;
        resources_booking[i] = 0;
    }

}


void *thread_function(void *data) {

    int type, n, m, pid1, pid2;
    pthread_t pthread_id;

    Msg tmp_msg;

    pthread_id = pthread_self();

    sscanf(data, "%d %d %d %d %d", &type, &n, &pid1, &m, &pid2);

    /* MUTEX LOCKED */
    if (pthread_mutex_lock(&resources_mutex) != 0) {
        syserr("mutex lock | first");
    }

    threadNumber++;

    while (resources[type] < n + m) {
        if (pthread_cond_wait(&types[type], &resources_mutex) != 0) {
            syserr("cond wait");
        }
    }

    resources[type] = resources[type] - n - m;

    printf("Wątek %lu przydziela %d+%d zasobów %d klientom %d %d, pozostało %d zasobów\n",
          (long)pthread_id, n, m, type + 1, pid1, pid2, resources[type]);

    if (pthread_mutex_unlock(&resources_mutex) != 0) {
        syserr("mutex unlock | first");
    }
    /* MUTEX UNLOCKED */


    tmp_msg.msg_type = pid1;
    memset(tmp_msg.data, 0, sizeof(tmp_msg.data));
    sprintf(tmp_msg.data, "%d", pid2);
    if (msgsnd(confirmation_id, &tmp_msg, strlen(tmp_msg.data), 0) != 0) {
        syserr("msgsnd | confiramtion1");
    }

    tmp_msg.msg_type = pid2;
    memset(tmp_msg.data, 0, sizeof(tmp_msg.data));
    sprintf(tmp_msg.data, "%d", pid1);
    if (msgsnd(confirmation_id, &tmp_msg, strlen(tmp_msg.data), 0) != 0) {
        syserr("msgsnd | confiramtion2");
    }

    if (msgrcv(finish_id, &tmp_msg, MAX_DATA_SIZE, pid1, 0) == -1) {
        syserr("msgrcv | finish1");
    }

    if (msgrcv(finish_id, &tmp_msg, MAX_DATA_SIZE, pid2, 0) == -1) {
        syserr("msgrcv | finish2");
    }

    /* MUTEX LOCKED */
    if (pthread_mutex_lock(&resources_mutex) != 0) {
        syserr("mutex lock | second");
    }

    resources[type] = resources[type] + n + m;

    if (pthread_cond_signal(&types[type]) != 0) {
        syserr("cond signal | types[type]");
    }

    threadNumber--;

    if (pthread_mutex_unlock(&resources_mutex) != 0) {
        syserr("mutex unlock | second");
    }
    /* MUTEX UNLOCKED */

    if (pthread_cond_signal(&final_cond) != 0) {
        syserr("signal cond | final_cond");
    }

    free(data);
    return 0;
}


void destroy_queues() {
    if (msgctl(request_id, IPC_RMID, 0) == -1)
		syserr("msgctl | request\n");

	if (msgctl(confirmation_id, IPC_RMID, 0) == -1)
		syserr("msgctl | confirmation\n");

	if (msgctl(finish_id, IPC_RMID, 0) == -1)
		syserr("msgctl | finish\n");

    if (pthread_attr_destroy(&th_attr) != 0) {
        syserr("attr destroy");
    }

    if (pthread_mutex_destroy(&resources_mutex) != 0) {
        syserr("mutex destroy");
    }

    if (pthread_cond_destroy(&final_cond) != 0) {
        syserr("cond destroy | final");
    }

    int i;
    for (i = 0; i < K; i++) {
        if (pthread_cond_destroy(&types[i]) != 0) {
            syserr("cond destroy | types[i]");
        }
    }
}


void sigHandler(int signal) {
    keepRunning = 0;
    printf("sigint caught\n");

    destroy_queues();

    exit(0);
}



int main(int argc, char* argv[]) {
    int new_k, new_n;

    if (argc != 3) {
        syserr("Wrong number of parameters");
    }

    signal(SIGINT, sigHandler);

    K = atoi(argv[1]);
    N = atoi(argv[2]);

    initialize_resources_table(N, K);

    /* Queues initialization */
    if ( (request_id = msgget(REQUEST, 0666 | IPC_CREAT | IPC_EXCL)) == -1) {
        syserr("msgget | REQUEST ");
    }

    if ( (confirmation_id = msgget(CONFIRMATION, 0666 | IPC_CREAT | IPC_EXCL)) == -1) {
        syserr("msgget | CONFIRMATION ");
    }

    if ( (finish_id = msgget(FINISH, 0666 | IPC_CREAT | IPC_EXCL)) == -1) {
        syserr("msgget | FINISH ");
    }

    /* Set up thread attr */
    if (pthread_attr_init(&th_attr) != 0) {
		syserr("attr init\n");
    }

    if (pthread_attr_setdetachstate(&th_attr, PTHREAD_CREATE_DETACHED) != 0) {
        syserr("attr setdetachstate\n");
    }

    if (pthread_mutex_init(&resources_mutex, NULL) != 0) {
        syserr("mutex init");
    }

    int j;
    for (j = 0; j < K; j++) {
        if ((pthread_cond_init(&types[j], NULL)) != 0) {
    		syserr("init types[j]\n");
        }
    }

    if ((pthread_cond_init(&final_cond, NULL)) != 0) {
		syserr("init final_cond\n");
    }

    /* The main thread of program. Catch new messages from new clients,
       create new thread for each two in pair */
    while (keepRunning && (msgrcv(request_id, &msg, MAX_DATA_SIZE, 0, 0))) {

        sscanf(msg.data, "%d %d", &new_k, &new_n);
        new_k--;

        /* If so you are first without partner, you have to wait
           else you get a partner */
        if (resources_booking[new_k] == 0) {
            resources_booking[new_k] = new_n;
            resources_PID[new_k] = msg.msg_type;
        } else {
            pthread_t th;
            char *th_data = malloc (sizeof(char) * 100);

            sprintf(th_data, "%d %d %ld %d %d", new_k, new_n, msg.msg_type, resources_booking[new_k], resources_PID[new_k]);
            resources_booking[new_k] = 0;
            resources_PID[new_k] = 0;

            if (pthread_create(&th, &th_attr, thread_function, th_data) != 0) {
                syserr("thread create\n");
            }
        }

    }

    while (threadNumber > 0) {
        if (pthread_cond_wait(&final_cond, &resources_mutex) != 0) {
            syserr("cond wait | final_cond");
        }
    }

    destroy_queues();

    exit(0);
}
