import processing.serial.*;
import processing.sound.*;

Serial port;
SinOsc pulseSonification;
SinOsc beatSounds;
Env env;
int NOTE_COUNT = 8;
float[] notes;
int sensorReading;
int BPM;
int IBI; // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int[] wavePoints;
boolean beat = false;
color red = #EE0000;
color bgOverlayColor = 0;
float quarterPeriod;

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
  background(0);
  fill(bgOverlayColor);
  noStroke();
  rect(0, 0, width, height);
  updateSound();
  drawWave();
  fill(red);
  text(BPM + " BPM", 10, 20);
}

void drawWave() {
  int offset = 811;
  wavePoints[wavePoints.length - 1] = offset - sensorReading;   // place new datapoint at end of array
  stroke(red);
  noFill();
  beginShape();   
  for (int i = 0; i < wavePoints.length-1; i++) {
    wavePoints[i] = wavePoints[i+1];  // move waveform by shifting points 1px left      
    vertex(i, wavePoints[i]); 
  }
  endShape();
}

void updateSound() {
  pulseSonification.freq(sensorReading/940.0 * BPM);
  if (beat) {
    beat = false;
    playNote();
    thread("midBeats");
  }
}

void midBeats() {
  int quarterLength = IBI/4;
  delay(quarterLength);
  if (mouseX < width/4) {
    playNote();
  }
  delay(quarterLength);
  if (mouseX < width/2) {
    playNote();
  }
  delay(quarterLength);
  if (mouseX < width/4) {
    playNote();
  }
}

void playNote() {
  int note = floor(mouseY/float(height) * NOTE_COUNT);
  beatSounds.play(notes[note], 1.0);
  env.play(beatSounds, 0.001, 0.004, 0.3, 0.1);
  changeBg(random(255), random(255), random(255));
}

void changeBg(float r, float g, float b) {
  bgOverlayColor = color(r, g, b, 70);
}

void findArduino() {
  // println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  port = new Serial(this, Serial.list()[1], 115200);  // make sure Arduino is talking serial at this baud rate
  port.clear();            // flush buffer
  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return 
}

void initSound() {
  notes = new float[NOTE_COUNT];
  //float[] eightStepMajor = {1,2,2,1,2,2,2,1};
  //notes[0] = 0;
  //for (int i = 1; i < notes.length; i++) {
  //  notes[i] = notes[i-1] + eightStepMajor[i%8]/12.0;
  //}
  notes[7] = 261.626; //C
  notes[6] = 293.665; //D
  notes[5] = 329.628; //E
  notes[4] = 349.228; //F
  notes[3] = 391.995; //G
  notes[2] = 440.000; //A
  notes[1] = 493.883; //B
  notes[0] = 523.251; //C
  
  beatSounds = new SinOsc(this);
  env  = new Env(this); 
  
  pulseSonification = new SinOsc(this);
  pulseSonification.play();
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
   if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI = int(inData);                   // convert the string to usable int
   }
}