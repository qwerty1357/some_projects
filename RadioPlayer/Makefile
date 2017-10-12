TARGETS: player client_udp

CC	= gcc
CFLAGS	= -Wall -O2 -pthread

all: $(TARGETS)

player: player.o err.o header.o
	$(CC) $(CFLAGS) $^ -o $@

%.o: %.cpp types.h
	%(CC) $(CFLAGS) -c $< -o $@

client_udp: client_udp.o err.o
	$(CC) $(LFLAGS) $^ -o $@

.PHONY: all clean debug

clean:
	rm -f player client_udp err *.o *~ *.bak
