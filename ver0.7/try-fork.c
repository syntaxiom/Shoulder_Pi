#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

int main()
{
	printf("Hello World!\n");

	int filedesc = open("/home/pi/Desktop/image.bin", O_RDWR);
	
	fork();
	fork();

	lseek(filedesc, 4, SEEK_CUR);

	return 0;
}