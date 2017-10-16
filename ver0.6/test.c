#include <unistd.h>

int main()
{
	lseek(0, 14, SEEK_CUR);
	return 0;
}