boolean drawCircuit = true;
ArrayList<int[]> circuitCoord;
int glowSize = 50; // Size of the glowing circle
int glowAlpha = 20; // Reduced alpha (transparency) of the glowing circle

void setup() {
  size(900, 600, P3D);
  background(155);
  circuitCoord = new ArrayList<int[]>();
}

void draw() {
  if (drawCircuit) {
    stroke(10);
    if (mousePressed) {
      int[] coord = {mouseX, mouseY};
      circuitCoord.add(coord);
    }

    if (circuitCoord.size() >= 20) {
      int[] firstCoord = circuitCoord.get(0);
      int[] lastCoord = circuitCoord.get(circuitCoord.size() - 1);

      // Calculate the distance between the first and last coordinates
      float distance = dist(firstCoord[0], firstCoord[1], lastCoord[0], lastCoord[1]);

      // Display the circuit design if the user is near the starting coordinates
      if (distance < glowSize/1.5) {
        noLoop(); // Stop further drawing
        drawCircuit = false;
        showCircuitDesign();
      }
    }
  }
  drawGlowingCircle();
}

void showCircuitDesign() {
  background(155);
  if (circuitCoord.size() >= 2) {
    for (int i = 1; i < circuitCoord.size(); i++) {
      int[] startCoord = circuitCoord.get(i - 1);
      int[] endCoord = circuitCoord.get(i);
      line(startCoord[0], startCoord[1], endCoord[0], endCoord[1]);
    }

    // Draw a line connecting the last and first points to close the circuit
    int[] firstCoord = circuitCoord.get(0);
    int[] lastCoord = circuitCoord.get(circuitCoord.size() - 1);
    line(firstCoord[0], firstCoord[1], lastCoord[0], lastCoord[1]);
  }
}

void drawGlowingCircle() {
  if (!circuitCoord.isEmpty()) {
    int[] firstCoord = circuitCoord.get(0);
    fill(255, 0, 0, glowAlpha); // Red circle with reduced transparency
    noStroke();
    ellipse(firstCoord[0], firstCoord[1], glowSize, glowSize);
  }
}

void mousePressed() {
  if (drawCircuit) {
    loop(); // Resume drawing
    background(155); // Clear the background
    circuitCoord.clear(); // Clear the coordinates
  }
}
