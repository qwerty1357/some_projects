#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <resolv.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <poll.h>
#include <fcntl.h>
#include <pthread.h>
#include <time.h>
#include <errno.h>

#include "err.h"
#include "header.h"


/* if status = 1 - PLAY, otherwise - PAUSE */
int status = 1;
/* Thread listening on UDP socket to get commands */
pthread_t t;
struct ICY_Header *header;
struct Stream *str;

struct parameters called_parameters;

void clean() {
    if (pthread_cancel(t) != 0) {
        fprintf(stderr, "Closing UDP's thread\n");
    }
    free(header);
    free(str);
}

void parse_parameters(int argc, char *argv[]) {
    if (argc != 7) {
        fprintf(stderr, "wrong number of parameters\n");
        clean();
        exit(1);
    } else {
        called_parameters.host = argv[1];
        called_parameters.path = argv[2];
        called_parameters.r_port = argv[3];
        called_parameters.file = argv[4];
        called_parameters.m_port = atoi(argv[5]);
        called_parameters.md = argv[6];
    }
}

/* Start playing music */
void play() {
    status = 1;
    return;
}


/* Pause playing music; Mute music */
void pause_streaming() {
    status = 0;
    return;
}


/* Exit player */
void quit() {
    clean();
    exit(0);
    return;
}


 /* Return title of current song if there is in the data;
 * Title is sending to the sender of request
 */
void title() {
    return;
}


/* UDP command execution */
void get_command(char* c, int len) {
    //printf("command = %s\n", c);
    if (strncmp(c, "PLAY", len) == 0) {
        status = 1;
    } else if (strncmp(c, "PAUSE", len) == 0) {
        status = 0;
    } else if (strncmp(c, "TITLE", len) == 0) {

    } else if (strncmp(c, "QUIT", len) == 0) {
        clean();
        exit(0);
    } else {
        fprintf(stderr, "ERROR: Invalid selection\n");
    }
    return;
}


/* Listening on UDP socket; Waiting for commands */
void *listening_on_UDP_and_commands_execution(void* costam) {
    int sock, flags;
    struct sockaddr_in server_address;
    struct sockaddr_in client_address;
    char buffer[BUFFER_SIZE];
    socklen_t snda_len, rcva_len;
    ssize_t len;

    /* creating IPv4 UDP socket */
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0)
        syserr("socket\n");

    server_address.sin_family = AF_INET; /* IPv4 */
    server_address.sin_addr.s_addr = htonl(INADDR_ANY); /* listening on all interfaces */
    server_address.sin_port = htons((uint16_t)called_parameters.m_port); /* default port for receiving is PORT_NUM */

    /* bind the socket to a concrete address */
    if (bind(sock, (struct sockaddr *) &server_address, (socklen_t) sizeof(server_address)) < 0)
        syserr("bind\n");

    snda_len = (socklen_t) sizeof(client_address);

    do {
        do {
            rcva_len = (socklen_t) sizeof(client_address);
            flags = 0;  /* we do not request anything special */
            memset(buffer, 0, BUFFER_SIZE);
            len = recvfrom(sock, buffer, sizeof(buffer), flags,
                    (struct sockaddr *) &client_address, &rcva_len);
            if (len < 0) {
                syserr("error on datagram from client socket\n");
            } else {
                get_command(buffer, len);
                size_t length = sizeof(global_title);
                if (strncmp(buffer, "TITLE", len) == 0) {
                    /* Title-reply to sender */
                    ssize_t snd_len = sendto(sock, global_title, sizeof(global_title), flags,
                    (struct sockaddr *) &client_address, snda_len);
                    if (snd_len != length)
                        syserr("error on sending datagram to client socket");
                }
            }
        } while (len > 0);
    } while(1);
    if (close(sock) < 0) {
        fprintf(stderr, "Close\n");
        clean();
        exit(1);
    }
}


