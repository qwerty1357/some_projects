#ifndef __HEADER_H_
#define __HEADER_H_

#include "types.h"
#include "err.h"

char global_title[512];

int extract_specific_field(char *from_header, char *field_name, char* buffer);

void parse_header(char *header);

int extract_header_fields(ICY_Header *header, char *buffer);

int extract_header_metaint(ICY_Header *header, char *buffer);

int extract_title(char *metadata_block, Stream *str);

#endif // __HEADER_H_
