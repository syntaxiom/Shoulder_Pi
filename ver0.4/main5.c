#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>

// 'global' variables to store screen info
char *fbp = 0;
struct fb_var_screeninfo vinfo;
struct fb_fix_screeninfo finfo;

void put_pixel_RGB24(int x, int y, char r, char g, char b)
{
    // calculate the pixel's byte offset inside the buffer
    // note: x * 3 as every pixel is 3 consecutive bytes
    unsigned int pix_offset = x * 3 + y * finfo.line_length;

    // now this is about the same as 'fbp[pix_offset] = value'
    *((char*)(fbp + pix_offset + 0)) = b;
    *((char*)(fbp + pix_offset + 1)) = g;
    *((char*)(fbp + pix_offset + 2)) = r;
}

int main(int argc, char* argv[])
{
    int fbfd = 0;
    long int screensize = 0;

    // Open the file for reading and writing
    fbfd = open("/dev/fb0", O_RDWR);

    // Get variable screen information
    ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo);
    
    // Get fixed screen information
    ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo);

    // map fb to user mem 
    screensize = vinfo.xres * vinfo.yres * vinfo.bits_per_pixel / 8;
    fbp = (char*)mmap(0, 
              screensize, 
              PROT_READ | PROT_WRITE, 
              MAP_SHARED, 
              fbfd, 
              0);
    
    put_pixel_RGB24(0, 0, 255, 255, 255);
    sleep(5);

    // cleanup
    munmap(fbp, screensize);
    close(fbfd);
    return 0;
}
