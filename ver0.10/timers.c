#include <stdio.h>
#include <time.h>

int main()
{
	clock_t start = clock(), diff;
	for (int i = 0; i < 1000000; i++){}
	diff = clock() - start;
	int msec = diff * 1000 / CLOCKS_PER_SEC;
	return 0;
}