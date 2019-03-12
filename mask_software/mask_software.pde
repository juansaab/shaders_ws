// Texture from Jason Liebig's FLICKR collection of vintage labels and wrappers:
// http://www.flickr.com/photos/jasonliebigstuff/3739263136/in/photostream/

PImage label;
PImage newLabel;
PShape can;
float angle;
int startTime;
float[][] matrix;
int mask; // 0, 1, 2: BW, edge, emboss
int detail;
int sample;

PShader shaderMask;

void setup() {
  startTime = millis();
  mask = 0;
  detail = 4096;
  sample = 1;
  size(1000, 1000, P3D);
  label = loadImage("tex"+ sample +".jpg");
  newLabel = createImage(label.width, label.height, RGB);
  switch (mask) {
    case 0:
      filterImageBW();
    break;
    case 1:
      matrix = new float[][]{{ -1, -1, -1 },
                             { -1,  8, -1 },
                             { -1, -1, -1 } };
      filterImageKernel();
    break;
    case 2:
      newLabel.filter(GRAY);
      matrix = new float[][]{{ -2, -1,  0 },
                             { -1,  1,  1 },
                             {  0,  1,  2 } };
      filterImageKernel();
    break;
  }
  can = createCan(716, 2500, detail, newLabel);
  println(millis() - startTime);
}

void draw() {
  scale(0.4);
  background(0);
  translate(width*1.2, height*1.2);
  rotateY(angle);  
  shape(can);  
  angle += 0.01;
  saveFrame("out_image_"+ sample +"_mask" + mask + ".png");
}

void filterImageKernel() {

  // We are going to look at both image's pixels
  label.loadPixels();
  newLabel.loadPixels();
  
  for (int x = 0; x < label.width; x++) {
    for (int y = 0; y < label.height; y++ ) {
      int loc = x + y*label.width;
      // Each pixel location (x,y) gets passed into a function called convolution() 
      // which returns a new color value to be displayed.
      color c = convolution(x,y,matrix,3,label);
      if (mask == 2) {
        int b = int(brightness(label.pixels[loc]));
        c = color(b, b, b);
      }
      newLabel.pixels[loc] = c;
    }
  }

  // We changed the pixels in destination
  newLabel.updatePixels();
}

void filterImageBW() {
  float threshold = 127;

  // We are going to look at both image's pixels
  label.loadPixels();
  newLabel.loadPixels();
  
  for (int x = 0; x < label.width; x++) {
    for (int y = 0; y < label.height; y++ ) {
      int loc = x + y*label.width;
      // Test the brightness against the threshold
      if (brightness(label.pixels[loc]) > threshold) {
        newLabel.pixels[loc]  = color(255);  // White
      }  else {
        newLabel.pixels[loc]  = color(0);    // Black
      }
    }
  }

  // We changed the pixels in destination
  newLabel.updatePixels();
}

color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  // Loop through convolution matrix
  for (int i = 0; i < matrixsize; i++){
    for (int j= 0; j < matrixsize; j++){
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      // Make sure we have not walked off the edge of the pixel array
      loc = constrain(loc,0,img.pixels.length-1);
      // Calculate the convolution
      // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
      rtotal += (red(img.pixels[loc]) * matrix[i][j]);
      gtotal += (green(img.pixels[loc]) * matrix[i][j]);
      btotal += (blue(img.pixels[loc]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal,0,255);
  gtotal = constrain(gtotal,0,255);
  btotal = constrain(btotal,0,255);
  // Return the resulting color
  return color(rtotal,gtotal,btotal);
}

PShape createCan(float r, float h, int detail, PImage tex) {
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  sh.texture(tex);
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail;
    float x = sin(i * angle);
    float z = cos(i * angle);
    float u = float(i) / detail;
    sh.normal(x, 0, z);
    sh.vertex(x * r, -h/2, z * r, u, 0);
    sh.vertex(x * r, +h/2, z * r, u, 1);    
  }
  sh.endShape();
  return sh;
}
