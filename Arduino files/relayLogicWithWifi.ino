#include <WiFi.h>
#include <esp_now.h>

#define TANK_LENGTH 75

const int trigPin = 25;
const int echoPin = 26;
const int relayPin = 27;

long duration;
float distanceCm;
float distanceInch;

//B8:D6:1A:A7:EF:20
uint8_t broadcastAddress[] = {0xB8, 0xD6, 0x1A, 0xA7, 0xEF, 0x20}; // Broadcast MAC address

typedef struct struct_message {
  float distanceCm;
  float distanceInch;
} struct_message;

struct_message myData;

esp_now_peer_info_t peerInfo;

void setup() {
  Serial.begin(115200);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(relayPin, OUTPUT);
  
  WiFi.mode(WIFI_MODE_STA);
  
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }
  
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;  
  peerInfo.encrypt = false;
  
  if (esp_now_add_peer(&peerInfo) != ESP_OK){
    Serial.println("Failed to add peer");
    return;
  }
}

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH);
  
  distanceCm = duration * 0.034 / 2;
  distanceInch = duration * 0.0133 / 2;
  
  Serial.print("Distance: ");
  Serial.print(distanceCm);
  Serial.print(" cm  ");
  Serial.print(distanceInch);
  Serial.println(" inch");
  
  if (distanceCm > TANK_LENGTH*0.8) {
    digitalWrite(relayPin, HIGH); // Turn on relay if distance is greater than 20 cm
  } else {
    digitalWrite(relayPin, LOW); // Turn off relay if distance is less than or equal to 20 cm
  }
  
  myData.distanceCm = distanceCm;
  myData.distanceInch = distanceInch;
  
  esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
  if (result == ESP_OK) {
    Serial.println("Sent with success");
  } else {
    Serial.println("Error sending the data");
  }
  
  delay(1000);
}