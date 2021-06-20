import java.util.ArrayList;
import java.util.List;
import gab.opencv.*;
import processing.video.*;


class ImageProcessing extends PApplet {
  //Capture cam;
  Movie cam;
  PImage img; //image cam
  OpenCV opencv;
  PVector radianAngles;
  void settings() {
    size(960, 540);
  }

  void setup() {
    /*
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
    */
    
    //cam = new Movie(this, "/home/jd/Documents/infoVisuel/repo-gr/VisualGame/last_version/Game/testvideo.avi");
    cam = new Movie(this, "C:/Users/raoul_dahrnuy/OneDrive/EPFL/Semestre4/Visual/Project/Game/last_version/Game/testvideo.avi");
    cam.loop();
    
    //noLoop(); // no interactive behaviour: draw() will be called only once.
    opencv = new OpenCV(this, 100, 100);
  }
  float nomrFacotr = 2, nomrFactor2 = 4, gaussianNormFact = 99;
  
  void draw() {
    if (cam.available() == true) {
      cam.read();
    }
    img = cam.get();
    //image(img, 0, 0);
//===================================================================================================================================================================================
    
    int minH = 80, maxH = 140; //vert
    int minS = 40, maxS = 255;
    int minB = 0, maxB = 180;
    
    PImage img1 = threshold(img, minH, maxH, minS, maxS, minB, maxB);
    PImage img11 = (new BlobDetection(img1)).findConnectedComponents(convolute(img1, gaussianKernel,3,gaussianNormFact), true);
    PImage img2 = scharr(img11);
    
    ArrayList<PVector> lines = (new Hough()).hough(img2, 8);

    List<PVector> quad = (new QuadGraph()).findBestQuad(lines, img2.width, img2.height, 10000000, 100000, false);

    for (int i = 0; i < quad.size(); ++i) {
      quad.get(i).z = 1;
    }

    TwoDThreeD rotat = new TwoDThreeD(img2.width, img2.height, 30);
    radianAngles = rotat.get3DRotations(quad);

   // System.out.println(quad.toString());
    //System.out.println(radianAngles.toString());

    image(img, 0, 0);

    drawLines(img2, lines);
    drawPoints(quad);
  }

  PVector getRotation() {
    return radianAngles;
  }

  float[][] kernel = { { 0, 0, 0 }, 
    { 0, 2, 0 }, 
    { 0, 0, 0 }};
  float[][] kernel2 = {{0, 1, 0}, {1, 0, 1}, {0, 1, 0}};
  float[][] gaussianKernel = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}};

  PImage convolute(PImage img, float[][] kernel, int N, float normFactor) {

    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);
    result.loadPixels();
    // kernel size N = 3
    //
    // for each (x,y) pixel in the image:
    // -multiply intensities for pixels in the range
    //    (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
    //    corresponding weights in the kernel matrix
    //- sum all these intensities and divide it by normFactor
    //- set result.pixels[y * img.width + x] to this value

    for (int y = N/2; y < img.height-N/2; ++y) {
      for (int x = N/2; x<img.width-N/2; ++x) {
        int sum = 0;
        for (int j = y - N/2; j <= y + N/2; ++j) {
          for (int i = x -N/2; i <= x + N/2; ++i) {
            sum += brightness(img.pixels[j*img.width + i]) * kernel[i -(x - N/2)][j - (y - N/2)];
          }
        }
        result.pixels[x + y*img.width] = color(sum/normFactor);
      }
    }
    result.updatePixels();
    return result;
  }

  boolean imagesEqual(PImage img1, PImage img2) {
    if (img1.width != img2.width || img1.height != img2.height)
      return false;
    for (int i = 0; i < img1.width*img1.height; i++)
      //assuming that all the three channels have the same value
      if (red(img1.pixels[i]) != red(img2.pixels[i]))
        return false;
    return true;
  }

  PImage scharr(PImage img) {
    float[][] vKernel = {
      { 3, 0, -3 }, 
      { 10, 0, -10 }, 
      { 3, 0, -3 } };

    float[][] hKernel = { 
      {3, 10, 3}, 
      {0, 0, 0}, 
      {-3, -10, -3}};

    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0; 
    int N = 3;
    float[] buffer = new float[img.width * img.height];
    // *************************************
    // Implement here the double convolution
    // *************************************
    for (int y = N/2; y < img.height-N/2; ++y) {
      for (int x = N/2; x<img.width-N/2; ++x) {
        int sum_h = 0, sum_v = 0;
        for (int j = y - N/2; j <= y + N/2; ++j) {
          for (int i = x -N/2; i <= x + N/2; ++i) {
            sum_h += brightness(img.pixels[j*img.width + i]) * hKernel[i -(x - N/2)][j - (y - N/2)];
            sum_v += brightness(img.pixels[j*img.width + i]) * vKernel[i -(x - N/2)][j - (y - N/2)];
          }
        }
        float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        buffer[x + y*img.width] = sum;
        if (sum > max) max=sum;
      }
    }
    result.loadPixels();
    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x] = color(val);
      }
    }
    result.updatePixels();
    return result;
  }

  PImage threshold(PImage img, float minHue, float maxHue, float minSat, float maxSat, float minBri, float maxBri) {
    PImage result= createImage(img.width, img.height, RGB);
    result.loadPixels();
    for (int i = 0; i < img.width * img.height; ++i) {
      color c = img.pixels[i]; 
      float hueC = hue(c), satC = saturation(c), briC = brightness(c);
      if ((hueC <= maxHue && hueC >= minHue)&&(satC <= maxSat && satC >= minSat)&&(briC <= maxBri && briC >= minBri)) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }
    result.updatePixels();
    return result;
  }

  PImage threshold(PImage img, int t) {
    PImage result= createImage(img.width, img.height, RGB);
    result.loadPixels();
    for (int i = 0; i < img.width * img.height; ++i) {
      color c = img.pixels[i]; 
      float briC = brightness(c);
      if (briC > t) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = color(0);
      }
    }
    result.updatePixels();
    return result;
  }

  void drawLines(PImage edgeImg, ArrayList<PVector> lines) {
    for (int idx = 0; idx < lines.size(); idx++) {
      PVector line=lines.get(idx);
      float r = line.x;
      float phi = line.y;
      //Cartesian equation of a line: y = ax + b
      //in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      //=> y = 0 : x = r / cos(phi)
      //=> x = 0 : y = r / sin(phi)

      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

      // Finally, plot the
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else {
          line(x2, y2, x3, y3);
        }
      }
    }
  }

  void drawPoints(List<PVector> quad) {
    int radius = 10;
    colorMode(RGB);
    for (int idx = 0; idx < quad.size(); ++idx) {
      PVector point = quad.get(idx);
      stroke(44, 255, 255);
      fill(44, 255, 255, 130);
      ellipse(point.x, point.y, radius, radius);
    }
  }
}
