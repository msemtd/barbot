import processing.serial.*;
import cc.arduino.*;
import g4p_controls.*;

Arduino arduino;
GStick joystick;
GCustomSlider sdr; 
GTextField txf1, txf2;
GButton[] btnColours = new GButton[8];
GDropList portList;



PShape bottle;
PFont font;

Serial ser;

Drink drink;
int dirX, dirY;
float px, py;
float speed;
int fctr;

public void setup() {

  size(640, 480, P2D);
  G4P.setGlobalColorScheme(GCScheme.ORANGE_SCHEME);
  G4P.setCursor(ARROW);
  if (frame != null)
    frame.setTitle("BarBot Test App 1");

  font = loadFont("CocktailShaker-88.vlw");
  textFont(font, 88);

  float ss = 80;
  joystick = new GStick(this, width-ss, height-ss, ss, ss);
  // Change from the default X4 mode (4 position) to the
  // 8 position mode.
  joystick.setMode(G4P.X8);

  ss = 30;
  sdr = new GCustomSlider(this, ss, height-170, width-(ss*2), 120, "purple18px"); 
  // Some of the following statements are not actually
  // required because they are setting the default value. 
  sdr.setLocalColorScheme(3); 
  sdr.setOpaque(false); 
  sdr.setValue(0.5); 
  sdr.setNbrTicks(20); 
  sdr.setShowLimits(true); 
  sdr.setShowValue(true); 
  sdr.setShowTicks(true); 
  sdr.setStickToTicks(false); 
  sdr.setEasing(10.0); 

  txf1 = new GTextField(this, 10, 10, 200, 20);
  txf1.tag = "txf1";
  txf1.setDefaultText("Yo!");

  int x = width - 42, y = 2;
  for (int i = 0; i < btnColours.length; i++) {
    btnColours[i] = new GButton(this, x, y + i * 20, 40, 18, "" + (i+1));
    btnColours[i].tag = "Button: " + (i+1);
    btnColours[i].setLocalColorScheme(i);
    btnColours[i].tagNo = 1000+i;
  }

  // servo control buttons
  {
  x=30;y=200;
  int sbw = 30;
  int snum = 1;
  String nom = "ps"+snum;
  GLabel lab = new GLabel(this, x, y, sbw, 18, nom);
  GButton b = new GButton(this, x, y+20, sbw, 18, "on");
  b.tagNo = 2000 + snum;
  b = new GButton(this, x, y+40, sbw, 18, "off");
  b.tagNo = 2000 + 10 + snum;
  }
  // serial drop-down...
  x = width - 144; 
  y = 5;
  portList = new GDropList(this, x, y, 90, 96, 5);
  serialSetup();
  
  px = 50;
  py = 280;

  drink = new Drink(px,px);
  fctr = frameCount;
  String p = portList.getSelectedText();
  arduino = new Arduino(this, p, 57600);
  arduino.pinMode(4, Arduino.SERVO);
  arduino.servoWrite(4, 0);
}

public void draw() {
  background(255, 255, 190);
  // draw glass posn - ease into chosen track location - feedback required
  shape(bottle, 280, 40);
  fill(255, 204, 0);
  text("BarBot", 50, 150);

  if(drink.followSlider){
    if(frameCount > (fctr+20)){
      fctr = frameCount;
    }
    // how do we get the slider X?
  //      float targetX = 100;
  //      float dx = targetX - x;
  //    if(abs(dx) > 1) {
  //      x += dx * easing;
  //    }
  //    
  //    float targetY = mouseY;
  //    float dy = targetY - y;
  //    if(abs(dy) > 1) {
  //      y += dy * easing;
  //    }

  } else {
    // use joystick to position drink
    px = (px + dirX * speed + width) % width;
    py = (py + dirY * speed + height) % height;

    drink.x = px;
    drink.y = py;
  }
  drink.display();
}

public void handleStickEvents(GStick stick, GEvent event) { 
  if (joystick == stick) {
    int pos = stick.getPosition();
    if (pos < 0) {
      speed = 0;
    } else {
      dirX = stick.getStickX();
      dirY = stick.getStickY();
      speed = 0.8;

      txf1.setText("facing = "+pos+" x = "+dirX+" py = "+dirY);
      float fpos = sdr.getValueF();
      fpos += (dirX*0.1);
      float fmin = sdr.getStartLimit();
      float fmax = sdr.getEndLimit();
      if(fpos < fmin) fpos = fmin; 
      if(fpos > fmax) fpos = fmax; 
      sdr.setValue(fpos);
    }
  }
}

public void handleButtonEvents(GButton button, GEvent event) { 
  if (button.tagNo >= 1000 && button.tagNo <2000) {
    joystick.setLocalColorScheme(button.tagNo - 1000);
  }
  if (button.tagNo == 1000) {
    println("drink pos = "+drink.x+","+drink.y);
  }
  // 2000 pop servo 1 - 6 on or off
  if(button.tagNo >= 2000 && button.tagNo < 3000) {
    int t = button.tagNo - 2000;
    boolean on = (t < 10);
    int snum = on ? t : t - 10;
    String msg = "Pop servo "+snum+ " "+ (on ? "on" : "off");
    // TODO multiple servo pins in validated array with on and off positions and timings
    int servoPin = 4;
    int onVal = 175;
    int offVal = 0;
    
    arduino.servoWrite(servoPin, on ? onVal : offVal);
    
    
    
  }
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if (slider == sdr) {
  }
}

public void serialSetup(){
  String ports[] = Arduino.list(); 
  portList.setItems(ports, 0);
 
//  if(comPortList.length>0){
//    comPort = new Serial(this, comPortList[0], 9600);
//    comPort.bufferUntil('\n');
//  }

}
public void handleDropListEvents(GDropList list, GEvent event) { 
  if(list == portList){
    String p = list.getSelectedText();
//    if(ser != null){
//      ser.stop();
//    }
    println("OK, opening port "+p);
//    ser = new Serial(this, p, 9600);
  arduino = new Arduino(this, p, 57600);
    println("OK - looks open to me"); 
  }
}

