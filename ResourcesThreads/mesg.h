#define MAX_DATA_SIZE 1000

typedef struct {
	long msg_type;
	char data[MAX_DATA_SIZE];
} Msg;

#define REQUEST 100L
#define CONFIRMATION 200L
#define FINISH 300L
