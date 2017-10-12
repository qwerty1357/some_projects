#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#include "err.h"

#define BUFFER_SIZE 1000

int main(int argc, char *argv[]) {
  int sock;
  struct addrinfo addr_hints;
  struct addrinfo *addr_result;

  int i, sflags, err;
  size_t len;
  ssize_t snd_len;
  struct sockaddr_in my_address;
  socklen_t rcva_len;

  if (argc < 3) {
    fatal("Usage: %s host port message ...\n", argv[0]);
  }

  // 'converting' host/port in string to struct addrinfo
  (void) memset(&addr_hints, 0, sizeof(struct addrinfo));
  addr_hints.ai_family = AF_INET; // IPv4
  addr_hints.ai_socktype = SOCK_DGRAM;
  addr_hints.ai_protocol = IPPROTO_UDP;
  addr_hints.ai_flags = 0;
  addr_hints.ai_addrlen = 0;
  addr_hints.ai_addr = NULL;
  addr_hints.ai_canonname = NULL;
  addr_hints.ai_next = NULL;
  err = getaddrinfo(argv[1], NULL, &addr_hints, &addr_result);
  if (err == EAI_SYSTEM) { // system error
    syserr("getaddrinfo: %s", gai_strerror(err));
  }
  else if (err != 0) { // other error (host not found, etc.)
    fatal("getaddrinfo: %s", gai_strerror(err));
  }

  my_address.sin_family = AF_INET; // IPv4
  my_address.sin_addr.s_addr =
      ((struct sockaddr_in*) (addr_result->ai_addr))->sin_addr.s_addr; // address IP
  my_address.sin_port = htons((uint16_t) atoi(argv[2])); // port from the command line

  freeaddrinfo(addr_result);

  sock = socket(PF_INET, SOCK_DGRAM, 0);
  if (sock < 0)
    syserr("socket");

  for (i = 3; i < argc; i++) {
    len = strnlen(argv[i], BUFFER_SIZE);
    if (len == BUFFER_SIZE) {
      (void) fprintf(stderr, "ignoring long parameter %d\n", i);
      continue;
    }
    (void) printf("sending to socket: %s\n", argv[i]);
    sflags = 0;
    rcva_len = (socklen_t) sizeof(my_address);
    snd_len = sendto(sock, argv[i], len, sflags,
        (struct sockaddr *) &my_address, rcva_len);

    if (snd_len != (ssize_t) len) {
      syserr("partial / failed write");
    }

    char buffer[100];
    if (strncmp(argv[i], "TITLE", 5) == 0) {
        snd_len = recvfrom(sock, buffer, sizeof(buffer), sflags,
            (struct sockaddr *) &my_address, &rcva_len);
            printf("%s\n", buffer);
    }


  }

  if (close(sock) == -1) { //very rare errors can occur here, but then
    syserr("close"); //it's healthy to do the check
  }

  return 0;
}
