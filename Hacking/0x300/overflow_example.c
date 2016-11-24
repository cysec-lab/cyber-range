#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int value = 5; 
    char buffer_one[8], buffer_two[8];

    strcpy(buffer_one, "one"); /* "one"をbuffer_oneに設定 */
    strcpy(buffer_two, "two"); /* "two"をbuffer_twoに設定 */

    printf("[前] buffer_two は %p にあり、その値は \'%s\' です\n", buffer_two, buffer_two);
    printf("[前] buffer_one は %p にあり、その値は \'%s\' です\n", buffer_one, buffer_one);
    printf("[前] value は %p にあり、その値は %d (0x%08x) です\n", &value, value, value);

    printf("\n[STRCPY] %d バイトを buffer_two にコピーします\n\n", strlen(argv[1]));
    strcpy(buffer_two, argv[1]); /* 最初の引数をbuffer_twoにコピーする */

    printf("[後] buffer_two は %p にあり、その値は \'%s\' です\n", buffer_two, buffer_two);
    printf("[後] buffer_one は %p にあり、その値は \'%s\' です\n", buffer_one, buffer_one);
    printf("[後] value は %p にあり、その値は %d (0x%08x) です\n", &value, value, value);    
}