void GET_request(int argc, char *argv[], struct ICY_Header *header, struct Stream *str) {
    char answ[BUFFER];
    int sock, y, x, current_bytes, err, timeout, rc, fd;
    struct addrinfo addr_hints;
    struct addrinfo *addr_result;
    struct pollfd fds[1];

    /* 'converting' host/port in string to struct addrinfo */
    memset(&addr_hints, 0, sizeof(struct addrinfo));
    addr_hints.ai_family = AF_INET; /* IPv4 */
    addr_hints.ai_socktype = SOCK_STREAM;
    addr_hints.ai_protocol = IPPROTO_TCP;
    err = getaddrinfo(called_parameters.host, called_parameters.r_port, &addr_hints, &addr_result);

    if (err == EAI_SYSTEM) {
        /* system error */
        syserr("getaddrinfo: %s", gai_strerror(err));
    }
    else if (err != 0) {
        /* other error (host not found, etc.) */
        fatal("getaddrinfo: %s", gai_strerror(err));
    }

    /* initialize socket according to getaddrinfo results */
    sock = socket(addr_result->ai_family, addr_result->ai_socktype, addr_result->ai_protocol);
    if (sock < 0) {
        syserr("socket");
    }

    /* Connect socket to the server */
    if (connect(sock, addr_result->ai_addr, addr_result->ai_addrlen) < 0) {
        syserr("connect");
    }

    fds[0].fd = sock;
    fds[0].events = POLLIN;
    fds[0].revents = 0;;
    timeout = 5 * 1000;

    freeaddrinfo(addr_result);

    if (strcmp(called_parameters.file, "-") == 0) {
        fd = STDOUT;
    } else {
        fd =  open(called_parameters.file, O_RDWR | O_CREAT, 777);
    }

    memset(answ, 0, sizeof(answ));

    char with_metadata;
    if (strcmp(called_parameters.md, "yes") == 0)
        with_metadata = '1';
    else
        with_metadata = '0';
    int req_size = sizeof("GET  http/1.1\nHOST: stream3.polskieradio.pl\r\nIcy-Metadata:1\r\n\n")+sizeof(called_parameters.path);
    char *req = malloc(req_size);
    sprintf(req, "GET %s http/1.1\nHOST: stream3.polskieradio.pl\r\nIcy-MetaData:%c\r\n\n", called_parameters.path, with_metadata);
    send(sock, req, req_size, 0);
    free(req);

    int reading_with_metadata = 0;
    if (strcmp(called_parameters.md, "yes") == 0) {
        reading_with_metadata = 1;
    }

    rc = poll(fds, 1, timeout);
    if (rc < 0) {
        fprintf(stderr, "poll()\n");
        clean();
        exit(1);
    } else if (rc == 0) {
        fprintf(stderr, "TIMEOUT!\n");
        clean();
        exit(1);
    }
    if (fds[0].fd != -1 && (fds[0].revents & (POLLIN | POLLERR))) {
        /* Reading data from server with metadata */
        current_bytes = 0;
        int i = 0;
        char b[10000];
        char c;
        int end = 0;
        int header_length = 0;
        int recv_head = 0;
        while (end < 3) {
            if ((recv_head = read(sock, &c, 1) != 0)) {
                b[i] = c;
                header_length++;
                i++;
                if (c == 13) {
                    if (end == 0 || end == 2) {
                        end++;
                    } else {
                        end = 0;
                    }
                } else if (c == 10) {
                    if (end == 1) {
                        end++;
                    } else {
                        end = 0;
                    }
                } else {
                    end = 0;
                }
            } else if (recv_head == 0) {
                fprintf(stderr, "Connection lost\n");
                clean();
                exit(1);
            } else {
                fprintf(stderr, "Read\n");
                clean();
                exit(1);
            }
            if (header_length > MAX_HEADER_SIZE) {
                fprintf(stderr, "OPS, header is too long\n");
                clean();
                exit(1);
            }
        }
        /*extr = extract_specific_field(tmp_metaint, "ICY", b);
        if (!extr) {
            fprintf(stderr, "Probably this server does not send music\n");
            //exit(0); ??
        }*/
        int is_icy_metaint = extract_header_metaint(header, b);
        if (!is_icy_metaint) {
            reading_with_metadata = 0;
        }
        recv_head = read(sock, &c, 1);
        if (recv_head < 0) {
            fprintf(stderr, "Read\n");
            clean();
            exit(1);
        }
        char tmp[4096];
        uint8_t len_of_metadata = 0;
        if (reading_with_metadata) {
            char mp3_buffer[header->metaint + 1];
            memset(mp3_buffer, 0, sizeof(mp3_buffer));
            //printf("metaint %d\n", header->metaint);
            int stop = 0;
            while (!stop) {
                current_bytes = 0;
                while ((current_bytes < header->metaint) && !stop) {
                    if ((x = read(sock, mp3_buffer, header->metaint - current_bytes)) != 0) {
                        current_bytes += x;
                        if (status) {
                            y = write(fd, mp3_buffer, x);
                        }
                    } else {
                        stop = 1;
                    }
                }
                if ((x = read(sock, mp3_buffer, 1) != 0)) {
                    len_of_metadata = mp3_buffer[0];
                    len_of_metadata *= 16;
                } else {
                    stop = 1;
                }
                current_bytes = 0;
                memset(tmp, 0, sizeof(tmp));
                while ((current_bytes < len_of_metadata) && !stop) {
                    if ((x = read(sock, mp3_buffer, len_of_metadata - current_bytes)) != 0) {
                        current_bytes += x;
                        strncat(tmp, mp3_buffer, current_bytes);
                    } else {
                        stop = 1;
                    }
                }
                extract_title(tmp, str);
            }
        /* Reading without metadata */
        } else {
            //strncpy(global_title, "Unknown title. Server doesn't get metadata", sizeof("Unknown title. Server doesn't get metadata"));
            memset(answ, 0, sizeof(answ));
            while ((x = read(sock, answ, sizeof(answ))) != 0) {
                if (status) {
                    y = write(fd, answ, x);
                }
            }
        }
        if (strcmp(called_parameters.file, "-") != 0) {
            close(fd);
        }
    }
    if (close(sock) < 0) {
        fprintf(stderr, "Close\n");
    }
}

int main(int argc, char *argv[]) {
    header = malloc(sizeof(struct ICY_Header));
    str = malloc(sizeof(struct Stream));
    errno = pthread_create(&t, NULL, listening_on_UDP_and_commands_execution, NULL);
    parse_parameters(argc, argv);
    GET_request(argc, argv, header, str);
    if (pthread_cancel(t) != 0) {
        fprintf(stderr, "Closing UDP's thread\n");
    }
    clean();
    exit(0);
}
