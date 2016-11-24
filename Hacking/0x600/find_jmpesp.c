int main()
{
  unsigned long linuxgate_start = 0xffffe000;
  char *ptr = (char *) linuxgate_start;

  int i;

  for(i=0; i < 4096; i++)
  {
    if(ptr[i] == '\xff' && ptr[i+1] == '\xe4')
      printf("jmp esp 命令は %p にあります。\n", ptr+i);
  }
}
