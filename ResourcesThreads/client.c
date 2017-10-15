#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>

#include "err.h"
#include "mesg.h"



/* Type of resources */
int k;

/* Number of resources */
int n;

/* Time required to finish the task with resources */
int workingTime;

/* Message */
Msg rcv, snd, msg, finishMsg;

/* Variables to store ids to individual queues */
int request_id;
int finish_id;
int confirmation_id;


int main(int argc, char* argv[]) {

    if (argc != 4) {
        syserr("Wrong number of parameters");
    }


    k = atoi(argv[1]);
    n = atoi(argv[2]);
    workingTime = atoi(argv[3]);

    /* get my pid to send to server */
    pid_t myPid = getpid();
    snd.msg_type = myPid;


    sprintf(snd.data, "%d %d %d", k, n, myPid);

    if ( (request_id = msgget(REQUEST, 0)) == -1) {
        syserr("msgget | REQUEST ");
    }

    if ( (confirmation_id = msgget(CONFIRMATION, 0)) == -1) {
        syserr("msgget | CONFIRMATION ");
    }

    if ( (finish_id = msgget(FINISH, 0)) == -1) {
        syserr("msgget | FINISH ");
    }

    if (msgsnd(request_id, &snd, strlen(snd.data), 0) != 0) {
        syserr("msgsnd | request");
    }

    if (msgrcv(confirmation_id, &rcv, MAX_DATA_SIZE, myPid, 0) == -1) {
        syserr("msgsnd | confirmation");
    }

    printf("%d %d %d %s\n", k, n, myPid, rcv.data);

    sleep(workingTime);

    finishMsg.msg_type = myPid;

    sprintf(finishMsg.data, "%d KONIEC", myPid);

    printf("%s\n", finishMsg.data);

    if (msgsnd(finish_id, &finishMsg, strlen(finishMsg.data), 0) != 0) {
        syserr("msgsnd | finish");
    }


}
