#include <stdio.h> 
#include <string.h>

int main() { 
   char message[20]; 
   int count, i;

   strcpy(message, "Hello, world!");

   printf("何度繰り返しますか？ "); 
   scanf("%d", &count);

   for(i=0; i < count; i++) 
      printf("%3d - %s\n", i, message);
}
