CFLAGS = -Wall
S = server.c
C = client.c
E = err.c

all: server client

server: $(S) $(E)
	gcc $(CFLAGS) $(S) $(E) -pthread -o server

client: $(C) $(E)
	gcc $(CFLAGS) $(C) $(E) -o client

clean:
	rm -f server client
