#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "header.h"
#include "err.h"

int extract_specific_field(char *from_header, char *field_name, char* buffer) {
    char *occurrence;
    int i, content_pos = 0;
    occurrence = strstr(buffer, field_name);
    if (occurrence != NULL) {
        occurrence += strlen(field_name) + 1;
        for (i = content_pos; occurrence[i] != '\n'; i++) {
            strncpy(from_header, occurrence + content_pos, i - content_pos);
            from_header[i - content_pos - 1] = '\0';
        }
        strncpy(from_header, occurrence + content_pos, i - content_pos);
        from_header[i - content_pos - 1] = '\0';
        return 1;
    } else {
        return 0;
    }
}


/* Extract icy-metaint - number of bytes in mp3 block */
int extract_header_metaint(ICY_Header *header, char *buffer) {
    char tmp_metaint[20];
    int extr = extract_specific_field(tmp_metaint, "icy-metaint", buffer);
    if (extr) {
        header->metaint = atoi(tmp_metaint);
        return 1;
    } else {
        return 0;
    }
}


 /* Function gets metadata block and extracts StreamTitle;
 * Extracted title is assigned to Stream->stream_title variable
 * which stores current song's title */
int extract_title(char *metadata_block, Stream *str) {
    char *occurrence;
    char title[250];
    int i, content_pos = 0;
    occurrence = strstr(metadata_block, "StreamTitle='");
    if (occurrence != NULL) {
        occurrence += strlen("StreamTitle='");
        for (i = content_pos; occurrence[i] != ';'; i++) {
            strncpy(title, occurrence + content_pos, i - content_pos);
            title[i - content_pos - 1] = '\0';
        }
        strncpy(title, occurrence + content_pos, i - content_pos);
        title[i - content_pos - 1] = '\0';
        strncpy(str->stream_title, title, sizeof(title));
        strncpy(global_title, title, sizeof(title));
        return 1;
    } else {
        return 0;
    }
}
