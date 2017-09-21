#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>

// 'global' variables to store screen info
char *fbp = 0;
struct fb_var_screeninfo vinfo;
struct fb_fix_screeninfo finfo;

// helper function to 'plot' a pixel in given color
void put_pixel(int x, int y, int c)
{
    // calculate the pixel's byte offset inside the buffer
    unsigned int pix_offset = x + y * finfo.line_length;

    // now this is about the same as '*((char*)(fbp + pix_offset)) = c'
    //fbp[pix_offset] = c;
    *((char*)(fbp + pix_offset)) = c;

}

// application entry point
int main(int argc, char* argv[])
{

    int fbfd = 0;
    struct fb_var_screeninfo orig_vinfo;
    long int screensize = 0;

    // Open the file for reading and writing
    fbfd = open("/dev/fb0", O_RDWR);

    // Get variable screen information
    ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo);

    // Store for reset (copy vinfo to vinfo_orig)
    memcpy(&orig_vinfo, &vinfo, sizeof(struct fb_var_screeninfo));

    // Change variable info
    vinfo.bits_per_pixel = 8;
    ioctl(fbfd, FBIOPUT_VSCREENINFO, &vinfo);

    // Get fixed screen information
    ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo);

    // map fb to user mem 
    screensize = vinfo.xres * vinfo.yres;
    fbp = (char*)mmap(0, 
              screensize, 
              PROT_READ | PROT_WRITE, 
              MAP_SHARED, 
              fbfd, 
              0);

    put_pixel(vinfo.xres / 2, vinfo.yres / 2, 5);
    sleep(5);

    // cleanup
    munmap(fbp, screensize);
    ioctl(fbfd, FBIOPUT_VSCREENINFO, &orig_vinfo);
    close(fbfd);

    return 0;

}