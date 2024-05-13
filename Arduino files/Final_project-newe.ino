#include<Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include<DHT.h>
// #include "DFRobot_ESP_PH.h"
#include "EEPROM.h"
#include "ph_sensor.h"
#include "soc/rtc_wdt.h"
#include <OneWire.h>
#include <DallasTemperature.h>
#include <esp_now.h>


#define ESPADC 4096.0   //the esp Analog Digital Convertion value
#define ESPVOLTAGE 3300 //the esp voltage supply value
#define PH_PIN 35		//the esp gpio data pin number
#define TdsSensorPin 34
#define SOUND_SPEED 0.034
#define CM_TO_INCH 0.393701
#define TANK_LENGTH 75




  
    


#include "time.h"
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"


#define WIFI_SSID "Redmi 9 Prime"
#define WIFI_PASSWORD "Ani#1234"
// #define WIFI_SSID "BSNLFIBRONET"//"Redmi 9 Prime"
// #define WIFI_PASSWORD "shaju2258"

//#define WIFI_SSID "Xiaomi_1F4F"
//#define WIFI_PASSWORD "KL@8@BD@926"


//#define API_KEY "AIzaSyBBrVsmg2nuwCZgV3SPuNNbirqWzEVlfVA"
#define API_KEY "AIzaSyACL3Y-1P_48fA7qMTwrNMZ9BB_yeuwMTE"

// Insert Authorized Email and Corresponding Password
                                                                                  #define USER_EMAIL "admin@gmail.com"
                                                                                  #define USER_PASSWORD "123456"

//#define DATABASE_URL "https://esptest-2a21e-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define DATABASE_URL "https://testing-cli-44c7c-default-rtdb.asia-southeast1.firebasedatabase.app/"

// Define Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// GPIO where the DS18B20 is connected to
const int oneWireBus = 4;     

// Setup a oneWire instance to communicate with any OneWire devices
OneWire oneWire(oneWireBus);

// Pass our oneWire reference to Dallas Temperature sensor 
DallasTemperature sensors(&oneWire);


String uid;
String databasePath;
String parentPath;

typedef struct struct_message {
  float distanceCm;
  float distanceInch;
} struct_message;

struct_message myData;


int timestamp;
int timestampPrev;
FirebaseJson json;

const char* ntpServer = "pool.ntp.org";
unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 60000;
unsigned long deleteDelay= 120;

long duration;
float distanceCm;
float distanceInch;




int turbiditySensorPin=32;
float distance;
float percentage;
float a,b;



float temperature=25,humidity=0,conductivity,pH;

float turbidity=0.0;


float turbiditySensorValue=0.0;

float maxTurbidity = 0.0;float minTurbidity = 1000.0;

float maxHumidity=0.0,minHumidity=100.0;

float maxTemperature=0.0,minTemperature=100.0;

float maxConductivity = 0.0,minConductivity = 100.0;

float maxpH = 0.0,minpH = 14.0;

float ppm=0.0;



String tempPath = "/temperature";
String maxTempPath="/max temperature";
String minTempPath="/min temperature";
String humPath = "/humidity";
String maxHumPath="/max humidity";
String minHumPath="/min humidity";


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

String ppmPath="/ppm";


esp_now_peer_info_t peerInfo;

TaskHandle_t lowPriorityTaskHandle = NULL;

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
        EEPROM.begin(32);//needed to permit storage of calibration value in eeprom
}


void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&myData, incomingData, sizeof(myData));
  distance = myData.distanceCm;
}


                                                              // Function that gets current epoch time
unsigned long getTime() {
        time_t now;
        struct tm timeinfo;

        delay(100);
        if (!getLocalTime(&timeinfo)) {
              //Serial.println("Failed to obtain time");
              return(0);
        }
        time(&now);
        return now;
}


/*This section of code measures the level of water using HCSR04*/


void dhtSensor(void * parameters){
   for(;;){

      sensors.requestTemperatures(); 
      float temperatureC = sensors.getTempCByIndex(0);
      temperature = temperatureC;
      vTaskDelay(4000/portTICK_PERIOD_MS);
   }
}

