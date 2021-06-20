// A simple Particle class
class Confetti {
  PVector center;
  float radius;
  float lifespan;
  int red;
  int green;
  int blue;
  PVector acc = new PVector(0, 0.2);
  PVector downer = new PVector(0, 0);


  Confetti(PVector center, float radius) {
    this.center = center.copy();
    this.lifespan = 255;
    this.radius = radius;
    this.red = (int)random(20, 230);
    this.green = (int)random(20, 230);
    this.blue = (int)random(20, 230);
  }

  void run() {
    update();
    display();
  }

  // Method to update the particle's remaining lifetime
  void update() {
    lifespan -= 2;
    downer.add(acc);
    center.add(downer);    
  }

  // Method to display
  void display() {
    stroke(red, green, blue, lifespan);
    fill(red, green, blue, 255);
    circle(center.x, center.y, 2*radius);
  }

  // Is the particle still useful?
  // Check if the lifetime is over.
  boolean isDead() {
    return lifespan <= 0;
  }
}
