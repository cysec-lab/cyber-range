#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    //signed int num = (1 << 31) - 1;
    signed int num = 1 << 31;
    char data[] = "abcdefghijklmnopqrstuvwxyz"; 
    char *p;

    printf("num=%d\n", num);

    if (num < 1024) {
        printf("num < 1024\n");
        
        p = (char *)malloc(sizeof(char) * 1024);
        strncpy(p, data, num);
        printf("%s\n", p);
        
        free(p);
    } else {
        printf("num >= 1024\n");
    }

    return 0;
}

