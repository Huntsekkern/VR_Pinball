// A class to describe a group of Particles
class ParticleSystem {
  PVector origin;
  boolean running;

  ParticleSystem(PVector origin) {
    this.origin = origin.copy();
    if (checkPosition(origin)) {
      cylinders.add(origin);
      running = true;
      score = 0;
      lastScore = 0;
      listOfScore.clear();
      won = false;
    }
  }

  void addParticle() {
    PVector center;
    int numAttempts = 100;

    for (int i=0; i<numAttempts; i++) {
      // Pick a cylinder and its center.
      int index = int(random(cylinders.size()));
      center = cylinders.get(index).copy();
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*Cylinder.cylinderBaseSize;
      center.y += cos(angle) * 2*Cylinder.cylinderBaseSize;
      if (checkPosition(center)) {
        cylinders.add(center);
        break;
      }
    }
  }

  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  boolean checkPosition(PVector center) {
    for (int i=0; i < cylinders.size(); ++i) {
      if (checkOverlap(center, cylinders.get(i))) {
        return false;
      }
    }
    if (checkOutOfBoundaries(center)) {
      return false;
    }
    return (PVector.sub(center, ball.location)).mag() > Cylinder.cylinderBaseSize+Ball.ballSize;
  }

  boolean checkOutOfBoundaries(PVector center) {
    if (center.x > boxSize/2 - Cylinder.cylinderBaseSize
      || center.x < -boxSize/2 + Cylinder.cylinderBaseSize
      || center.y >  boxSize/2 - Cylinder.cylinderBaseSize
      || center.y <  -boxSize/2 + Cylinder.cylinderBaseSize) {
      return true;
    }
    return false;
  }

  // Check if a particle with center c1
  // and another particle with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2) {
    return (PVector.sub(c1, c2)).mag() < 2*Cylinder.cylinderBaseSize;
  }

  // Iteratively update and display every particle,
  // and remove them from the list if their lifetime is over.
  void run() {
    if (running) {
      if ((frameCount * 2) % frameRate == 0 && mode == 0) {
        addParticle(); 
        lastScore = -10;
        score += lastScore;
        listOfScore.add(score);
      }

      BandPV bpv = ball.checkCylinderCollision();
      if ((boolean)bpv.b) {
        cylinders.remove(bpv.pv);
        lastScore = 5*ball.velocity.mag();
        score += lastScore;
        listOfScore.add(score);
        if (bpv.pv.equals(origin)) {
          cylinders.clear();
          running = false;
          cs = new ConfettiSystem(new PVector(800, 200, 450));

          won = true;
        }
      }
    }
  }
}
