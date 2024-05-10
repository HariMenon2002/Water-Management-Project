#ifndef PH_SENSOR_CALIBRATION_H
#define PH_SENSOR_CALIBRATION_H

#include <Arduino.h>

const int adcPin = 35; // Analog pin connected to the pH sensor
float pH_voltage_7, pH_voltage_4;
float a, b;

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
        sum_voltage_7 += analogRead(adcPin) * (3.3 / pow(2, 12)); // Convert ADC value to voltage
        delay(1000); // Delay between readings
      }
      pH_voltage_7 = sum_voltage_7 / 3;
      Serial.print("pH 7 voltage: ");
      Serial.println(pH_voltage_7);

      Serial.println("Dip the pH 4 buffer solution. Then enter 'ph4'.");
      while (!Serial.available());
      input = Serial.readStringUntil('\n');
      if (input.equals("ph4")) {
        delay(3000); // Allow time for stabilization
        float sum_voltage_4 = 0;
        for (int i = 0; i < 3; i++) {
          sum_voltage_4 += analogRead(adcPin) * (3.3 / pow(2, 12)); // Convert ADC value to voltage
          delay(1000); // Delay between readings
        }
        pH_voltage_4 = sum_voltage_4 / 3;
        Serial.print("pH 4 voltage: ");
        Serial.println(pH_voltage_4);

        // Calculate calibration coefficients
        a = 3 / (pH_voltage_7 - pH_voltage_4);
        b = 4 - (3 * pH_voltage_4 / (pH_voltage_7 - pH_voltage_4));
        Serial.println("Calibration completed.");
      } else {
        Serial.println("Invalid input.");
      }
    } else {
      Serial.println("Invalid input.");
    }
  } else {
    Serial.println("Invalid input.");
  }
}

float read_pH() {
  int sensorValue = analogRead(adcPin);
  float voltage = sensorValue * (3.3 / pow(2, 12)); // Convert ADC value to voltage
  float pH = a * voltage + b; // Calculate pH using calibration equation
  return pH;
}

#endif
