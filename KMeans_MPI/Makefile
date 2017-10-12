MPICC = mpicc
CFLAGS = -Wall

all: main.o utils.o metrics.o
	$(MPICC) $(CFLAGS) main.o utils.o metrics.o -o kmeans

main.o: main.c metrics.h utils.h
	$(MPICC) $(CFLAGS) main.c -c -o main.o

clean:
	rm -f *.o kmeans
