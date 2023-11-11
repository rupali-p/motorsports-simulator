import peasy.*;
import processing.sound.*;
import ddf.minim.*;
import ddf.minim.spi.*;
import javax.sound.sampled.*;


float ampWeight = 1.0; // Weight for amplitude
float pitchWeight = 1.0; // Weight for pitch

float minPitch = 0.01;
float maxPitch = 0.02;

Minim minim;
Amplitude amp;
AudioIn in;
AudioInput inputPitch;
FFT fft;
PeasyCam cam;

int bands = 512;
float[] spectrum = new float[bands];
PVector camPosition;
ArrayList<PVector> coords = new ArrayList<PVector>();
float carPositionOnPath = 10;
float carPositionOnPathCar2 = 40;
boolean isDrawing = true;
int glowSize = 50; // Size of the glowing circle
int glowAlpha = 20; // Reduced alpha (transparency) of the glowing circle
boolean isPaused = false;
PVector pausedPosition;
PVector pausedPositionCar2;
float boxSize = 40;
float boxWidth = 90;
float boxHeight = 27;
float boxDepth = 30;
float speedCar1;
float speedCar2;
int tab;

color[] colours = new color[3];
PImage[] liveries = new PImage[3];

UnsplashImage backgroundAPI;
PImage backgroundImage;
String userInput = "";
String query;
boolean enableAPIQuery = true;


