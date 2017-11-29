#include <stdio.h>

int main()
{
	printf("\e[?25l");
 	fflush(stdout);
	sleep(3);
	printf("\e[?25h");
  	fflush(stdout);
	sleep(3);
	return 0;
}