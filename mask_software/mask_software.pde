// Texture from Jason Liebig's FLICKR collection of vintage labels and wrappers:
// http://www.flickr.com/photos/jasonliebigstuff/3739263136/in/photostream/

PImage label;
PImage newLabel;
PShape can;
float angle;
int startTime;
int mask; // 0, 1, 2: BW, edge, emboss

PShader shaderMask;

void setup() {
  startTime = millis();
  mask = 0;
  size(1000, 1000, P3D);
  label = loadImage("tex3.jpg");
  newLabel = createImage(label.width, label.height, RGB);
  switch (mask) {
    case 0:
      filterImageBW();
    break;
    case 1:
      filterImageEdges();
    break;
    case 2:
      //filterImageEmboss();
    break;
  }
  can = createCan(716, 2500, 4500, newLabel);
  println(millis() - startTime);
}

void draw() {
  scale(0.4);
  background(0);
  translate(width*1.2, height*1.2);
  rotateY(angle);  
  shape(can);  
  angle += 0.01;
  saveFrame("out"+ mask +".png");
}

void filterImageEdges() {
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