class Drink {
  float x, y; // X-coordinate, y-coordinate
  float easing = 0.05;
  boolean followSlider = false;
  
  Drink(float xpos, float ypos) {
    x = xpos;
    y = ypos;
  }


  void display() {
    stroke(153);
    fill(#819DCB);
    pushMatrix();
    translate(x, y);
    //    rotate(tilt);
    //    scale(scalar);
    beginShape();
    noFill();
strokeWeight(6.0);
strokeJoin(ROUND);

    vertex(0, 0);
    vertex(5, 50);
    vertex(35, 50);
    vertex(40, 0);
    endShape();
    popMatrix();
  }
}

