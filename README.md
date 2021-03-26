# Computer Architecture course projects [ECOAR]
**Interpolated Rectangle**  

# Description  
Porject implemented in MIPS assembly using MARS simulator.  
Program displays interpolated rectangle on the bitmap.  
   
Program takes as an input:  
* width in pixels  
* heigh in pixels  
* color of vertices as: R, G, B as integer values.  

# Interpolation algorithm  
Step size is calculated as a difference between each color component (R, G and B) of the vertices.
This value is added to the previously drawn pixel to obtain the next color value.  
  
*Interpolation Y = (color component of vertice 3 - color component of vertice 1) / height*  
*Interpolation X = (color component of vertice 2 - color component of vertice 1) / width*  
*Interpolation X1 = color component of vertice 4 - color component of vertice 3) / width*  
*Interpolation Difference = Interpolation X1 - Interpolation X*  

*Interpolation Difference* is needed to change step size when going to the next row.

# Bitmap settings:  
In order to see program results there is a need to input the following settings and connect the bitmap to MIPS:  
* Display width in Pixels: 1024  
* Base address for display: 1x10040000 (heap)  
  
Colors of pixels are interpolated using fixed-point arithmetics (16.16 format).  
 
# Emaple outputs of the program  
(PINK) 16763080 - (YELLOW) 16762880 - (BLUE) 2634473 – (GREY) 988190  
   
![alt text](https://github.com/Kjablonska/ECOAR/blob/master/assets/interpolation1.png?raw=true)  
  
(RED) 16711680 - (GREEN) 65280 - (BLUE) 255 - (WHITE) 16777215  
  
![alt text](https://github.com/Kjablonska/ECOAR/blob/master/assets/Interpolation2.png?raw=true)  
