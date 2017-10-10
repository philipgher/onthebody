const int buttonPin = 2;
const int ledPin =  13;
int buttonState = 0;
int counterL = 0;
int counterH = 0;

void setup() {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {
  buttonState = digitalRead(buttonPin);
  if (buttonState == HIGH) {
    delay(50);
    Serial.println("0");
    digitalWrite(ledPin, HIGH);
  } else {
    delay(50);
    Serial.println("1");  
    digitalWrite(ledPin, LOW);
  }
}