/*This section of code measures the pH value of the water*/
void pHSensor(void * parameters){
  calibrate_pH_sensor();
   for(;;){
        // rtc_wdt_protect_off();    // Turns off the automatic wdt service
        // rtc_wdt_enable();         // Turn it on manually
        // rtc_wdt_set_time(RTC_WDT_STAGE0, 40000);  // Define how long you desire to let dog wait.
          // Read pH sensor voltage
        float sensorVoltage = analogRead(PH_PIN) * (3.3 / pow(2, 12)); // Convert ADC value to voltage
        // Calculate pH value
        float pH = calculate_pH(sensorVoltage);
        Serial.print("pH Value");
        Serial.println(pH);
        // float voltage;
      	// static unsigned long timepoint = millis();
        // if (millis() - timepoint > 1000U) //time interval: 1s
        // {
        //   timepoint = millis();
        //   //voltage = rawPinValue / esp32ADC * esp32Vin
        //   voltage = analogRead(PH_PIN) / ESPADC * ESPVOLTAGE; // read the voltage
          
        //  // temperature = readTemperature();  // read your temperature sensor to execute temperature compensation
        //   temperature=100;
        //   pH = ph.readPH(voltage, temperature); // convert voltage to pH with temperature compensation
        // }

      vTaskDelay(2000/portTICK_PERIOD_MS);
   }
}

/*This section of the code measure the turbidity of the water*/
void turbiditySensor(void * parameters){
  float ntu;
   for(;;){
      // Convert the ADC reading to voltage (assuming a 4.1V reference voltage)
      float volt = 0;
      for (int i = 0; i < 800; i++) {
      volt += ((float)analogRead(turbiditySensorPin) / 4096) * 3.3; // Conversion for 3.3V, as ESP has a 12-bit ADC
      }
      volt = volt / 800;


      ntu = 0.1329407 + 9.845065*exp(-5.495042*volt); // Calculating NTU using the provided quadratic equation
      //y = 0.1329407 + 9.864065*e^(-5.495042*x)
      // Limiting the NTU value between 0 and 2000
      if (ntu < 0) {
      ntu = 0;
      } else if (ntu > 10) {
      ntu = 10;
      }

      turbidity = ntu;
      vTaskDelay(2000/portTICK_PERIOD_MS);
   }
}

/*This section of code measures both conductivity and TDS value*/
void conductivitySensor(void * parameters){
    float VREFF = 3.3;
    int sensorValue;
    float tdsValue = 0;
    float temperature1 = 25;
   for(;;){
 
       // put your main code here, to run repeatedly:
    sensorValue = analogRead(TdsSensorPin);
    // Serial.print("Sensor value:");    //read the analog value and store into the buffer
    // Serial.println(sensorValue);
    float sensorVoltage = sensorValue*VREFF/4096;
    // Serial.print("Sensor voltage:");    //read the analog value and store into the buffer
    // Serial.print(sensorVoltage);
    // Serial.println("V");
    float compensationCoefficient = 1.0+0.02*(temperature1-25.0);
      //temperature compensation
    float compensationVoltage=sensorVoltage/compensationCoefficient;
   
    tdsValue=(133.42*compensationVoltage*compensationVoltage*compensationVoltage - 255.86*compensationVoltage*compensationVoltage + 857.39*compensationVoltage)*0.5;
    ppm=tdsValue;
    conductivity = ppm/0.7;
    // Serial.print("TDS value:");    //read the analog value and store into the buffer
    // Serial.print(tdsValue);
    // Serial.println("ppm");


      vTaskDelay(2000/portTICK_PERIOD_MS);
   }
}

void lowPriorityTask(void *pvParameters) {
    for (;;) {
        // Task code goes here

        // Reset watchdog timer
        rtc_wdt_feed();

        // Delay to control task execution frequency
        vTaskDelay(pdMS_TO_TICKS(1000)); // Adjust delay as needed
    }
}


