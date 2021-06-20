// A class to describe a group of Particles
class ConfettiSystem {
  ArrayList<Confetti> confettis;
  PVector origin;
  float confettiRadius = 5;
  int amountSpawn = 600;

  ConfettiSystem(PVector origin) {
    this.origin = origin.copy();
    confettis = new ArrayList<Confetti>();
    confettis.add(new Confetti(origin, confettiRadius));
  }

  void addConfetti() {
    PVector center;


    // Pick a cylinder and its center.
    //center = confettis.get(index).center.copy();
    center = origin;
    // Try to add an adjacent cylinder.
    float angle = random(TWO_PI);
    center.x += sin(angle) * 5*confettiRadius;
    center.y += cos(angle) * 5*confettiRadius;
    confettis.add(new Confetti(center, confettiRadius));
  }

  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  boolean checkPosition(PVector center) {
    for (int i=0; i < confettis.size(); ++i) {
      if (checkOverlap(center, confettis.get(i).center)) {
        return false;
      }
    }
    return true;
  }

  // Check if a particle with center c1
  // and another particle with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2) {
    return (PVector.sub(c1, c2)).mag() < 2*confettiRadius;
  }

  // Iteratively update and display every particle,
  // and remove them from the list if their lifetime is over.
  void run() {
    if ((frameCount * 40) % frameRate == 0) {
      for (int i = 0; i<8; ++i) {
        addConfetti();
        amountSpawn -= 1;
      }
      if (amountSpawn <= 0) {
        won = false;
      }
    }
    for (int i = 0; i < confettis.size(); ++i) {
      confettis.get(i).run();
      if (confettis.get(i).isDead()) {
        confettis.remove(i);
      }
    }
  }
}
