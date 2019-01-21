
// TODO:
// - find a nice layout in .glsl that uses the texture as a model and returns gl_FragColor
//   in a sort of decoupled view kind of way.  ex: render cells as 3x3 px squares
// - see if there is an atomic add to global thing for population counting
// - for webapping this stuff, see https://github.com/patriciogonzalezvivo/glslCanvas

PShader conwayState;
PGraphics displayGraphics;

long lastPrintMillis = 0;
int iterationsPerFrame = 10;
int targetFrameRate = 1000;

int environmentWidth = 1000;
int environmentHeight = 800;

void setup() {
  size(1000, 800, P3D);
  displayGraphics = createGraphics(environmentWidth, environmentHeight, P2D);
  displayGraphics.noSmooth();
  conwayState = loadShader("conway.glsl");
  conwayState.set("resolution", float(displayGraphics.width), float(displayGraphics.height));
  frameRate(targetFrameRate);

  PImage seed = createImage(environmentWidth, environmentHeight, ARGB);
  seed.loadPixels();
  for (int i = 0; i < seed.pixels.length; i++) {
    if (random(1.0) < 0.3) {
      seed.pixels[i] = 0xFFFFFFFF;
    } else {
      seed.pixels[i] = 0xFF000000;
    }
  }
  conwayState.set("seed", seed);
  conwayState.set("firstFrame", true);
}

void draw() {
  for (int i = 0; i < iterationsPerFrame; i++) {
    displayGraphics.beginDraw();
    displayGraphics.background(0);
    displayGraphics.shader(conwayState);
    displayGraphics.rect(0, 0, displayGraphics.width, displayGraphics.height);
    displayGraphics.endDraw();
  }
  image(displayGraphics, 0, 0, width, height);
  if (millis() - lastPrintMillis > 2000) {
    int iterationsPerSecond = (int)frameRate * iterationsPerFrame;
    println("Running @ " + iterationsPerSecond + " iterations per second");
    lastPrintMillis = millis();
  }

  conwayState.set("firstFrame", false);
}
