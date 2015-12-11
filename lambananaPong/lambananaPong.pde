import oscP5.*;
import netP5.*;

OscP5 oscP5;

final int STATE_PLAYING = 0;
final int STATE_OVER = 1;

final int MAX_SCORE = 10;
final int PAD_WIDTH = 33;
final int PAD_HEIGHT = 100;

final int BALL_RADIUS = 8;

int currentState;

PVector ballPos;
PVector ballVel;

PImage lambanana;
PImage lambanana2;
PImage[] ballImage;

// positions X e Y for the Pad
PVector padPos;
PVector[] padObj;

PVector pad2Pos;
PVector[] pad2Obj;

int score;
int score2;

void setup() {
  size(700, 500);
  oscP5 = new OscP5(this, 12000);

  ballPos = new PVector(width/2, height/2, BALL_RADIUS);
  ballVel = new PVector(5, 5);

  lambanana = loadImage("lambanana.png");
  lambanana.resize(100, 0);

  lambanana2 = loadImage("lambanana2.png");
  lambanana2.resize(100, 0);

  ballImage = new PImage[36];
  for (int i=0; i<ballImage.length; i++) {
    ballImage[i] = loadImage("flame/tmp-"+i+".gif");
    ballImage[i].resize(100, 0);
  }

  //initial positon for the pad
  // x fixed, y will be dynamic
  padPos = new PVector(10, height/2);
  padObj = new PVector[8];
  padObj[0] = new PVector(80, 48, 14);
  padObj[1] = new PVector(60, 70, 15);
  padObj[2] = new PVector(70, 90, 8);
  padObj[3] = new PVector(55, 95, 8);
  padObj[4] = new PVector(56, 45, 8);
  padObj[5] = new PVector(32, 55, 18);
  padObj[6] = new PVector(16, 28, 12);
  padObj[7] = new PVector(30, 84, 12);

  pad2Pos = new PVector(width - lambanana2.width - 10, height/2);
  pad2Obj = new PVector[8];
  int magicXNumber = 100;
  pad2Obj[0] = new PVector(magicXNumber-80, 48, 14);
  pad2Obj[1] = new PVector(magicXNumber-60, 70, 15);
  pad2Obj[2] = new PVector(magicXNumber-70, 90, 8);
  pad2Obj[3] = new PVector(magicXNumber-55, 95, 8);
  pad2Obj[4] = new PVector(magicXNumber-56, 45, 8);
  pad2Obj[5] = new PVector(magicXNumber-32, 55, 18);
  pad2Obj[6] = new PVector(magicXNumber-16, 28, 12);
  pad2Obj[7] = new PVector(magicXNumber-30, 84, 12);

  score = 0;
  score2 = 0;

  currentState = STATE_PLAYING;
}

void draw() {
  if (currentState == STATE_PLAYING) {
    background(255, 255, 255);

    // here is adding the increment velocity to the position
    ballPos.add(ballVel);

    padPos.y = height-mouseY;
    pad2Pos.y = mouseY;

    // checking if position X is bigger than the width of the screen

    if (ballPos.x >= width) {
      ballPos.x = width/2;
      ballPos.y = height/2;
      score = score + 1;
      ballVel.x = ballVel.x * -1;
    }
    //checking if position X is smaller than the 0 of the screen 
    if (ballPos.x <= 0) {
      ballPos.x = width/2;
      ballPos.y = height/2;
      score2 = score2 + 1;
      ballVel.x = ballVel.x * -1;
    }

    //checking if position Y is bigger than the height of the screen
    if (ballPos.y >= height || ( ballPos.y <= 0)) {
      ballVel.y = ballVel.y * -1;
    }

    for (int i=0; i<padObj.length; i++) {
      PVector absoluteObjPos = PVector.add(padPos, padObj[i]);
      if (ballPos.dist(absoluteObjPos) < ballPos.z+padObj[i].z) {
        ballVel.x = ballVel.x * -1;
        ballVel.y = ballVel.y * -1;
        break;
      }
    }

    for (int i=0; i<pad2Obj.length; i++) {
      PVector absoluteObjPos = PVector.add(pad2Pos, pad2Obj[i]);
      if (ballPos.dist(absoluteObjPos) < ballPos.z+pad2Obj[i].z) {
        ballVel.x = ballVel.x * -1;
        ballVel.y = ballVel.y * -1;
      }
    }

    // calling functions to draw the objects
    drawBallImage(ballPos, ballVel);
    drawPadImage(padPos, lambanana, padObj);
    drawPadImage(pad2Pos, lambanana2, pad2Obj);

    // code to draw the score on screen
    textSize(32);
    fill(0);
    text(score, 10, 30);
    text(score2, width-40, 30);

    if (score >= MAX_SCORE || score2 >= MAX_SCORE) {
      currentState = STATE_OVER;
    }
  } else if (currentState == STATE_OVER) {
    if (mousePressed == true) {
      currentState = STATE_PLAYING;
      score = 0;
      score2 = 0;
    }

    background(0, 0, 0);
    textSize(64);
    fill(200, 0, 0);
    text("GAME OVER", 30, height/2);
    if (score >= MAX_SCORE) {
      textSize(32);
      text("player 1 wins", 30, height/2+70);
    } else {
      textSize(32);
      text("player 2 wins", 30, height/2+70);
    }
  }
}

void drawPad(PVector pos, PVector[] obj) {
  pushMatrix();
  translate(pos.x, pos.y);
  fill(255, 0, 0);
  rect(0, 0, PAD_WIDTH, PAD_HEIGHT);
  fill(0, 0, 255);
  for (int i=0; i<obj.length; i++) {
    ellipse(obj[i].x, obj[i].y, 2*obj[i].z, 2*obj[i].z);
  }
  popMatrix();
}

void drawBallImage(PVector pos, PVector vel) {
  pushMatrix();
  translate(pos.x, pos.y);
  rotate(vel.heading()-PI/2);
  translate(-ballImage[0].width/2, -ballImage[0].height);
  image(ballImage[(frameCount/2)%ballImage.length], 0, 0);
  popMatrix();
  fill(255,127,80);
  stroke(255,127,80);
  ellipse(pos.x, pos.y, 2*ballPos.z, 2*ballPos.z);
}

void drawPadImage(PVector pos, PImage img, PVector[] obj) {
  pushMatrix();
  translate(pos.x, pos.y);
  fill(255, 0, 0);
  image(img, 0, 0);
  fill(0, 0, 255, 100);
  popMatrix();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //print(" typetag: "+theOscMessage.typetag());
  if (theOscMessage.addrPattern().equals("/1/fader1")) {
    padPos.y = map(theOscMessage.get(0).floatValue(), 0, 1, height, 0);
  }
  if (theOscMessage.addrPattern().equals("/1/fader1")) {
    pad2Pos.y = map(theOscMessage.get(0).floatValue(), 0, 1, height, 0);
  }
}