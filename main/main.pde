ArrayList<PVector> coords = new ArrayList<PVector>();
boolean isDrawing = true;
int glowSize = 50; // Size of the glowing circle
int glowAlpha = 20; // Reduced alpha (transparency) of the glowing circle

void setup() {
  size(800, 600, P3D);
  background(155);
}

void draw() {
  background(155);
  if (isDrawing) {
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
     }else if (coords.size() >= 20) {
      drawPath3D();
     }
  }
  drawGlowingCircle();
  drawPath3D();
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
