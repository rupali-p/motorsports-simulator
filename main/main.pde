import peasy.*;
PeasyCam cam;

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
float speed; 
int tab;

color[] colours = new color[3];


void setup() {
  size(800, 600, P3D);
  background(155);
  colours[0] = color(255, 0, 0);  // Red
  colours[1] = color(1, 119, 140);  // Aston Martin
  colours[2] = color(255, 165, 0); // Orange
  
  cam = new PeasyCam(this, width/2, height/2, 0, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  camPosition = new PVector(width, height, 0);
}

void draw() {
  background(155);
  if (isDrawing) {
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
  }else if (coords.size() >= 20) {
    drawGlowingCircle();
    drawPath3D();
    moveCarAlongPath();
  }
}

void drawPath3D() {
  noFill();
  stroke(1);
  strokeWeight(20);  
  
  beginShape();
  for (PVector point3D : coords) {
    vertex(point3D.x, point3D.y, point3D.z);
  }
  endShape();
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

void drawCarLivery() {
  int currentPointIndex = (int) carPositionOnPath;
  PVector currentPoint = coords.get(currentPointIndex);
  PVector targetPoint = coords.get((currentPointIndex + 1) % coords.size());

  pausedPosition = currentPoint; // Store the current position for pausing
  speed = 0.2; 
  PVector direction = PVector.sub(targetPoint, currentPoint);
  float rotationAngle = atan2(direction.y, direction.x);

  int currentPointIndexCar2 = (int) carPositionOnPathCar2;
  PVector currentPointCar2 = coords.get(currentPointIndexCar2);
  PVector targetPointCar2 = coords.get((currentPointIndexCar2 + 1) % coords.size());

  pausedPositionCar2 = currentPointCar2; // Store the current position for pausing

  PVector directionCar2 = PVector.sub(targetPointCar2, currentPointCar2);
  float rotationAngleCar2 = atan2(directionCar2.y, directionCar2.x);

  float halfWidth = boxWidth / 2.0;
  float halfHeight = boxHeight / 2.0;
  float halfDepth = boxDepth / 2.0;

  pushMatrix();
  translate(currentPoint.x, currentPoint.y, currentPoint.z + 20);
  rotateZ(rotationAngle); // Rotate the car based on the direction
  fill(colours[tab]);
  noStroke();

  // Draw the car body
  drawCarBody();

  popMatrix();

  pushMatrix();
  translate(currentPointCar2.x, currentPointCar2.y, currentPointCar2.z + 20);
  rotateZ(rotationAngleCar2); // Rotate the second car based on the direction
  fill(colours[tab]);
  noStroke();
  popMatrix();
}

void drawCarBody() {
  float halfWidth = boxWidth / 2.0;
  float halfHeight = boxHeight / 2.0;
  float halfDepth = boxDepth / 2.0;

  if (colours != null) {
    fill(colours[tab]);

    // Front face
    beginShape(QUADS);
    //textureWrap(REPEAT);
    vertex(-halfWidth, -halfHeight, -halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, -halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, -halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, -halfDepth, 0, 1);
    endShape();

    // Back face
    beginShape(QUADS);
    //textureWrap(REPEAT);
    vertex(-halfWidth, -halfHeight, halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, halfDepth, 0, 1);
    endShape();

    // Side faces
    beginShape(QUADS);
    //textureWrap(REPEAT);
    vertex(-halfWidth, -halfHeight, -halfDepth, 0, 0);
    vertex(halfWidth, -halfHeight, -halfDepth, 1, 0);
    vertex(halfWidth, -halfHeight, halfDepth, 1, 1);
    vertex(-halfWidth, -halfHeight, halfDepth, 0, 1);
    endShape();

    beginShape(QUADS);
    //textureWrap(REPEAT);
    vertex(-halfWidth, halfHeight, -halfDepth, 0, 0);
    vertex(halfWidth, halfHeight, -halfDepth, 1, 0);
    vertex(halfWidth, halfHeight, halfDepth, 1, 1);
    vertex(-halfWidth, halfHeight, halfDepth, 0, 1);
    endShape();
  }
}

void moveCarAlongPath() {
  if (!isPaused) {
    speed = 0.2;
    carPositionOnPath += speed;
    carPositionOnPathCar2 += speed;

    if (carPositionOnPath >= coords.size()) {
      carPositionOnPath = 0;
    }
    
    if (carPositionOnPathCar2 >= coords.size()) {
      carPositionOnPathCar2 = 0;
    }
    drawCarLivery();
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
      if ((coords.size() != 0 || coords.size() != 1) && coords.size() -1 % 10 == 0){
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
