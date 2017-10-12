#include <limits.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "err.h"

#define MAX_CLIENTS 20
#define TRUE 1
#define FALSE 0
#define MAX_MESSAGE_LENGTH 1000

static int finish = FALSE;

/* take number (uint16_t) from 'user' message */
uint16_t restore_numb(char* buf) {
  uint8_t i8_1_restored = buf[0];
  uint8_t i8_2_restored = buf[1];
  uint16_t i16_restored = i8_2_restored | i8_1_restored << 8;
  return i16_restored;
}

/* signal handler */
static void catch_int(int sig) {
  finish = TRUE;
  fprintf(stderr, "Signal %d catched. No new connections will be accepted.\n",
          sig);
}

/* checking if message is correct */
char* check_data(ssize_t len, uint16_t number) {
  if (len <= MAX_MESSAGE_LENGTH) {
    if (len != number) {
      if (len < number) {
        fprintf(stderr, "wrong length of message\n");
        return "NOT OK";
      }
    }
  }
  return "OK";
}

int main(int argc, char* argv[]) {
  /* default port number */
  char* port = "20160";
  struct pollfd client[MAX_CLIENTS + 1];
  struct sockaddr_in server;
  char buf[MAX_MESSAGE_LENGTH + 2];
  ssize_t rval, wrval, to_send;
  int msgsock, activeClients, i, j, ret, tmp_port;
  uint16_t i16_restored;

  /* checking number of parameters */
  if (argc == 2) {
    tmp_port = atoi(argv[1]);
    if ((tmp_port > 65535) || (tmp_port <= 0)) {
      fprintf(stderr, "Wrong port number\n");
      exit(1);
    } else {
      port = argv[1];
    }
  } else if (argc != 1) {
    fprintf(stderr, "Too many parameters\n");
    exit(1);
  }

  /* server ends on Ctrl-C */
  if (signal(SIGINT, catch_int) == SIG_ERR) {
    perror("Unable to change signal handler");
    exit(EXIT_FAILURE);
  }

  /* Init. client table, client[0] is main socket */
  for (i = 0; i < MAX_CLIENTS + 1; ++i) {
    client[i].fd = -1;
    client[i].events = POLLIN | POLLOUT;
    client[i].revents = 0;
  }
  activeClients = 0;


  /* creating socket */
  client[0].fd = socket(PF_INET, SOCK_STREAM, 0);
  if (client[0].fd < 0) {
    perror("Opening stream socket");
    exit(EXIT_FAILURE);
  }

  /* name socket */
  server.sin_family = AF_INET;
  server.sin_addr.s_addr = htonl(INADDR_ANY);
  server.sin_port = htons(atoi(port));
  if (bind(client[0].fd, (struct sockaddr*)&server, (socklen_t)sizeof(server)) < 0) {
    perror("Binding stream socket");
    exit(EXIT_FAILURE);
  }

  if (listen(client[0].fd, 5) == -1) {
    perror("Starting to listen");
    exit(EXIT_FAILURE);
  }

  do {

    for (i = 0; i < activeClients; ++i) {
      client[i].revents = 0;
    }

    /* no new connection after Ctrl-C */
    if (finish == TRUE && client[0].fd >= 0) {
      if (close(client[0].fd) < 0) {
        perror("close");
      }
      client[0].fd = -1;
    }

    /* set timeout value 5000 ms */
    ret = poll(client, MAX_CLIENTS + 1, 5000);
    if (ret < 0) {
      perror("poll");
    } else if (ret > 0) {
      if (finish == FALSE && (client[0].revents & POLLIN)) {
        msgsock = accept(client[0].fd, (struct sockaddr*)0, (socklen_t*)0);
        if (msgsock == -1) {
          perror("accept");
        } else {
          for (i = 1; i < MAX_CLIENTS + 1; i++) {
            if (client[i].fd == -1) {
              client[i].fd = msgsock;
              activeClients += 1;
              break;
            }
          }
          if (i >= MAX_CLIENTS + 1) {
            fprintf(stderr, "Too many clients\n");
            if (close(msgsock) < 0) {
              perror("close");
            }
          }
        }
      }
      for (i = 1; i < MAX_CLIENTS + 1; i++) {
        if (client[i].fd != -1 && (client[i].revents & (POLLIN | POLLERR))) {
          memset(buf, 0, sizeof(buf));
          rval = read(client[i].fd, buf, MAX_MESSAGE_LENGTH + 2);
          i16_restored = restore_numb(buf);
          if (rval > 0) {
            /* message is correct */
            if (strcmp(check_data(rval - 2, i16_restored), "OK") == 0) {
              for (j = 1; j <= MAX_CLIENTS + 1; j++) {
                if (j != i) {
                  if (client[j].fd != -1 && (client[j].revents & (POLLOUT | POLLERR))) {
                    to_send = rval;
                    wrval = write(client[j].fd, buf, to_send);
                    if (wrval != to_send) {
                      syserr("writing on stream socket");
                    }
                  }
                }
              }
            /* message is too long or too short */
            } else {
              fprintf(stderr, "Ending connection\n");
              if (close(client[i].fd) < 0) perror("close");
              client[i].fd = -1;
              activeClients -= 1;
            }
          } else if (rval < 0) {
            perror("Reading stream message");
            if (close(client[i].fd) < 0) {
              perror("close");
            }
            client[i].fd = -1;
            activeClients -= 1;
          } else if (rval == 0) {
            fprintf(stderr, "Ending connection\n");
            if (close(client[i].fd) < 0) {
              perror("close");
            }
            client[i].fd = -1;
            activeClients -= 1;
          }
        }
      }
    }
  } while (finish == FALSE || activeClients > 0);

  if (client[0].fd >= 0) {
    if (close(client[0].fd) < 0) perror("Closing main socket");
  }

  exit(EXIT_SUCCESS);
}
