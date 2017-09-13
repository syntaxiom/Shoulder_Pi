 #include <X11/Xlib.h>
  #include <stdio.h>

   int main()
 {
   Display *display;
   if(!(display=XOpenDisplay(NULL)))
   {
     return(1);
   }
  return 0;
}