// Texture from Jason Liebig's FLICKR collection of vintage labels and wrappers:
// http://www.flickr.com/photos/jasonliebigstuff/3739263136/in/photostream/

PImage label;
PShape can;
float angle;
int startTime;

PShader shaderMask;

void setup() {
  size(1000, 1000, P3D);
  label = loadImage("tex3.jpg");
  can = createCan(716, 2500, 4500, label);
  shaderMask = loadShader("embossfrag.glsl");
  //shaderMask = loadShader("edgesfrag.glsl");
  //shaderMask = loadShader("bwfrag.glsl"); 
}

void draw() {
  scale(0.2);
  background(0);
  shader(shaderMask);
  translate(width*2.5, height*2.5);
  rotateY(angle);  
  shape(can);  
  angle += 0.01;
  //saveFrame("out.png");
}

PShape createCan(float r, float h, int detail, PImage tex) {
  startTime = millis();
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
  println(millis() - startTime);
  return sh;
}
