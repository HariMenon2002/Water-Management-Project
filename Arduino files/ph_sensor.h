#ifndef PH_SENSOR_H
#define PH_SENSOR_H

#include <Arduino.h>
#include <EEPROM.h>

// Pin connected to the pH sensor
#define PH_PIN 35

// Coefficient variables
extern float a;
extern float b;

// EEPROM address locations for coefficients
const int aAddress = 0; // Address to store coefficient 'a'
const int bAddress = sizeof(float); // Address to store coefficient 'b'

// Function prototypes
void readCoefficientsFromEEPROM();
void saveCoefficientsToEEPROM();
void updateCoefficientsAfterCalibration();
void calibrate_pH_sensor();
float calculate_pH(float voltage);

void readCoefficientsFromEEPROM() {
  EEPROM.begin(256);
  EEPROM.get(aAddress, a);
  EEPROM.get(bAddress, b);
  EEPROM.end();
}

void saveCoefficientsToEEPROM() {
  EEPROM.begin(512);
  EEPROM.put(aAddress, a);
  EEPROM.put(bAddress, b);
  EEPROM.commit();
  EEPROM.end();
}

// void updateCoefficientsAfterCalibration() {
//   // Your calibration logic here
//   // Once calibrated, update 'a' and 'b' coefficients
//   a = ...; // Update 'a' coefficient
//   b = ...; // Update 'b' coefficient
  
//   // Save updated coefficients to EEPROM
//   saveCoefficientsToEEPROM();
// }

void calibrate_pH_sensor() {
  Serial.println("Enter 'calph' to start calibration.");
  while (!Serial.available());
  String input = Serial.readStringUntil('\n');
  if (input.equals("calph")) {
    Serial.println("Dip the pH 7 buffer solution. Then enter 'ph7'.");
    while (!Serial.available());
    input = Serial.readStringUntil('\n');
    if (input.equals("ph7")) {
      delay(3000); // Allow time for stabilization
      float sum_voltage_7 = 0;
      for (int i = 0; i < 3; i++) {
        sum_voltage_7 += analogRead(PH_PIN) * (3.3 / pow(2, 12)); // Convert ADC value to voltage
        delay(1000); // Delay between readings
      }
      float pH_voltage_7 = sum_voltage_7 / 3;
      Serial.print("pH 7 voltage: ");
      Serial.println(pH_voltage_7);
      vTaskDelay(1000/portTICK_PERIOD_MS);

      Serial.println("Dip the pH 4 buffer solution. Then enter 'ph4'.");
      while (!Serial.available());
      input = Serial.readStringUntil('\n');
      if (input.equals("ph4")) {
        delay(3000); // Allow time for stabilization
        float sum_voltage_4 = 0;
        for (int i = 0; i < 3; i++) {
          sum_voltage_4 += analogRead(PH_PIN) * (3.3 / pow(2, 12)); // Convert ADC value to voltage
          delay(1000); // Delay between readings
        }
        float pH_voltage_4 = sum_voltage_4 / 3;
        Serial.print("pH 4 voltage: ");
        Serial.println(pH_voltage_4);

        // Calculate calibration coefficients
        a = 3 / (pH_voltage_7 - pH_voltage_4);
        b = 4 - (3 * pH_voltage_4 / (pH_voltage_7 - pH_voltage_4));
        Serial.println("Calibration completed.");

        // Save coefficients to EEPROM
        saveCoefficientsToEEPROM();
      } else {
        Serial.println("Invalid input.");
      }
    } else {
      Serial.println("Invalid input.");
    }
  } else {
    // Read coefficients from EEPROM
    readCoefficientsFromEEPROM();
  }
}

float calculate_pH(float voltage) {
  return a * voltage + b;
}

#endif
