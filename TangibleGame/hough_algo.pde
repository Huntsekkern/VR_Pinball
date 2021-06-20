import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Collections;

class Hough {

  private int[] accumulator;



  public ArrayList<PVector> hough(PImage edgeImg, int nLines) {

    float discretizationStepsPhi = 0.05f;
    float discretizationStepsR = 2.5f;
    int minVotes=50;

    int accNeighbours = 10; //week 11 step 2 to modify.

    int maxAcc =0 ;

    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);

    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);

    // our accumulator
    accumulator = new int[phiDim * rDim];

    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR =  1.f/(discretizationStepsR);
    
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang)*inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang)*inverseR);
    }

    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator: r += rDim / 2
          for (int phi = 0; phi < phiDim; phi += 1) {
            float r = x*tabCos[phi]+ y*tabSin[phi];
            int idx = (phi * rDim + (int)(r + rDim/2));
            accumulator[idx] += 1;
            if (accumulator[idx] > maxAcc) maxAcc = accumulator[idx];
          }
        }
      }
    }

    ArrayList<Integer> bestCandidates = new ArrayList();
/*
    for (int i = 0; i < accumulator.length; ++i) {
      if (accumulator[i] > minVotes) {
        int examin = accumulator[i];
        boolean isBiggestReg = true;
        int x = i % edgeImg.width;
        int y = i / edgeImg.height;
        for (int k = - (accNeighbours/2); k <= (accNeighbours/2); ++k) {
          if ((y + k >= 0) && (y + k < edgeImg.height)) {
            for (int l = - (accNeighbours/2); l <= (accNeighbours/2); ++l) {
              if ((x + l >= 0) && (x + l < edgeImg.width)) {
                if (examin < accumulator[(y+k)*edgeImg.width + (x+l)]) {
                  isBiggestReg = false;
                  break;
                }
              }
            }
          }
        }
        if (isBiggestReg) {
          bestCandidates.add(i);
        }
      }
    }
*/

   for (int i = 0; i < accumulator.length; ++i) {
      if (accumulator[i] > minVotes) {
        int examin = accumulator[i];
        boolean isBiggestReg = true;
        int phi = i % phiDim;
        int r = i / rDim;
        for (int k = - (accNeighbours/2); k <= (accNeighbours/2); ++k) {
          if ((r + k >= 0) && (r + k < rDim)) {
            for (int l = - (accNeighbours/2); l <= (accNeighbours/2); ++l) {
              if ((phi + l >= 0) && (phi + l < phiDim)) {
                if (examin < accumulator[(r+k)*phiDim+ (phi+l)]) {
                  isBiggestReg = false;
                  break;
                }
              }
            }
          }
        }
        if (isBiggestReg) {
          bestCandidates.add(i);
        }
      }
    }

    Collections.sort(bestCandidates, new HoughComparator(accumulator));

    ArrayList<PVector> lines = new ArrayList();

    int nbLines = 0;
    if (nLines < bestCandidates.size()) {
      nbLines = nLines;
    } else {
      nbLines = bestCandidates.size();
    }

    for (int i= 0; i < nbLines; ++i) {
      int idx = bestCandidates.get(i);
      if (accumulator[idx] > minVotes) {
        // first, compute back the (r, phi) polar coordinates:
        int accPhi = (int) (idx / (rDim)); 
        int accR = idx - (accPhi) * (rDim);
        float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
        float phi = (accPhi) * discretizationStepsPhi;
        lines.add(new PVector(r, phi));
      }
    }

    System.out.println(maxAcc);

    /*PImage houghImg = createImage(rDim, phiDim, ALPHA);
     for (int i = 0; i < accumulator.length; i++) {
     houghImg.pixels[i] = color(min(255, accumulator[i]));
     }
     // You may want to resize the accumulator to make it easier to see:
     houghImg.resize(400, 400);
     houghImg.updatePixels();
     */
    return lines;
  }
}
