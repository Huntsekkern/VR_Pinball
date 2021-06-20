// A simple Particle class
class Particle {
  PVector center;
  float radius;
  float lifespan;
  
  Particle(PVector center, float radius) {
    this.center = center.copy();
    this.lifespan = 255;
    this.radius = radius;
  }
  
  void run() {
    update();
    display();
  }
  
  // Method to update the particle's remaining lifetime
  void update() {
   //lifespan -= 1;
  }
  
  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    circle(center.x, center.y, 2*radius);
  }
  
  // Is the particle still useful?
  // Check if the lifetime is over.
  boolean isDead() {
    return lifespan <= 0;
  }
}
