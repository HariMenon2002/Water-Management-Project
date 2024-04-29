#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include "DFRobot_ESP_PH.h"
#include "EEPROM.h"

// Define sensor pins and constants
#define PH_PIN 35
#define TdsSensorPin 34
#define DHTPIN 2
#define trigPin 25
#define echoPin 26
#define relayPin 12
#define turbiditySensorPin 32

// Define sensor types and instances
DFRobot_ESP_PH ph;
DHT dht(DHTPIN, DHTTYPE);

// Define Firebase parameters
#define WIFI_SSID "Redmi 9 Prime"
#define WIFI_PASSWORD "Ani#1234"
#define API_KEY "AIzaSyACL3Y-1P_48fA7qMTwrNMZ9BB_yeuwMTE"
#define USER_EMAIL "admin@gmail.com"
#define USER_PASSWORD "123456"
#define DATABASE_URL "https://testing-cli-44c7c-default-rtdb.asia-southeast1.firebasedatabase.app/"
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Define variables
float temperature = 25, humidity, conductivity, pH;
float turbidity = 0.0;
float turbiditySensorValue = 0.0;
float maxTurbidity = 0.0, minTurbidity = 1000.0;
float maxHumidity = 0.0, minHumidity = 100.0;
float maxTemperature = 0.0, minTemperature = 100.0;
float maxConductivity = 0.0, minConductivity = 100.0;
float maxpH = 0.0, minpH = 14.0;
float ppm = 0.0;

// Define Firebase paths
String tempPath = "/temperature";
String maxTempPath = "/max temperature";
String minTempPath = "/min temperature";
String humPath = "/humidity";
String maxHumPath = "/max humidity";
String minHumPath = "/min humidity";
String timePath = "/timestamp";
String conductivityPath = "/conductivity";
String maxConductivityPath = "/max conductivity";
String minConductivityPath = "/min conductivity";
String turbidityPath = "/turbidity";
String maxTurbidityPath = "/max turbidity";
String minTurbidityPath = "/min turbidity";
String pHPath = "/pH";
String maxpHPath = "/max pH";
String minpHPath = "/min pH";
String ppmPath = "/ppm";

// Initialize WiFi connection
void initWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println(WiFi.localIP());
  Serial.println();
  Serial.begin(115200);
  EEPROM.begin(32);
  ph.begin();
}

// Get current time
unsigned long getTime() {
  time_t now;
  struct tm timeinfo;
  delay(100);
  if (!getLocalTime(&timeinfo)) {
    return(0);
  }
  time(&now);
  return now;
}

// Task for DHT sensor readings
void dhtSensor(void * parameters) {
  for (;;) {
    vTaskDelay(1000/portTICK_PERIOD_MS);
  }
}

// Task for pH sensor readings
void pHSensor(void * parameters) {
  for (;;) {
    float voltage;
    static unsigned long timepoint = millis();
    if (millis() - timepoint > 1000U) {
      timepoint = millis();
      voltage = analogRead(PH_PIN) / ESPADC * ESPVOLTAGE;
      temperature = readTemperature();
      pH = ph.readPH(voltage, temperature);
    }
    vTaskDelay(1000/portTICK_PERIOD_MS);
  }
}

// Task for turbidity sensor readings
void turbiditySensor(void * parameters) {
  for (;;) {
    turbiditySensorValue = analogRead(turbiditySensorPin);
    turbidity = map(turbiditySensorValue, 0, 4095, 100, 0);
    vTaskDelay(1000/portTICK_PERIOD_MS);
  }
}

