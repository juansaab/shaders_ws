// Texture from Jason Liebig's FLICKR collection of vintage labels and wrappers:
// http://www.flickr.com/photos/jasonliebigstuff/3739263136/in/photostream/

PImage label;
PShape can;
float angle;
int startTime;
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
  can = createCan(716, 2500, detail, label);
  switch (mask) {
    case 0:
      shaderMask = loadShader("bwfrag.glsl");
    break;
    case 1:
      shaderMask = loadShader("edgesfrag.glsl");
    break;
    case 2:
      shaderMask = loadShader("embossfrag.glsl");
    break;
  }
  println(millis() - startTime);
}

void draw() {
  scale(0.4);
  background(0);
  shader(shaderMask);
  translate(width*1.2, height*1.2);
  rotateY(angle);  
  shape(can);  
  angle += 0.01;
  saveFrame("out_image_"+ sample +"_mask" + mask + ".png");
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
