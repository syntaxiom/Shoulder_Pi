#include <unistd.h>

int main()
{
	lseek(0, 14, SEEK_SET);
	return 0;
}