import processing.serial.*;
import processing.sound.*;

Serial port;
AudioDevice device;
SoundFile[] sounds;
SinOsc sine;    

int sensorReading;
int BPM;
int[] wavePoints;
boolean beat = false;
int selectedSound = 1;
float pitch = 1;
color red = #EE0000;
color bgOverlayColor = 0;

void setup() {
  findArduino();
  initSound();
  size(700, 600);
  frameRate(100);
  wavePoints = new int[width];
  for (int i=0; i < wavePoints.length; i++){
    wavePoints[i] = height/2;
  }
}
  
void draw() {
  int newVal = 811 - sensorReading;
  background(0);
  fill(bgOverlayColor);
  noStroke();
  rect(0, 0, width, height);
  updateSound(newVal);
  drawWave(newVal);
  fill(red);
  text(BPM + " BPM", 20, 20);
}

void findArduino() {
  // println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  port = new Serial(this, Serial.list()[1], 115200);  // make sure Arduino is talking serial at this baud rate
  port.clear();            // flush buffer
  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return 
}

void initSound() {
  sine = new SinOsc(this);
  sine.play();
  device = new AudioDevice(this, 48000, 32);
  sounds = new SoundFile[6];
  sounds[1] = new SoundFile(this, "1.aif");
  sounds[2] = new SoundFile(this, "2.aif");
  sounds[3] = new SoundFile(this, "3.aif");
  sounds[4] = new SoundFile(this, "4.aif");
  sounds[5] = new SoundFile(this, "5.aif");
}

void drawWave(int newVal) {
  wavePoints[wavePoints.length - 1] = newVal;   // place new datapoint at end of array
  stroke(red);
  noFill();
  beginShape();   
  for (int i = 0; i < wavePoints.length-1; i++) {
    wavePoints[i] = wavePoints[i+1];  // move waveform by shifting points 1px left      
    vertex(i, wavePoints[i]); 
  }
  endShape();
}

void updateSound(int newVal) {
  sine.freq(newVal/2);
  if (beat) {
    float r = random(255);
    float g = random(255);
    float b = random(255);
    bgOverlayColor = color(r, g, b, 70);
    sounds[selectedSound].play(pitch);
    beat = false;
  }
}

void serialEvent(Serial port){ 
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)
   
   if (inData.charAt(0) == 'S'){          // leading 'S' for sensor data
     inData = inData.substring(1);        // cut off the leading 'S'
     sensorReading = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'B'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = int(inData);                   // convert the string to usable int
     beat = true;
   }
}

void keyPressed() {
  if (key == CODED) {
      if (keyCode == UP) {
        pitch *= 2;
      } else if (keyCode == DOWN) {
        pitch /= 2;
      }
      pitch = constrain(pitch, 0.5, 100);
  } else {
    switch(key) {
      case '1':
        selectedSound = 1;
        break;
      case '2':
        selectedSound = 2;
        break;
      case '3':
        selectedSound = 3;
        break;
      case '4':
        selectedSound = 4;
        break;
      case '5':
        selectedSound = 5;
        break;
    }
  }
}