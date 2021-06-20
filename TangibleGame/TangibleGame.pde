import processing.video.*;

Ball ball;
Cylinder cylin;
ParticleSystem ps;
PShape robotnik;
PGraphics gameSurface;
PGraphics scoreSurface;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;
HScrollbar scrollBar;
ConfettiSystem cs;
ImageProcessing imgproc;

PVector grav;
int windowWidth = 1400;
int windowHeight = 900;
int scoreBoardHeight = 300;
int barChartWidth = windowWidth - scoreBoardHeight*2 - 50;

static int frameRate = 60;
float score = 0;
float lastScore = 0;
float maxScore = 100;
ArrayList<Float> listOfScore = new ArrayList();
boolean won = false;

void settings() {
  size(windowWidth, windowHeight, P3D);
}

void setup() {
  frameRate(frameRate);
  noStroke();
  ball = new Ball();
  grav = new PVector(0, 0);
  cylin = new Cylinder();
  robotnik = loadShape("robotnik.obj");
  gameSurface = createGraphics(width, height-scoreBoardHeight, P3D);
  scoreSurface = createGraphics(width, scoreBoardHeight, P3D);
  topView = createGraphics(scoreBoardHeight, scoreBoardHeight, P2D);
  scoreBoard = createGraphics(scoreBoardHeight, scoreBoardHeight, P2D);
  barChart = createGraphics(barChartWidth, scoreBoardHeight, P2D);
  scrollBar = new HScrollbar(scoreBoardHeight*2 + 40, height - 20, barChartWidth, 10);

  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
}

float depth = 800;
final static float boxSize = 500, heightB = 20;
float rx = 0, rz = 0, rotateSpeedFactor = 0.01, decalageX = 0, decalageZ = 0;
int mode = 0;
ArrayList<PVector> cylinders = new ArrayList();

//new variable for rotation detected on image
PVector rot;

void draw() {
  drawGame();
  image(gameSurface, 0, 0);  
  drawScoreSurface();
  image(scoreSurface, 0, height-scoreBoardHeight);
  drawTopView();
  image(topView, 0, height-scoreBoardHeight);
  drawScoreBoard();
  image(scoreBoard, scoreBoardHeight + 20, height-scoreBoardHeight);
  drawBarChart();
  image(barChart, scoreBoardHeight*2 + 40, height-scoreBoardHeight);
  scrollBar.update();
  scrollBar.display();
  
  rot = imgproc.getRotation();
  //System.out.println("Rot : "+rot.x +" "+rot.y+" "+rot.z);
  updateAnglesWithVideo();
}

void drawGame() {  
  gameSurface.beginDraw();
  if (mode == 0) {
    update();
    gameSurface.camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  } else if (mode == 1) {
    gameSurface.camera(width/2, height/2, depth, width/2, height/2, 0, 1, 0, 0);
  }
  gameSurface.directionalLight(50, 100, 125, 0, -1, 0);
  gameSurface.ambientLight(102, 102, 102);
  gameSurface.background(125);
  gameSurface.translate(width/2, height/2, 0);

  if (mode == 0) {
    gameSurface.rotateX(rx);
    gameSurface.rotateZ(rz);
  } else if (mode == 1) {
    gameSurface.rotateX(-PI/2); 
    gameSurface.rotateY(PI/2);
  }
  gameSurface.fill(255);
  gameSurface.box(boxSize, heightB, boxSize);



  gameSurface.pushMatrix();
  if (mode == 0) {
    ball.update();
  }
  ball.checkEdges();

  if (ps != null) {
    ps.run();
  }
  gameSurface.translate(ball.location.x, -(heightB/2 + Ball.ballSize), ball.location.y);
  ball.display();
  gameSurface.popMatrix();

  for (int i = 0; i < cylinders.size(); ++i) {
    gameSurface.pushMatrix();
    gameSurface.rotateX(PI/2);
    gameSurface.translate(cylinders.get(i).x, cylinders.get(i).y, heightB/2);
    gameSurface.shape(cylin.openCylinder);
    gameSurface.shape(cylin.topCylinder);
    gameSurface.shape(cylin.bottomCylinder);
    if (i==0) {
      gameSurface.pushMatrix();
      gameSurface.translate(0, 0, Cylinder.cylinderHeight);
      gameSurface.scale(90);
      gameSurface.rotateX(PI/2);
      float xdiff = (ball.location.x - cylinders.get(i).x);
      float zdiff = (ball.location.y - cylinders.get(i).y);
      float angle = atan(xdiff/zdiff);
      if (zdiff > 0) angle += PI;
      gameSurface.rotateY(-angle);
      gameSurface.shape(robotnik);
      gameSurface.popMatrix();
    }
    gameSurface.popMatrix();
  }

  if (won) {
    cs.run();
  }

  gameSurface.endDraw();
}

