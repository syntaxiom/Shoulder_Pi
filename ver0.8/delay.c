#include <stdio.h>
#include <time.h>

int main()
{
   struct timespec tim, tim2;
   tim.tv_sec = 1;
   tim.tv_nsec = 500;
   nanosleep(&tim , &tim2);
   return 0;
}