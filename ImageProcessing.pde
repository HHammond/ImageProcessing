/*
This program applies a self-made gaussian filter using
a convolution matrix and statistical methods learned in 
my honours statistics class at Carleton University.

This program also applies a normalization method I wrote, which 
extends the range of an image to the full 0-255 spectrum

Created by Henry Hammond 2012
*/

//path to images folder
String path = "/Users/henryhhammond92/Desktop/Covers";

ArrayList<PImage> imgs;
void setup() {

  imgs = readFiles(path);

  size(imgs.get(0).width*1, imgs.get(0).height);
  frameRate(60);
}

//this is the initial radius of the gaussian filter
float i=0.9;

void draw() {

  image( gaussian(imgs.get(0), i), 0, 0);
  
  //increment gaussian radius and for reapplication
  i+=.5;
  
  //add label
  fill(0);
  text(i, 10, 10);
}


//Gaussian blur application
PImage gaussian(PImage img, float radius) {

  // generate kernel from radius information
  int kernWidth = min( max( int(radius*16), 3 ), min(img.width, img.height));
  kernWidth += (kernWidth+1)%2;

  if ( radius <= 1/6) {
    return img;
  }

  float [] kernel = new float[kernWidth];
  
  //compute kernel values from Gaussian distribution
  for (int i=0;i<kernWidth;i++) {
    kernel[i] = gauss( radius, -kernWidth*1.0/2+i);
  }
  
  //prepare image copy
  int newImg[][][] = imageToMap(img);
  
  //convolve the image with our new kernel in 2D manner
  newImg = convolve(newImg, kernel, 1);  //filter x
  newImg = convolve(newImg, kernel, 0);  //filter y
  
  //return final image
  return mapToImage(newImg);
}

//convert PImage to integer array holding values
int [][][] imageToMap(PImage img){
  int newImg[][][] = new int[img.width][img.height][3];
  for (int x=0;x<img.width;x++) {
    for (int y=0;y<img.height;y++) {
      newImg[x][y][0] = img.get(x, y) >> 16 & 0xFF;
      newImg[x][y][1] = img.get(x, y) >>  8 & 0xFF;
      newImg[x][y][2] = img.get(x, y) >>  0 & 0xFF;
    }
  }
  
  return newImg;
}

//converts an integer map to a PImage
PImage mapToImage(int [][][]img){
  //generate final image
  PImage finalImage = new PImage(img.length, img[0].length);

  //paste data into final image
  for (int x=0;x<img.length;x++) {
    for (int y=0;y<img[x].length;y++) {
      finalImage.set(x, y, color(img[x][y][0], img[x][y][1], img[x][y][2]));
    }
  }
  
  //return the final image map
  return finalImage;
}

//trnnspose an integer map
int [][][] transpose(int [][][] img) {
  int n[][][] = new int[img[0].length][img.length][3];
  for (int x=0;x<n.length;x++) {
    for (int y=0;y<n[x].length;y++) {
      n[x][y] = img[y][x];
    }
  }
  return n;
}

//Apply guassian filter in both directions simultaneously (slower)
PImage gaussian2D(PImage img, float radius) {

  int kernWidth = int( radius/6 );

  //prepare the kernel
  float kernel[][] = new float[kernWidth*2+1][kernWidth*2+1];
  for (int x=-kernWidth; x<kernWidth; x++) {
    for (int y=-kernWidth; y<kernWidth; y++) {
      kernel[x+kernWidth][y+kernWidth] = gauss(radius, x, y);
    }
  }

  //create copy image
  int newImg[][][] = new int[img.width][img.height][3];
  for (int x=0;x<img.width;x++) {
    for (int y=0;y<img.height;y++) {
      newImg[x][y][0] = img.get(x, y) >> 16 & 0xFF;
      newImg[x][y][1] = img.get(x, y) >>  8 & 0xFF;
      newImg[x][y][2] = img.get(x, y) >>  0 & 0xFF;
    }
  }

  //apply kernel to image
  newImg = convolve( newImg, kernel );

  //generate final canvas for the image
  PImage finalImage = new PImage(img.width, img.height);

  for (int x=0;x<newImg.length;x++) {
    for (int y=0;y<newImg[x].length;y++) {
      finalImage.set(x, y, color(newImg[x][y][0], newImg[x][y][1], newImg[x][y][2]));
    }
  }

  //return the image
  return finalImage;
}