// Task for conductivity sensor readings
void conductivitySensor(void * parameters) {
  float VREFF = 3.3;
  int sensorValue;
  float tdsValue = 0;
  float temperature1 = 25;
  for (;;) {
    sensorValue = analogRead(TdsSensorPin);
    float sensorVoltage = sensorValue * VREFF / 4096;
    float compensationCoefficient = 1.0 + 0.02 * (temperature1 - 25.0);
    float compensationVoltage = sensorVoltage / compensationCoefficient;
    tdsValue = (133.42 * compensationVoltage * compensationVoltage * compensationVoltage - 255.86 * compensationVoltage * compensationVoltage + 857.39 * compensationVoltage) * 0.5;
    ppm = tdsValue;
    conductivity = ppm / 0.7;
    vTaskDelay(1000/portTICK_PERIOD_MS);
  }
}

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(relayPin, OUTPUT);
  Serial.begin(115200);
  initWiFi();
  configTime(0, 0, ntpServer);
  config.api_key = API_KEY; // Assign the api key (required)
  auth.user.email = USER_EMAIL;// Assign the user sign in credentials
  auth.user.password = USER_PASSWORD;// Assign the user sign in credentials
  config.database_url = DATABASE_URL;// Assign the RTDB URL (required)
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);
  Firebase.begin(&config, &auth);
  String databasePath = "/UsersData/readings";
  xTaskCreate(dhtSensor, "DHTSENSOR", 1000, NULL, 1, NULL);
  xTaskCreate(pHSensor, "PHSENSOR", 1000, NULL, 1, NULL);
  xTaskCreate(turbiditySensor, "TURBIDITYSENSOR", 1000, NULL, 1, NULL);
  xTaskCreate(conductivitySensor, "CONDUCTIVITYSENSOR", 1000, NULL, 1, NULL);
}

void loop() {
  digitalWrite(relayPin, LOW);
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH);
  float distanceCm = duration * SOUND_SPEED / 2;
  float distanceInch = distanceCm * CM_TO_INCH;
  Serial.print("Distance (cm): ");
  Serial.println(distanceCm);
  Serial.print("Distance (inch): ");
  Serial.println(distanceInch);
  delay(1000);

  // Control relay based on distance
  while (distanceCm >= 18) {
    digitalWrite(relayPin, HIGH);
  }

  // Firebase data sending and cleanup
  if (Firebase.ready() && (millis() - sendDataPrevMillis > timerDelay || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    int timestamp = getTime();
    int timestampPrev = timestamp - deleteDelay;
    Serial.print("Time: ");
    Serial.println(timestamp);
    String parentPath = databasePath + "/" + String(timestamp);
    temperature = dht.readTemperature();
    humidity = dht.readHumidity();
    FirebaseJson json;
    json.set(tempPath.c_str(), String(temperature));
    json.set(humPath.c_str(), String(humidity));
    if (maxTemperature < temperature) maxTemperature = temperature;
    if (minTemperature > temperature) minTemperature = temperature;
    json.set(maxHumPath.c_str(), String(maxHumidity));
    json.set(minHumPath.c_str(), String(minHumidity));
    json.set(maxTempPath.c_str(), String(maxTemperature));
    json.set(minTempPath.c_str(), String(minTemperature));
    json.set(conductivityPath.c_str(), String(conductivity));
    if (maxConductivity < conductivity) maxConductivity = conductivity;
    if (minConductivity > conductivity) minConductivity = conductivity;
    json.set(maxConductivityPath.c_str(), String(maxConductivity));
    json.set(minConductivityPath.c_str(), String(minConductivity));
    json.set(turbidityPath.c_str(), String(turbidity));
    if (maxTurbidity < turbidity) maxTurbidity = turbidity;
    if (minTurbidity > turbidity) minTurbidity = turbidity;
    json.set(maxTurbidityPath.c_str(), String(maxTurbidity));
    json.set(minTurbidityPath.c_str(), String(minTurbidity));
    json.set(pHPath.c_str(), String(pH));
    if (maxpH < pH) maxpH = pH;
    if (minpH > pH) minpH = pH;
    json.set(maxpHPath.c_str(), String(maxpH));
    json.set(minpHPath.c_str(), String(minpH));
    json.set(ppmPath.c_str(), String(ppm));
    json.set(timePath, String(timestamp));
    Serial.printf("Set json... %s\n", Firebase.RTDB.setJSON(&fbdo, parentPath.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    String oldDataPath = databasePath + "/" + String(timestampPrev);
    Serial.printf("Deleting old data at path: %s\n", oldDataPath.c_str());
    if (Firebase.RTDB.deleteNode(&fbdo, oldDataPath.c_str())) {
      Serial.println("Old data deleted successfully");
    } else {
      Serial.printf("Failed to delete old data: %s\n", fbdo.errorReason().c_str());
    }
    vTaskDelay(1000/portTICK_PERIOD_MS);
  }
}
