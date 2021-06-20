class Ball {
  
  final static float ballSize = 20;
  PVector location;
  PVector velocity;
  float facteurRebond = 0.8;
  PVector frott; float mu = 0.015, normalMagn = 1, frottMagn = 0;
  
  Ball() {
    location = new PVector(0, 0);
    velocity = new PVector(0, 0);
    frott = new PVector(0,0);
  }

  void update() {
    frottMagn = normalMagn * mu;
    frott = velocity.copy().normalize().mult(-frottMagn);
    velocity.add(grav);
    velocity.add(frott);
    location.add(velocity);
  }
  void display() {
    gameSurface.fill(127);
    gameSurface.sphere(ballSize);
  }
  
  void checkEdges() {
    if (location.x > boxSize/2 - ballSize) {
      location.x = boxSize/2 - ballSize;
      velocity.x = (velocity.x - grav.x) * -facteurRebond;
    } else if (location.x < -boxSize/2 + ballSize) {
      location.x = -boxSize/2 + ballSize;
      velocity.x = (velocity.x - grav.x) * -facteurRebond;
    }
    
    if (location.y >  boxSize/2 - ballSize) {
      location.y =  boxSize/2 - ballSize;
      velocity.y = (velocity.y - grav.y) * -facteurRebond;
    } else if (location.y <  -boxSize/2 + ballSize) {
      location.y =  -boxSize/2+ballSize;
      velocity.y = (velocity.y - grav.y) * -facteurRebond;
    }
  }
  
  BandPV checkCylinderCollision() {
    PVector norm;
   for(int i = 0; i < cylinders.size(); ++i) {
    PVector cLoc2D = new PVector(cylinders.get(i).x, cylinders.get(i).y);
    
    if(PVector.sub(location, cLoc2D).mag() < ballSize + Cylinder.cylinderBaseSize) {

      norm = PVector.sub(location, cLoc2D).normalize();

      //velocity.x = -velocity.x;
      //velocity.y = -velocity.y;
      velocity = PVector.sub(velocity , PVector.mult(norm,(2*(PVector.dot(velocity, norm)))));
      // compute with cos?
      location = PVector.add(cLoc2D, PVector.mult(norm, (ballSize + Cylinder.cylinderBaseSize)));
      return new BandPV(true, cLoc2D);
    }
   }
    return new BandPV(false, null);
  }
}
