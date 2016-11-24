#include <stdio.h>

int main(int argc, char *argv[]) {
   char buffer[50];

   printf("バッファは %p にあります。\n", &buffer);

   if(argc > 1)
      strcpy(buffer, argv[1]);

   return 1;
}