void drawScoreSurface() {
  scoreSurface.beginDraw();
  scoreSurface.background(155);
  scoreSurface.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(100, 200, 25);

  //ball
  topView.fill(0);
  topView.ellipse(map(ball.location.x, -boxSize/2, boxSize/2, 0, scoreBoardHeight), map(ball.location.y, -boxSize/2, boxSize/2, 0, scoreBoardHeight), 25, 25);

  for (int i = 0; i < cylinders.size(); ++i) {
    //color = blue
    topView.fill(0, 0, 255);
    if (i==0) {
      topView.fill(255, 0, 0);
    }
    topView.ellipse(map(cylinders.get(i).x, -boxSize/2, boxSize/2, 0, scoreBoardHeight), map(cylinders.get(i).y, -boxSize/2, boxSize/2, 0, scoreBoardHeight), 60, 60);
  }
  topView.endDraw();
}


void drawScoreBoard() {
  scoreBoard.beginDraw();
  scoreBoard.background(200);
  scoreBoard.textSize(20);
  scoreBoard.fill(0);
  scoreBoard.text("Total Score:", 10, 20);
  scoreBoard.text(score, 10, 50);
  scoreBoard.text("Velocity:", 10, 80);
  scoreBoard.text(ball.velocity.mag(), 10, 110);
  scoreBoard.text("Last Score:", 10, 140);
  scoreBoard.text(lastScore, 10, 170);
  scoreBoard.endDraw();
}

int widthRect = 5, heightRect = 5;
float x1 = 0, y1= scoreBoardHeight/2;

void drawBarChart() {
  barChart.beginDraw();

  widthRect = (int) map(scrollBar.getPos(), 0, 1, 2, 20);

  if ((frameCount * 2) % frameRate == 0 && mode == 0) {
    barChart.background(220);
    for (int i = 0; i < listOfScore.size(); ++i) {
      int x = i*widthRect;
      int nbRect = listOfScore.get(i).intValue() / heightRect;
      for (int j = 0; j < nbRect; ++j) {
        barChart.rect(x1 + x, y1 - (j+1)*heightRect, widthRect, heightRect);
      }
      for (int j = 0; j > nbRect; --j) {
        barChart.rect(x1 + x, y1 - j*heightRect, widthRect, heightRect);
      }
    }
    barChart.line(x1, y1, barChartWidth, y1);
  }
  barChart.endDraw();
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }
    if (keyCode == SHIFT) {
      mode = 1;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      mode = 0;
    }
  }
}

void mouseWheel(MouseEvent e) {
  if (e.getCount() <0) {
    rotateSpeedFactor += 0.001;
    if (rotateSpeedFactor > 0.1) {
      rotateSpeedFactor = 0.1;
    }
  } else {
    rotateSpeedFactor -= 0.001;
    if (rotateSpeedFactor < 0.001) {
      rotateSpeedFactor = 0.001;
    }
  }
}

float xInst =0;
float yInst =0;

void mousePressed() {
  if (mode == 0) {
    decalageX = rx;
    decalageZ = rz;
    xInst = mouseX;
    yInst = mouseY;
  } else if (mode == 1) {
    if (mouseX > (width - boxSize)/2 + Cylinder.cylinderBaseSize 
      && mouseX < (width + boxSize)/2 - Cylinder.cylinderBaseSize
      && mouseY > (height - scoreBoardHeight - boxSize)/2 + Cylinder.cylinderBaseSize
      && mouseY < (height - scoreBoardHeight + boxSize)/2 - Cylinder.cylinderBaseSize) {
      cylinders.clear();
      float scaling = 1.5;
      ps = new ParticleSystem(new PVector((mouseX - width/2)*scaling, (mouseY - (height-scoreBoardHeight)/2)*scaling));
    }
  }
}

void mouseDragged() {
  if (mode == 0) {
    rz = (mouseX-xInst)*rotateSpeedFactor + decalageZ;
    rx = -(mouseY - yInst)*rotateSpeedFactor + decalageX;
    if (rz <-PI/3) {
      rz = -PI/3;
    } else if (rz>PI/3) {
      rz = PI/3;
    }
    if (rx >PI/3) {
      rx = PI/3;
    } else if (rx<-PI/3) {
      rx = -PI/3;
    }
  }
}
//////////////////////////////////////////////////////////////////////
//  new code
void updateAnglesWithVideo(){
  if(mode == 0 && rot != null && !rot.equals(new PVector(0f,0f,0f))){
    rz= rot.z;
    rx = rot.x;
    if (rz <-PI/3) {
      rz = -PI/3;
    } else if (rz>PI/3) {
      rz = PI/3;
    }
    if (rx >PI/3) {
      rx = PI/3;
    } else if (rx<-PI/3) {
      rx = -PI/3;
    }
  }
}
//////////////////////////////////////////////////////////////////////

float gravCste = 0.4;

void update() {
  grav.x = sin(rz) * gravCste;
  grav.y = -sin(rx) * gravCste;
}

// stackOverflow
public class BandPV<Boolean, PVector> { 
  public final Boolean b; 
  public final PVector pv; 
  public BandPV(Boolean b, PVector pv) { 
    this.b = b; 
    this.pv = pv;
  }
} 
