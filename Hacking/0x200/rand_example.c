#include <stdio.h> 
#include <stdlib.h>

int main() { 
   int i;
   printf("RAND_MAX： %u\n", RAND_MAX); 
   srand(time(0));

   printf("0からRAND_MAXまでの乱数値\n"); 
   for(i=0; i < 8; i++)
      printf("%d\n", rand()); 
   printf("1から20までの乱数値\n"); 
   for(i=0; i < 8; i++)
      printf("%d\n", (rand()%20)+1);
}
