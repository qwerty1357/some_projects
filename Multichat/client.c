#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <limits.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <poll.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#include "err.h"

#define MAX_MESSAGE_LENGTH 1000
#define TRUE 1
#define FALSE 0
#define STDIN 0

static int finish = FALSE;

/* signal handler */
static void catch_int(int sig) {
  finish = TRUE;
  fprintf(stderr, "Signal %d catched.\n",
          sig);
}

/* checking if message is correct:
(number of bytes (uint16_t) == length of message (in bytes)) */
char* check_data(ssize_t len, uint16_t number) {
  if (len <= MAX_MESSAGE_LENGTH) {
    if (len != number) {
      if (len < number) {
        fprintf(stderr, "wrong message length\n");
        return "NOT OK";
      }
    }
  }
  return "OK";
}

/* creating message: length (in bytes) of message + message;
   function returns buffer to send (uint16_t + message) */
char* create_statement(char* buf, ssize_t len) {
  if (len <= MAX_MESSAGE_LENGTH) {
    uint16_t i16 = htons(len);
    uint8_t i8_1 = (uint8_t) i16;
    uint8_t i8_2 = (uint8_t) (i16 >> 8);
    buf[0] = i8_1;
    buf[1] = i8_2;
  } else {
    fprintf(stderr, "message is longer than %d bytes\n", MAX_MESSAGE_LENGTH);
    exit(100);
  }
  return buf;
}

/* taking number (uint16_t) from received message */
uint16_t restore_numb(char* buf) {
  uint8_t i8_1_restored = buf[0];
  uint8_t i8_2_restored = buf[1];
  uint16_t i16_restored = i8_2_restored | i8_1_restored << 8;
  return i16_restored;
}

int main(int argc, char* argv[]) {
  int rc, sock, ret, tmp_port;
  struct addrinfo addr_hints, *addr_result;
  ssize_t rval, wrval, to_send;
  uint16_t i16_restored;
  char buf[MAX_MESSAGE_LENGTH + 2];
  /* default port number */
  char* port = "20160", *tmp;
  struct pollfd client[2];

  /* checking the number of parameters */
  if (argc == 3) {
    tmp_port = atoi(argv[2]);
    if ((tmp_port > 65535) || (tmp_port <= 0)) {
      fprintf(stderr, "Wrong port number\n");
      exit(1);
    } else {
      port = argv[2];
    }
  } else if (argc != 2) {
    fprintf(stderr, "Wrong number of parameters\n");
    exit(1);
  }

  if (signal(SIGINT, catch_int) == SIG_ERR) {
    perror("Unable to change signal handler");
    exit(EXIT_FAILURE);
  }

  /* creating the socket */
  sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (sock < 0) {
    syserr("socket");
  }

  memset(&addr_hints, 0, sizeof(struct addrinfo));
  addr_hints.ai_flags = 0;
  addr_hints.ai_family = AF_INET;
  addr_hints.ai_socktype = SOCK_STREAM;
  addr_hints.ai_protocol = IPPROTO_TCP;
  addr_hints.ai_addrlen = 0;
  addr_hints.ai_addr = NULL;
  addr_hints.ai_canonname = NULL;
  addr_hints.ai_next = NULL;

  rc = getaddrinfo(argv[1], port, &addr_hints, &addr_result);
  if (rc != 0) {
    fprintf(stderr, "Wrong parameter\n");
    exit(1);
  }

  /* connecting socket to the server */
  if (connect(sock, addr_result->ai_addr, addr_result->ai_addrlen) != 0) {
    fprintf(stderr, "Unable to connect to server\n");
    exit(1);
  }
  freeaddrinfo(addr_result);

  memset(client, 0, sizeof(client));

  /* client[0] - server; client[1] - STDIN */
  client[0].fd = sock;
  client[1].fd = STDIN;
  client[0].events = POLLIN | POLLOUT;
  client[1].events = POLLIN;

  do {

    client[0].revents = 0;
    client[1].revents = 0;

    ret = poll(client, 2, 5000);

    if (ret < 0) {
      perror("poll");
    } else if (ret > 0) {
      if (client[0].fd != -1 && (client[0].revents & (POLLIN | POLLERR))) {
        /* reading from server */
        rval = read(client[0].fd, buf, MAX_MESSAGE_LENGTH + 2);
        if (rval < 0) {
          perror("Reading stream message");
          if (close(client[0].fd) < 0) {
            perror("close");
          }
          client[0].fd = -1;
          exit(100);
        } else if (rval == 0) {
          fprintf(stderr, "Ending connection\n");
          if (close(client[0].fd) < 0) {
            perror("close");
          }
          exit(100);
        } else {
          i16_restored = restore_numb(buf);
          if (strcmp(check_data(rval - 2, i16_restored), "OK") == 0) {
            printf("%.*s\n", (int)(rval - 2), &buf[2]);
            fflush(stdout);
          } else {
            exit(100);
          }
        }
      }
      if (client[1].fd != -1 && (client[1].revents & (POLLIN | POLLERR))) {
        /* reading from stdin */
        memset(buf, 0, sizeof(buf));
        rval = read(client[1].fd, &buf[2], MAX_MESSAGE_LENGTH);
        if (rval < 0) {
          perror("Reading stream message");
          if (close(client[0].fd) < 0) {
            perror("close");
          }
          client[0].fd = -1;
        } else if (rval == 0) {
          fprintf(stderr, "Ending connection\n");
          if (close(client[0].fd) < 0) {
            perror("close");
          }
          client[1].fd = -1;
          exit(100);
          /* rval > 1 - sending only not empty messages to server */
        } else if (rval > 1 &&  client[0].fd != -1 && (client[0].revents & (POLLOUT | POLLERR))) {
          if (buf[rval + 1] == '\n') {
            rval -= 1;
          }
          tmp = create_statement(buf, rval);
          /* to_send = rval (length of message in bytes) + 2 bytes for uint16_t */
          to_send = rval + 2;
          wrval = write(client[0].fd, tmp, to_send);
          if (wrval < 0) {
            syserr("writing on stream socket");
          }
        }
      }
    }
  } while (finish == FALSE);
  if (close(sock) < 0) perror("closing stream socket");

  exit(EXIT_SUCCESS);
}