void setup() {
  size(800, 600, P3D);
  noFill();
  stroke(0);
  colours[0] = color(255, 0, 0);  // Red
  colours[1] = color(1, 119, 140);  // Aston Martin
  colours[2] = color(255, 165, 0); // Orange
  liveries[0] = loadImage("../data/ferrari55.png");
  liveries[1] = loadImage("../data/aston-martin.png");
  liveries[2] = loadImage("../data/mclaren81.png");

  cam = new PeasyCam(this, width/2, height/2, 0, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  camPosition = new PVector(width, height, 0);
  textureMode(NORMAL);

  Sound.list();
  Sound s = new Sound(this);
  s.inputDevice(3);
  AudioIn in = new AudioIn(this, 0);
  in.start();
  amp = new Amplitude(this);
  amp.input(in);
  println(amp.analyze());
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  fft.input(in);
}

void draw() {
  background(155);
  if (enableAPIQuery && isDrawing){
    cam.beginHUD();
    fill(0);
    
    textAlign(CENTER, CENTER);
    textSize(20);
    text("Please type your destination and press enter when ready", width/2, height/2 - 20);
    
    text(userInput, width/2, height/2 + 20);
    query = userInput;
    cam.endHUD();
  }
  if (!enableAPIQuery) {
    cam.beginHUD();
    backgroundAPI = new UnsplashImage(query);
    if (backgroundAPI.getBackground().exists){
      backgroundImage = backgroundAPI.getBackground().image;
      image(backgroundImage, 0, 0, width, height);
    }
    cam.endHUD();
  }
 
  if (isDrawing && !enableAPIQuery) {
    cam.beginHUD();
    drawGlowingCircle();
    stroke(10);
    drawPath3D();
    if (coords.size() >= 20) {
      PVector firstCoord = coords.get(0);
      PVector lastCoord = coords.get(coords.size() - 1);
      // Calculating the distance between the first and last coordinates
      float distance = PVector.dist(firstCoord, lastCoord);
      // Displaying the circuit design if the user is near the starting coordinates
      if (distance < glowSize/3) {
        isDrawing = false;
      }
      println(coords.size());
    }
    cam.endHUD();
  } else if (!isDrawing && !enableAPIQuery && (coords.size() >= 20)) {
    println(amp);
    float ampNormalised = amp.analyze();
    println(ampNormalised);
    speedCar1 = map(ampNormalised, 0, 0.01, 0.05, 1); // Mapping the amplitude to the speed
    println("speedAmp: " + speedCar1);
    // Perform FFT on the audio input
    fft.analyze(spectrum);
    float pitchNormalised = spectrum[findPeak(spectrum)]; // Assuming findPeak returns the index of the peak

    speedCar2 = map(pitchNormalised, minPitch, maxPitch, 0.05, 1.5) * pitchWeight; // Adjust the range as needed

    println("Pitch Before Mapping: " + pitchNormalised);
    println("Pitch After Mapping (SpeedCar2): " + speedCar2);

    drawPath3D();
    moveCarAlongPath(1, speedCar1);  // Pass speed for car 1
    moveCarAlongPath(2, speedCar2);  // Pass speed for car 2
  }
}

int findPeak(float[] spectrum) {
  // Return a specific value (e.g., -1) when the array is empty
  if (spectrum == null || spectrum.length == 0) {
    return -1;
  }

  int peakIndex = 0;
  float peakValue = spectrum[0];

  for (int i = 1; i < spectrum.length; i++) {
    if (spectrum[i] > peakValue) {
      peakValue = spectrum[i];
      peakIndex = i;
    }
  }
  return peakIndex;
}

void drawPath3D() {
  noFill();
  stroke(1);
  strokeWeight(20);  
  beginShape();
  for (PVector point3D : coords) {
    vertex(point3D.x, point3D.y, point3D.z);
  }
  endShape(CLOSE);
  beginShape();
  for (PVector point3D : coords) {
    vertex(point3D.x - 20, point3D.y, point3D.z);
  }
  endShape(CLOSE);
}

void drawGlowingCircle() {
  float ellipseSize = 0.0;
  if (!coords.isEmpty()) {
    PVector firstCoord = coords.get(0);
    ellipseSize = glowSize;
    if (isDrawing) {
      fill(255, 0, 0);
    } else {
      fill(155);
    }
    noStroke();
    ellipse(firstCoord.x, firstCoord.y, ellipseSize, ellipseSize);
  }
}

void drawCarLivery(int carNumber) {
  int currentPointIndex;
  if (carNumber == 1) {
    currentPointIndex = (int) carPositionOnPath;
  } else {
    currentPointIndex = (int) carPositionOnPathCar2;
  }
  
  PVector currentPoint = coords.get(currentPointIndex);
  PVector targetPoint = coords.get((currentPointIndex + 1) % coords.size());

  pausedPosition = currentPoint; // Store the current position for pausing

  PVector direction = PVector.sub(targetPoint, currentPoint);
  float rotationAngle = atan2(direction.y, direction.x);
  
  float halfWidth = boxWidth / 2.0;
  float halfHeight = boxHeight / 2.0;
  float halfDepth = boxDepth / 2.0;

  pushMatrix();
  translate(currentPoint.x, currentPoint.y, currentPoint.z + 20);
  rotateZ(rotationAngle); // Rotate the car based on the direction
  fill(colours[tab]);
  noStroke();
  pushMatrix();
  fill(155);
  box(boxWidth-10, boxHeight-10, boxDepth-10);
  popMatrix();
  if (liveries[tab]!= null) {
    texture(liveries[tab]);
    fill(colours[tab]);

    // Front face
    beginShape(QUADS);
    vertex(-halfWidth, -halfHeight, -halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, -halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, -halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, -halfDepth, 0, 1);
    endShape();

    // Back face
    beginShape(QUADS);
    vertex(-halfWidth, -halfHeight, halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, halfDepth, 0, 1);
    endShape();

    // front
    pushMatrix();
    beginShape(QUADS);
    vertex(halfWidth, -halfHeight, -halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, halfDepth, 1, 1);
    vertex(halfWidth, halfHeight, -halfDepth, 0, 1);
    endShape();
    popMatrix();

    // back
    beginShape(QUADS);
    vertex(-halfWidth, -halfHeight, -halfDepth, 0, 0);
    vertex(-halfWidth, -halfHeight, halfDepth, 1, 0);
    vertex(-halfWidth, halfHeight, halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, -halfDepth, 0, 1);
    endShape();
   
    // outside/left side
    beginShape(QUADS);
    texture(liveries[tab]);
    vertex(-halfWidth, -halfHeight, halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, halfDepth, 1, 0);
    vertex(halfWidth, -halfHeight, -halfDepth, 1, 1);
    vertex(-halfWidth, -halfHeight, -halfDepth, 0, 1);
    endShape();

    // inside/right side
    beginShape(QUADS);
    texture(liveries[tab]);
    vertex(-halfWidth, halfHeight, halfDepth, 0, 0);
    vertex(halfWidth, halfHeight, halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, -halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, -halfDepth, 0, 1);
    endShape();
  }

  popMatrix();
}

void moveCarAlongPath(int carNumber, float speed) {
  if (!isPaused) {
    if (carNumber == 1) {
      carPositionOnPath += speed;
      if (carPositionOnPath >= coords.size()) {
        carPositionOnPath = 0;
      }
    } else if (carNumber == 2) {
      carPositionOnPathCar2 += speed;
      if (carPositionOnPathCar2 >= coords.size()) {
        carPositionOnPathCar2 = 0;
      }
    }
    drawCarLivery(carNumber);
  }
}

void mouseDragged() {
  int index = 0;
  float previousZ = 0;
  float currentZ = 0;
  float nextZ = 0;
  if (isDrawing) {
    PVector point3D;
    if (coords.size() % 10 == 0) {
      if ((coords.size() != 0 || coords.size() != 1) && coords.size() -1 % 10 == 0) {
        previousZ = coords.get(index-1).z;
      }
      point3D = new PVector(mouseX, mouseY, random(-10, 10));
    } else {
      point3D = new PVector(mouseX, mouseY, 0); // Keep z-value constant
    }
    coords.add(point3D);
    index++;
  }
}

void keyPressed() {
  if (key == ' ') {
    isDrawing = !isDrawing;
  }
  // Toggle pause with the 'P' key
  if (key == 'P') {
    isPaused = !isPaused;
  }
  if (key == TAB) {
    tab = (tab + 1) % 3;  // Cycle between 0, 1, and 2 for the 3 colours so far
  }
  if (enableAPIQuery){
    //Check if the key pressed is Enter
    userInput += key;
    if (key == ENTER) {
      // Print the user input to the terminal
      println("User input: " + userInput);
      // Clear the user input for the next entry
      userInput = "";
      enableAPIQuery = false;
    }
  }
}