//convolution matrix application in one dimension
int [][][] convolve(int [][][] img, float [] kernel, int dir) {

  //force direction to be a binary value of horizontal or vertical
  dir = 2*(dir%2)-1;

  float [][][] newImg = new float[img.length][img[0].length][3];
  int   [][][] finalImg = new int[img.length][img[0].length][3];

  int width = img.length;
  int height = img[0].length;

  for (int x=0;x<width; x++) {
    for (int y=0;y<height;y++) {

      newImg[x][y][0] = 0;
      newImg[x][y][1] = 0;
      newImg[x][y][2] = 0;

      for (int j=0;j<kernel.length;j++) {

        if ( dir == 1 ) {
          int offset = x+j-kernel.length/2;
          if ( offset < width && offset >= 0) {
            newImg[x][y][0] += img[offset][y][0]*kernel[j];
            newImg[x][y][1] += img[offset][y][1]*kernel[j];
            newImg[x][y][2] += img[offset][y][2]*kernel[j];
          }
          else {

            if (offset > 0) {
              newImg[x][y][0] += img[ 0 ][y][0]*kernel[j];
              newImg[x][y][1] += img[ 0 ][y][1]*kernel[j];
              newImg[x][y][2] += img[ 0 ][y][2]*kernel[j];
            }
            else if (offset < width+1) {
              
              newImg[x][y][0] += img[ width-1 ][y][0]*kernel[j];
              newImg[x][y][1] += img[ width-1 ][y][1]*kernel[j];
              newImg[x][y][2] += img[ width-1 ][y][2]*kernel[j];
              
            }
          }
        }
        else {
          int offset = y+j-kernel.length/2;
          if ( offset < height && offset >= 0) {
            newImg[x][y][0] += img[x][offset][0]*kernel[j];
            newImg[x][y][1] += img[x][offset][1]*kernel[j];
            newImg[x][y][2] += img[x][offset][2]*kernel[j];
          }
          else {

            if (offset > 0) {
              newImg[x][y][0] += img[ x ][0][0]*kernel[j];
              newImg[x][y][1] += img[ x ][0][1]*kernel[j];
              newImg[x][y][2] += img[ x ][0][2]*kernel[j];
            }
            else if (offset <= width) {
              newImg[x][y][0] += img[ x ][ height-1 ][0]*kernel[j];
              newImg[x][y][1] += img[ x ][ height-1 ][1]*kernel[j];
              newImg[x][y][2] += img[ x ][ height-1 ][2]*kernel[j];
            }
          }
        }
      }

      finalImg[x][y][0] = int( newImg[x][y][0] );
      finalImg[x][y][1] = int( newImg[x][y][1] );
      finalImg[x][y][2] = int( newImg[x][y][2] );
    }
  }

  return finalImg;
}

//2d convolution matrix application
int [][][] convolve(int [][][] img, float [][] kernel) {

  float [][][] newImg = new float[img.length][img[0].length][3];
  int   [][][] finalImg = new int[img.length][img[0].length][3];

  for (int x=0; x<img.length; x++) {
    for (int y=0; y<img[x].length; y++) {

      newImg[x][y][0] = 0;
      newImg[x][y][1] = 0;
      newImg[x][y][2] = 0;

      //Apply kernel
      for (int i=0; i < kernel.length; i++) {
        for (int j=0; j < kernel[0].length; j++) {

          int xoff = x + i-floor(kernel.length*1.0/2);
          int yoff = y + i-floor(kernel.length*1.0/2);

          if ( xoff >= 0 && yoff >= 0 && xoff < img.length && yoff < img[x].length) {
            int c=0;
            newImg[x][y][c] += ( img[xoff][yoff][c] * kernel[i][j]); 
            c++;
            newImg[x][y][c] += ( img[xoff][yoff][c] * kernel[i][j]); 
            c++;
            newImg[x][y][c] += ( img[xoff][yoff][c] * kernel[i][j]);
          }
          else {

            xoff = xoff < 0? 0: xoff >= img.length ? img.length-1: xoff;
            yoff = yoff < 0? 0: yoff >= img[x].length ? img[x].length-1: yoff;

            int c = 0;
            newImg[x][y][c] += ( img[xoff][yoff][c] * kernel[i][j]); 
            c++;
            newImg[x][y][c] += ( img[xoff][yoff][c] * kernel[i][j]); 
            c++;
            newImg[x][y][c] += ( img[xoff][yoff][c] * kernel[i][j]);
          }
        }
      }

      finalImg[x][y][0] = int(newImg[x][y][0]);
      finalImg[x][y][1] = int(newImg[x][y][1]);
      finalImg[x][y][2] = int(newImg[x][y][2]);
    }
  }

  return finalImg;
}

