using System;
using System.Drawing;
using System.IO;

namespace ImageToSource
{
    class Program
    {
        static void Main()
        {
            Console.WriteLine("Powering up...");

            Bitmap img = new Bitmap(@"C:\Users\smlwc\Pictures\Saved Pictures\test.png");
            StreamWriter file = new StreamWriter(@"C:\Users\smlwc\Documents\image.s");
            Color[] pixels = new Color[img.Width * img.Height];
            int index = 0;

            Console.WriteLine("Storing pixels into Color array...");

            for (int x = 0; x < img.Width; x++)
            {
                for (int y = 0; y < img.Height; y++)
                {
                    pixels[index] = img.GetPixel(x, y);
                    index += 1;
                }
            }

            index = 0;

            Console.WriteLine("Writing the code...");

            file.WriteLine("/* SP+12 = x_offset, SP+16 = y_offset */");
            file.WriteLine("\t.global show_image");
            file.WriteLine("show_image:");

            for (int x = 0; x < img.Width; x++)
            {
                for (int y = 0; y < img.Height; y++)
                {
                    if (pixels[index].A == 255)
                    {
                        string x_hex = x.ToString("X8");
                        string y_hex = y.ToString("X8");

                        file.WriteLine("\tLDR\tR0, =0x" + x_hex);
                        file.WriteLine("\tLDR\tR1, =0x" + y_hex);
                        file.WriteLine("\tLDR\tR2, [SP, #12]");
                        file.WriteLine("\tLDR\tR3, [SP, #16]");
                        file.WriteLine("\tADD\tR0, R0, R2");
                        file.WriteLine("\tADD\tR1, R1, R3");
                        file.WriteLine("\tMOV\tR2, #" + pixels[index].R.ToString());
                        file.WriteLine("\tMOV\tR3, #" + pixels[index].G.ToString());
                        file.WriteLine("\tMOV\tR4, #" + pixels[index].B.ToString());
                        file.WriteLine("\tBL\tput_pixel");
                    }

                    index += 1;
                }
            }
            
            Console.WriteLine("Finishing up...");

            file.WriteLine("\tBAL\tmain2");
            file.Close();

            Console.WriteLine("Done. (Press any key to exit.)");
            Console.ReadKey(true);
        }
    }
}
