#define TRUE  1
#define FALSE 0
#define TCP_TIMEOUT 5
#define PORT_NUM 10099
#define BUFFER_SIZE 10000
#define BUFFER 50000

#define STDOUT 1

#define DEBUG 0

#define MAX_HEADER_SIZE 8192


typedef struct ICY_Header{
    /* name of the server */
    char icy_name[500];
    /* redundant notice */
    char icy_notice1[500];
    /* tells the client what server it is and version */
    char icy_notice2[500];
    /* what genre the server falls under */
    char icy_genre[127];
    /* server homepage */
    char icy_url[511];
    /* whether the server is public or not */
    char icy_pub[15];
    /* bitrate */
    char icy_br[15];
    /* number of data bytes to read between Meta-Data blocks */
    unsigned int metaint;
} ICY_Header;


typedef struct Stream {
    /* current song title */
    char stream_title[511];
    /* number of bytes read since last metadata block */
    unsigned int number_of_bytes;
    /* Number of bytes read from beginning */
    unsigned int total_number_of_bytes;
} Stream;


typedef struct parameters {
    /* host address */
    char *host;
    /* path to data */
    char *path;
    /* TCP port */
    char *r_port;
    /* name of file where data will be stored;
     * '-' write on STDOUT */
    char *file;
    /* UDP port number to listening for commands */
    int m_port;
    /* md = yes - want to get metadata
     * md = no - dont's want to get metadata */
    char *md;
} parameters;
