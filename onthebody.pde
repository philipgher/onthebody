import processing.serial.*;
import processing.video.*;
import java.io.*;
import processing.sound.*;

SoundFile dontbeshycomeCloser;
SoundFile hithere;
SoundFile ienjoymeetingnewpeople;
SoundFile wecanshareanexperience;
SoundFile doyouagreetoseewhatsnext;
SoundFile standinfrontofthelightandpressthebuttontostart;

int timer = 0;
float playTime;
int musicPlayer;

Serial myPort;  // Create object from Serial class

String val;     // Data received from the serial port
Capture camL;
PImage img;
PImage camLLastFrame;
String photoCounter = "0";

int cellsize = 4;           // Dimensions of each cell in the grid
int columns, rows;          // Number of columns and rows in our system
int aniPos = 40000;         // Positie van pixel animatie, deze waarde wordt alleen voor de eerste cycle gebruikt
int aniStartPos = 40000;    // Startpositie van de animatie, het punt waarop de animatie weer terug gaat naar het middelpunt
int aniSpeedFast = 70;
int aniSpeedMedium = 40;
int aniSpeedSlow = 10;
int aniSpeedSuperSlow = 5;
boolean direction = true;   // True is pixels naar elkaar, false van elkaar af

void setup() {
  fullScreen(P3D);
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i +" " +cameras[i]);
  }
 
  myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600); // "/dev/cu.usbmodem1421" = rechter usb poort, "/dev/cu.usbmodem1422" = linker (op macbook van Philip)
  
  img = loadImage("0_Big.jpg");                            // Deze eerste afbeelding moet aanwezig zijn in de map data
  img.resize(600, 375);                                    // De grootte werkt goed op eerste scherm (moet variabel gemaakt worden)
  img.save("data/"+photoCounter+".jpg");
  img = loadImage("data/"+photoCounter+".jpg");
  columns = img.width / cellsize;                          // Calculate # of columns
  rows = img.height / cellsize;                            // Calculate # of rows

  camL = new Capture(this, cameras[15]);                   // 15 = HD camera van Tim, check welke camera je moet hebben in console
  camL.start();
  
  dontbeshycomeCloser = new SoundFile(this, "./sound/dontbeshycomecloser.mp3");
  hithere = new SoundFile(this, "./sound/hitherehowareyou.mp3");
  ienjoymeetingnewpeople = new SoundFile(this, "./sound/ienjoymeetingnewpeople.mp3");
  wecanshareanexperience = new SoundFile(this, "./sound/wecanshareanexperiance.mp3");
  doyouagreetoseewhatsnext = new SoundFile(this, "./sound/doyouagreetoseewhatnext_.mp3");
  standinfrontofthelightandpressthebuttontostart = new SoundFile(this, "./sound/standinfrontofthelightandpressthebuttontostart.mp3");
}

void draw() {
  readPort();
  playSound();
  explode();
}

void playSound() {
  if (timer == 0) playTime = int(random(300, 400));   // Interval tussen fragmenten randomizen
  timer++;
  if (timer == playTime) {
    timer = 0;                               // Reset timer voor nieuwe interval
    //musicPlayer = int(random (0, 5));      // Om alle tekstjes af te spelen, was niet zo'n goed idee
    musicPlayer = 5;                         // 5 = instructie fragment
    println("playsound");
    switch (musicPlayer) {
      case 0:
        dontbeshycomeCloser.play();
      break;
      case 1:
        hithere.play();
      break;
      case 2:
        ienjoymeetingnewpeople.play();
      break;
      case 3:
        wecanshareanexperience.play();
      break;
      case 4:
        doyouagreetoseewhatsnext.play();
      break;
      case 5:
        standinfrontofthelightandpressthebuttontostart.play();
      break;
    }
  }
}

int counter = 0;
void readPort() {
  if ( myPort.available() > 0) {
    val = myPort.readStringUntil('\n');      // Lees continu de poort uit
  }
  if (val != null) {                         // Nullpointer exeption voorkomen
    if (val.contains("1") || val == "1") {   // Als de knop is ingedrukt
      counter++;                             // Om herhaal foto's te voorkomen
      if (counter == 1) buttonPressed();
    } else counter = 0;
  }
}

void explode() {
  if (aniPos < -100 || aniPos >= aniStartPos) { // Om heen en weer te animeren
    direction = !direction;
  }
  
  if (direction == true) {          // naar middelpunt
    if (aniPos < 0) {
      aniPos-=aniSpeedSuperSlow;
    } else if (aniPos < 3000) {
      aniPos-=aniSpeedSlow;
    } else if (aniPos < 5000) {
      aniPos-=aniSpeedMedium;
    } else  {
      aniPos-=aniSpeedFast;
    }
  }
  
  if (direction == false) {       // van middelpunt af
    if (aniPos > -200) {
      aniPos+=aniSpeedSuperSlow;
    } else if (aniPos > 3000) {
      aniPos+=aniSpeedSlow;
    } else if (aniPos > 5000) {
      aniPos+=aniSpeedMedium;
    } else if (aniPos > 10000) {
      aniPos+=aniSpeedFast+50;
    }
  }
  
  background(0);
  for ( int i = 0; i < columns; i++) {
    for ( int j = 0; j < rows; j++) {
      int x = i*cellsize + cellsize/2;            // x position
      int y = j*cellsize + cellsize/2;            // y position
      int loc = x + y*img.width;                  // Pixel array location
      color c = img.pixels[loc];                  // Grab the color
      float z = (aniPos / float(width)) * brightness(img.pixels[loc]) - 20.0;   // Translate to the location, set fill and stroke, and draw the rect
      pushMatrix();
      translate(x + 660, y + 412, z);
      fill(c, 204);
      noStroke();
      rectMode(CENTER);
      rect(0, 0, cellsize, cellsize);
      popMatrix();
    }
  }
}

void buttonPressed() {
    camL.read();                                             // Lees camerabeeld
    background(0);                                           // Schoon scherm
    image(camL, 0, 0, width, height);                        // Toon camerabeeld op scherm voor super kort, op de achtergrond beeld afvangen werkt niet door P3D
    photoCounter = ""+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second(); // Unieke naamgeving
    saveFrame("data/"+photoCounter+"_Big.jpg");              // Maak screenshot van gehele scherm
    img = loadImage("data/"+photoCounter+"_Big.jpg");        // Grote screenshot inladen op scherm
    img.resize(600, 375);                                    // Maak afbeelding kleiner en sla opnieuw op
    img.save("data/"+photoCounter+".jpg");
    img = loadImage("data/"+photoCounter+".jpg");            // Laad afbeelding opnieuw in
    aniPos = aniStartPos;                                    // Reset animatie positie
    direction = true;                                        // Reset richting
}

void keyPressed() {
  if (keyCode == 32) {                                       // 32 = spatiebalk
    buttonPressed();
  }
}