//get guassian values
float gauss(float dev, float x) {
  return 1/( sqrt(2*PI) * dev) * exp( -x*x/(2*dev*dev));
}

//get gaussian values multinomial
float gauss(float rad, float x, float y) {

  return 1/(2*PI*rad*rad) * exp(-(x*x+y*y)/(2*rad*rad)) ;
}

//normalization method
PImage normalizeIMG(PImage img, float k) {

  img.loadPixels();
  int w = img.width;
  int h = img.height;

  PImage newImg = new PImage(w, h);

  int pxl = w*h;
  int reds[]   = new int[ pxl ];
  int greens[] = new int[ pxl ];
  int blues[]  = new int[ pxl ];

  for (int p=0; p<w*h ;p++) {
    reds[p]   = img.pixels[p] >> 16 & 0xFF;
    greens[p] = img.pixels[p] >> 8  & 0xFF;
    blues[p]  = img.pixels[p] >> 0  & 0xFF;
  }

  
  //generate statistical information
  reds = sort(reds);
  greens = sort(greens);
  blues = sort(blues);

  int bR = max( int( quartile(reds, 0.5)   - k * IQR(reds)   ), reds[0]);
  int tR = min( int( quartile(reds, 0.5)   + k * IQR(reds)   ), reds[pxl-1]);
  int bG = max( int( quartile(greens, 0.5) - k * IQR(greens) ), greens[0]);
  int tG = min( int( quartile(greens, 0.5) + k * IQR(greens) ), greens[pxl-1]);
  int bB = max( int( quartile(blues, 0.5)  - k * IQR(blues)  ), blues[0]);
  int tB = min( int( quartile(blues, 0.5)  + k * IQR(blues)  ), blues[pxl-1]);

  int xr = 0;
  int xg = 0;
  int xb = 0;
  int mr = 255;
  int mg = 255;
  int mb = 255;
  
  //set new values to normalized versions
  for (int x=0;x<w;x++) {
    for (int y=0;y<h;y++) {

      int r = img.get(x, y) >> 16 & 0xFF;
      int g = img.get(x, y) >> 8  & 0xFF;
      int b = img.get(x, y) >> 0  & 0xFF;

      r = normalize2(r, 255, 0, tR, bR);
      g = normalize2(g, 255, 0, tG, bG);
      b = normalize2(b, 255, 0, tB, bB);

      xr = max(xr, r);
      xg = max(xg, g);
      xb = max(xb, b);
      mr = min(mr, r);
      mg = min(mg, g);
      mb = min(mb, b);

      newImg.set(x, y, color(r, g, b) );
    }
  }

  //if statement added for debuggin purposes
  if (true) {
    print( bR+" "+tR+" "+mr+" "+xr+" "+k+"\n");
    print( bG+" "+tG+" "+mg+" "+xg+" "+k+"\n");
    print( bB+" "+tB+" "+mb+" "+xb+" "+k+"\n");
    print( "\n" );
  }
  return newImg;
}

//find quartile of a list
int quartile( int[] arr, float percentile) {
  return arr[ int(arr.length*percentile) ];
}

//find interquartile range of list
int IQR( int[] arr) {
  return quartile( arr, 3.0/4 ) - quartile( arr, 1.0/4 );
}

//normalization algorithm 2
int normalize2(int val, int newMax, int newMin, int Max, int Min) {
  if ( val>255) val = 255;
  if ( val<0) val = 0;
  if ( Max == Min) return 255;
  return int( (val-Min)*(newMax-newMin)/(Max-Min) +newMin);
}

//normalization algorithm 1
int normalize(int val, int newMax, int newMin, int Max, int Min, int alph, int beta) {
  if (alph == 0) return 0;
  return int( (newMax-newMin) * ( 1 / ( 1 + exp( (val-beta)/alph*-1) )) + newMin);
}

//read image files from directory
ArrayList<PImage> readFiles(String path) {

  ArrayList<PImage> images = new ArrayList();

  File dir = new File(path);
  String[] list = dir.list();

  if (list == null) {
    println("Folder could not be opened.");
    return null;
  } 
  else {
    ArrayList<String> files = new ArrayList();

    for (int i=0;i<list.length;i++) {
      //use regex to find useable image files
      if ( list[i].matches ("^.*\\.(jpg|png|jpeg)$") ) {
        PImage img = loadImage(path+"/"+list[i]);
        images.add(img);
      }
    }
  } 
  return images;
}

