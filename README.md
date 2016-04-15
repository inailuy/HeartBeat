# HeartBeat
 <img src="http://i.imgur.com/QJ2za48.jpg" width="248" height="400">     <img src="http://i.imgur.com/f0QqzMt.jpg" width="248" height="400">     <img src="http://i.imgur.com/RMOTeXO.jpg" width="248" height="400">

Health Fitness App for working out with bluetooth heart rate monitor written in Objectic C
## User Interface
User interface takes cues from social networking app Snapchat. Three way slide Interface with the starting view displays a screen with options to begin a workout. The app uses transparencies views with a map of the users location in the background
### Main Screen
The app automatically connects to a bluetooth heart rate monitor and begins displaying heartbeat measurements. At the bottom theres a button for choosing types of workouts. At the top you have left and right buttons (History/Settings) and the name of the App in the middle. Click on either of the buttons or swiping brings you into a new screen.
### History Screen
History provides a table view of all your finished workouts sorted from most recent to least. Each cell provides minor details of the workout such as Duration, Type of workout and The average heart rate of the workout. Clicking on a cell opens a more detailed view of the workout with a graph that allows you to pan threw it. At the top theres a back button, type of workout in the middle and a share button that opens the share dialog and shares a screenshot of the current view. At the bottom Information about calories burned, minimun/average and max heart rate are displayed.
### Setting Screen
Settings provides a table view with a range of modifiable settings from personal info to app details. User is allowed to change age, weight, sex. Remove or include health access. Change between units, connect or disconnect bluetooth heart rate monitors and log out from the app.

## Techonologies/Frameworks Used
* CoreBluetooth - For access heart rate monitor data
* HealthKit - For store workout data, retreive personal data such as sex, age, weight
* AVFoundation - For speech utterance 
* MapKit/CLLocation - For displaying map in the background and storing run distances
* CoreGraphics - For displaying workout data in line graphs
* FacebookSDK - Login users
* Parse/CloudKit - Backend storage of workout data

