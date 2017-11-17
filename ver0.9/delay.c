#include <stdio.h>
#include <time.h>

struct timespec tim;

int main()
{
  tim.tv_sec = 1;
  tim.tv_nsec = 500000000;
  nanosleep(&tim, NULL);
  return 0;
}
