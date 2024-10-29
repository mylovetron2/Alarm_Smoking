
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"
//#include <SoftwareSerial.h>
#include "Ticker.h"
#include <TM1637Display.h>
#include "header.h"

// Insert your network credentials
#define WIFI_SSID "Family f2"
#define WIFI_PASSWORD "23456781"

// Insert Firebase project API Key
#define API_KEY "AIzaSyAJCyHQmTX6xjs1uktvxWbk-Bc8sfYLw2I"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://temperature-app-3d881-default-rtdb.firebaseio.com" 

//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;

int epoch_time;
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

String database_path;  //main path
String parent_path;
//get current epoch time
//SoftwareSerial swSer(14, 12, false); //Define hardware connections

unsigned long Get_Epoch_Time() {
  timeClient.update();
  unsigned long now = timeClient.getEpochTime();
  return now;
}

void setup(){
  pinMode(pin_sensor1,INPUT);
  pinMode(pin_sensor2,INPUT);
  pinMode(pin_sensor3,INPUT);
  pinMode(pin_led1,OUTPUT);
  pinMode(pin_led2,OUTPUT);
  pinMode(pin_led3,OUTPUT);

  Serial.begin(115200);

  display.clear();
  display.setBrightness(0x0f);
  tk_display.attach(1, displayTM);
  tk_read_sensor.attach(1,read_sensor);




  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  /* Assign the api key (required) */
  config.api_key = API_KEY;
  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;
  auth.user.email = "mystore2018myapp@gmail.com";
  auth.user.password = "123456789";
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  config.max_token_generation_retry = 5;
  
  timeClient.begin();
  timeClient.setTimeOffset(25200);

  Firebase.begin(&config, &auth);
  Serial.println("Getting User UID...");

  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }

  String UID;
  UID = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(UID);
  //database_path = "/Data/" + UID + "/readings";
  database_path = "/SensorDat";
  delay(2000);
  Serial.println(database_path);
  

}

void displayTM(){
  display.setSegments(P,1,0);
  //display.showNumberDec(100,false,3,1);
  display.showNumberDec(sensor1*100+2*sensor2*10+3*sensor3,true,3,1);
  
}

void read_sensor(){
  sensor1=!digitalRead(pin_sensor1);
  sensor2=!digitalRead(pin_sensor2);
  sensor3=!digitalRead(pin_sensor3);

  digitalWrite(pin_led1,sensor1);
  digitalWrite(pin_led2,sensor2);
  digitalWrite(pin_led3,sensor3);

}

void loop(){
   if (Firebase.ready() && (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)){
    sendDataPrevMillis = millis();

    epoch_time = Get_Epoch_Time();
    parent_path=  database_path + "/sensor1";
    if (Firebase.RTDB.setInt(&fbdo, parent_path, sensor1)){
      //Serial.println("Sensor1");
    }
    parent_path=  database_path + "/sensor2";
    if (Firebase.RTDB.setInt(&fbdo, parent_path, sensor2)){
      //Serial.println("Sensor2");
    }
    parent_path=  database_path + "/sensor3";
    if (Firebase.RTDB.setInt(&fbdo, parent_path, sensor3)){
      //Serial.println("Sensor3");
    }
      

  }
  
}
