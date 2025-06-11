/*
  Combined sensor reading for water level (ultrasonic) and water flow (YF-S401).
  Outputs CSV in the format: elapsed,distance_cm,flowRate
  
  - Ultrasonic sensor pins: 
      * Trigger: pin 10
      * Echo:    pin 9
  - Flow sensor pin:
      * Connected to digital pin 2 (which supports external interrupts)
*/

// ----- PIN DEFINITIONS -----
// Ultrasonic Sensor
const int trigPin = 10;  // Trigger pin for ultrasonic sensor
const int echoPin = 9;   // Echo pin for ultrasonic sensor

// Flow Sensor
const int sensorinterrupt = 0;
const int sensorPin = 2; // Flow sensor is connected here (must support interrupts)

// Optional: Status LED (active-low typical setup)
const byte statusLed = 13;

// ----- GLOBAL VARIABLES: Ultrasonic Sensor -----
long duration;      // Time (in microseconds) for the pulse to return
int distance_cm;    // Calculated distance (cm)

// ----- GLOBAL VARIABLES: Flow Sensor -----
volatile unsigned int flowPulseCount = 0; // Count pulses detected via interrupt
float flowRate = 0.0;                     // Flow rate in L/min
unsigned int flowMilliLitres = 0;         // Volume in milliliters for the interval (if desired)
unsigned long totalMilliLitres = 0;         // Cumulative volume if needed
unsigned long lastFlowMillis = 0;         // Timing reference for flow measurement intervals

// Calibration constant: Adjust depending on your sensor's datasheet or calibration tests.
// For a YF-S401 sensor, you might need to determine this experimentally.
const float calibrationFactor = 2077;

// ----- TIMING VARIABLE for CSV output -----
unsigned long startTime = 0;

// ----- INTERRUPT SERVICE ROUTINE (ISR) -----
// This function gets called for every falling edge on the flow sensor pin.
void pulseCounter() {
  flowPulseCount++;
}

void setup() {
  // Initialize Serial for debugging and data output
  Serial.begin(9600);

  // Set up ultrasonic sensor pins
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  // Set up the flow sensor pin with internal pull-up (most hall-effect sensors work with pull-up)
  pinMode(sensorPin, INPUT_PULLUP);
  
  // Optionally, set up the status LED
  pinMode(statusLed, OUTPUT);
  digitalWrite(statusLed, HIGH); // active-low LED: HIGH means off
  
  // Attach the interrupt for the flow sensor pin
  // digitalPinToInterrupt(sensorPin) returns the proper interrupt number.
  attachInterrupt(digitalPinToInterrupt(sensorPin), pulseCounter, FALLING);
  
  // Initialize timing variables
  lastFlowMillis = millis();
  startTime = millis();
}

void loop() {
  // ----- Ultrasonic Sensor Reading: Water Level -----
  // Trigger the ultrasonic sensor:
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  // Measure the time for the echo to return:
  duration = pulseIn(echoPin, HIGH);
  // Calculate distance in centimeters:
  // (speed of sound is 0.034 cm/µs and we divide by 2 for the round-trip)
  distance_cm = duration * 0.034 / 2;
  
  // ----- Flow Sensor Reading: Water Flow -----
  unsigned long currentMillis = millis();
  unsigned long interval = currentMillis - lastFlowMillis;
  if (interval >= 1000) {   // Process every 1 second
    // Calculate frequency in pulses per second:
    float frequency = flowPulseCount / (interval / 1000.0);
    // Calculate flow rate (L/min) from pulse frequency:
    flowRate = (60.0 / calibrationFactor) * frequency;
    
    // (Optional) Calculate the volume in millilitres passing in this interval:
    flowMilliLitres = (flowRate / 60) * 1000;
    totalMilliLitres += flowMilliLitres;
    
    // Reset counter for the next measurement period
    flowPulseCount = 0;
    lastFlowMillis = currentMillis;
  }
  
  // ----- Output Data as CSV -----
  // Compute elapsed time since the sketch started
  unsigned long elapsed = millis() - startTime;
  // Print CSV: elapsed (ms), distance (cm), flow rate (L/min)
  Serial.print(elapsed);
  Serial.print(",");
  Serial.print(distance_cm);
  Serial.print(",");
  Serial.println(flowRate);
  
  delay(500); // Delay between readings for stability
}
