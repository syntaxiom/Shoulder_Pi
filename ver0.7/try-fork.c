#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
	printf("Hello World!\n");
	
	fork();
	printf("Goodbye!\n");
	return 0;
}