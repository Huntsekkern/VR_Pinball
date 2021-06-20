import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

class BlobDetection {
  
  private PImage img;
  
  public BlobDetection(PImage img){
    this.img = img;
  }
  
  //black and white input, find white;
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {


    PImage result = createImage(img.width, img.height, RGB);
    result.loadPixels();
    // First pass: label the pixels and store labels' equivalences

    int [] labels = new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    labelsEquivalences.add(new TreeSet());
    labelsEquivalences.get(0).add(0);

    int currentLabel = 1;
    // TODO!   

    for (int y = 0; y < result.height; ++y) {
      for (int x = 0; x < result.width; ++x) {
        if (brightness(input.pixels[y*img.width + x]) > 128) {
          int appliedLabel = 0;
          boolean hasNeighbour = false;
          int smallestNeighbour = Integer.MAX_VALUE;
          int[] neighbours = new int[4];

          if (x > 0 && y > 0 && labels[(y-1)*img.width + (x-1)] != 0) {
            hasNeighbour = true;
            neighbours[0] = labels[(y-1)*img.width + (x-1)];
            smallestNeighbour = neighbours[0];
          }
          if (y > 0 && labels[(y-1)*img.width + x] != 0) {
            hasNeighbour = true;
            neighbours[1] = labels[(y-1)*img.width + x];
            smallestNeighbour = min(smallestNeighbour, neighbours[1]);
          }
          if (y > 0 && x < result.width-1 && labels[(y-1)*img.width + x+1] != 0) {
            hasNeighbour = true;
            neighbours[2] = labels[(y-1)*img.width + x+1];
            smallestNeighbour = min(smallestNeighbour, neighbours[2]);
          }
          if (x > 0 && labels[y*img.width + x-1] != 0) {
            hasNeighbour = true;
            neighbours[3] = labels[y*img.width + x-1];
            smallestNeighbour = min(smallestNeighbour, neighbours[3]);
          }

          if (hasNeighbour) {
            appliedLabel = smallestNeighbour;
            for (int i = 0; i < 4; ++i) {
              if(neighbours[i] > smallestNeighbour){
                labelsEquivalences.get(neighbours[i]).add(smallestNeighbour);
                labelsEquivalences.get(smallestNeighbour).add(neighbours[i]);
              }
            }
          } else {
            appliedLabel = currentLabel;
            currentLabel++;
            labelsEquivalences.add(new TreeSet());
            labelsEquivalences.get(appliedLabel).add(appliedLabel);
          }
          labels[y*img.width + x] = appliedLabel;
        }
      }
    }
    
    boolean[] marked = new boolean[labelsEquivalences.size()];
    
    for(int i= 0; i < marked.length; ++i){
      marked[i] = false;
    }
    
    for(int i = 0; i < labelsEquivalences.size(); ++i){
      if(!marked[i]){
        for(int j = i+1; j < labelsEquivalences.size(); ++j){
            TreeSet<Integer> intersection = new TreeSet();
            intersection.addAll(labelsEquivalences.get(i)); 
            intersection.retainAll(labelsEquivalences.get(j)); 
            if(!intersection.isEmpty()) {
              marked[j] = true;
              labelsEquivalences.get(i).addAll(labelsEquivalences.get(j));
              labelsEquivalences.get(j).addAll(labelsEquivalences.get(i));
            }
        }
      }
    }
    
    
    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    int[] blobSizes = new int[currentLabel]; 

    for (int y = 0; y < result.height; ++y) {
      for (int x = 0; x < result.width; ++x) {
        int oldval = labels[y*img.width + x];
            // TODO! ================================================================TODO
            // could come from above, when setting up the equivalences too
        int newval = (labelsEquivalences.get(oldval)).first();
        //int newval = oldval;
        labels[y*img.width + x] = newval;
        if (onlyBiggest) {
          blobSizes[newval] += 1;
        }
      }
    }




    int biggestBlobLabel = 0;
    int biggestBlobSize = 0;
    for (int i = 1; i < currentLabel; ++i) {
      if (blobSizes[i] > biggestBlobSize) {
        biggestBlobLabel = i;
        biggestBlobSize = blobSizes[i];
      }
    }

    // Finally:
    // if onlyBiggest==true, output an image with the biggest blob in white and others in black
    if (onlyBiggest) {
      for (int i = 0; i < img.width * img.height; i++) {
        if (labels[i] == biggestBlobLabel) {
          result.pixels[i] = color(255);
        } else {
          result.pixels[i] = color(0);
        }
      }
    } else {
      // if onlyBiggest==false, output an image with each blob colored in one uniform color
      for (int i = 0; i < img.width * img.height; i++) {
        if (labels[i] != 0)
          result.pixels[i] = color(labels[i]*255/currentLabel, (labels[i]*255/currentLabel+100)%255, (labels[i]*255/currentLabel+180)%255);
        else
        result.pixels[i] = color(0);
        }
      }
      result.updatePixels();
    return result;
  }
}
