import processing.serial.*;
import processing.sound.*;

Serial port;
AudioDevice device;
SoundFile sf;
SinOsc sine;    

int sensorReading;
int BPM;
int[] wavePoints;
boolean beat = false;

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
  fill(250,0,0);
  text(BPM + " BPM", 20, 20);
  int newVal = 811 - sensorReading;
  drawWave(newVal);
  updateSound(newVal);
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
  sf = new SoundFile(this, "1.aif"); 
}

void drawWave(int newVal) {
  wavePoints[wavePoints.length - 1] = newVal;   // place new datapoint at end of array
  stroke(250,0,0);
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
    sf.play(0.5);
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