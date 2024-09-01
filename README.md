## Water Management Project

This project is made with the intention of testing the potability of drinking water so that various diseases can be prevented. It involves an app which displays all the essential water parameters like dissolved oxygen, pH, turbidity, temperature and conductivity.We used special sensors for the same reason and all of them were connected to an ESP32 microcontroller. The data logged from these sensors is sent to Firebase via ESP32 which has a Firebase client library.  

These parameter values are taken from the Firebase database and displayed in an app built using Flutter. The app has a signin and signup authentication initially. It displays all the parameters with their maximum and minimum values as well. The app also displays an alert when there is an abnormal fluctuation in the parameters which could be caused due to impurities or other problems. Simultaneously an alert is also sent on Telegram to the user. This is done using a telegram bot which is connected to the app. It also has google gemini integrated with it which serves as a chatbot to clarify the user's doubts.

A machine learning model which uses Random Forest Classifier has also been built to predict the potability of water using the parameter values which are sent to the model which is connected to the app via localhost.

***

## Technologies used
1. Flutter
2. Firebase
3. ESP32
4. Flask
5. ML model using sklearn library