void printData(void *pvParameters) {
  for (;;) {
    percentage = distance/TANK_LENGTH*100;
    Serial.print("Distance: ");
    Serial.print(distance);
    Serial.print(" cm  ");
    Serial.print(percentage);
    Serial.println("%");
    humidity = percentage;
    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}


void setup() {

          Serial.begin(115200);
          initWiFi();

          WiFi.mode(WIFI_MODE_STA);
  
          configTime(0, 0, ntpServer);
          // Assign the api key (required)
          config.api_key = API_KEY;

          // Assign the user sign in credentials
                                                                                                auth.user.email = USER_EMAIL;
                                                                                                
                                                                                                auth.user.password = USER_PASSWORD;

          // Assign the RTDB URL (required)
          config.database_url = DATABASE_URL;


          if (Firebase.signUp(&config, &auth, "", "")){
                Serial.println("ok");
                //signupOK = true;
          }
          else{
                Serial.printf("%s\n", config.signer.signupError.message.c_str());
          }

  

          Firebase.reconnectWiFi(true);
          fbdo.setResponseSize(4096);
          Firebase.begin(&config, &auth);
          databasePath= "/UsersData/readings";




          if (esp_now_init() != ESP_OK) {
              Serial.println("Error initializing ESP-NOW");
              return;
            }

            esp_now_register_recv_cb(OnDataRecv);

           xTaskCreate(printData,
            "Print Data",
             1024,
             NULL,
             2,
            NULL);
          

  
          xTaskCreate(
              dhtSensor,
              "DHTSENSOR",
              1000,//stack size
              NULL,//task parameters
              1,//priority
              NULL  //task handle
          );

          xTaskCreate(
              pHSensor,
              "PHSENSOR",
              2048,//stack size
              NULL,//task parameters
              0,//priority
              NULL  //task handle
          );

          xTaskCreate(
              turbiditySensor,
              "TURBIDITYSENSOR",
              1000,//stack size
              NULL,//task parameters
              1,//priority
              NULL  //task handle
          );

          xTaskCreate(
              conductivitySensor,
              "CONDUCTIVITYSENSOR",
              1000,//stack size
              NULL,//task parameters
              1,//priority
              NULL  //task handle
          );
          xTaskCreate(
        lowPriorityTask,      // Task function
        "LowPriorityTask",    // Task name
        1000,                 // Stack size (words)
        NULL,                 // Task parameters
        0,                    // Priority (low priority)
        &lowPriorityTaskHandle  // Task handle
    );
          // xTaskCreate(
          //     legthMeasure,
          //     "Lengthmeasure",
          //     1000,//stack size
          //     NULL,//task parameters
          //     1,//priority
          //     NULL  //task handle
          // );

          // xTaskCreate(
          //     fireBase,
          //     "FIREBASE", 
          //     1000,//stack size
          //     NULL,//task parameters
          //     1,//priority
          //     NULL  //task handle
          // );

}

void loop() {



  

        if (Firebase.ready() && (millis() - sendDataPrevMillis > timerDelay || sendDataPrevMillis == 0)){
                      sendDataPrevMillis = millis();

                      //Get current timestamp
                      timestamp = getTime();
                      timestampPrev=timestamp- deleteDelay;
                      Serial.print ("time: ");
                      Serial.println (timestamp);

                      parentPath= databasePath + "/" + String(timestamp);

                      // temperature=dht.readTemperature();
                      // humidity=dht.readHumidity();


                      json.set(tempPath.c_str(), String(temperature));
                      json.set(humPath.c_str(), String(humidity));

                      if(maxTemperature<temperature) maxTemperature=temperature;
                      if(minTemperature>temperature) minTemperature=temperature;
                      if(maxHumidity<humidity) maxHumidity=humidity;
                      if(minHumidity>humidity) minHumidity=humidity;
                      

                      json.set(maxHumPath.c_str(), String(maxHumidity));
                      json.set(minHumPath.c_str(), String(minHumidity));
                      json.set(maxTempPath.c_str(), String(maxTemperature));
                      json.set(minTempPath.c_str(), String(minTemperature));
   
                      


                      json.set(conductivityPath.c_str(), String(conductivity));         //for conductivity

                      if (maxConductivity < conductivity) maxConductivity = conductivity;
                      if (minConductivity > conductivity) minConductivity = conductivity;

                      json.set(maxConductivityPath.c_str(), String(maxConductivity));
                      json.set(minConductivityPath.c_str(), String(minConductivity));

                      // For Turbidity
                      json.set(turbidityPath.c_str(), String(turbidity));

                      if (maxTurbidity < turbidity) maxTurbidity = turbidity;
                      if (minTurbidity > turbidity) minTurbidity = turbidity;

                      json.set(maxTurbidityPath.c_str(), String(maxTurbidity));
                      json.set(minTurbidityPath.c_str(), String(minTurbidity));

                      // For pH
                      json.set(pHPath.c_str(), String(pH));

                      if (maxpH < pH) maxpH = pH;
                      if (minpH > pH) minpH = pH;

                      json.set(maxpHPath.c_str(), String(maxpH));
                      json.set(minpHPath.c_str(), String(minpH));
                      
                      json.set(ppmPath.c_str(),String(ppm));


                      json.set(timePath, String(timestamp));
                      Serial.printf("Set json... %s\n",Firebase.RTDB.setJSON(&fbdo, parentPath.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());

                      String oldDataPath = databasePath + "/" + String(timestampPrev);
                      Serial.printf("Deleting old data at path: %s\n", oldDataPath.c_str());
                      if (Firebase.RTDB.deleteNode(&fbdo, oldDataPath.c_str())) {
                               Serial.println("Old data deleted successfully");
                      } 
                      else {
                               Serial.printf("Failed to delete old data: %s\n", fbdo.errorReason().c_str());
                      }


                      vTaskDelay(1000/portTICK_PERIOD_MS);      
          }
}
