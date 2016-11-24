#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 256

int main() {
    char string[BUFSIZE];

    fgets(string, BUFSIZE, stdin);

    printf(string);

    return 0;
}

