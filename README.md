## EatUps - _Location based meetup app for finding someone to eat with 🍽_

# Inspiration
Coming fresh into college, we found it difficult to match up our schedules with our friends. We also were eager to meet new people but sitting next to a random stranger can be very intimidating. That's why we created EatUps: an app thats you to find people in your area so you can meetup and eat!

# What it does
**EatUps** is a location-based meetup app that streamlines the process of finding someone to eat with. Picking a place eat, someone to eat with, and coordinating with them simplified to be as quick and easy as possible! **EatUps** begins with selecting a place to eat from options based on both your current location and organization. (such as universities and workplaces!) After this step, you can pick the perfect dining buddy for the meal from all the available users in your vicinity. Once you've picked someone (and they've accepted your invite), you have a number of ways to coordinate where to eat with them. Don't know what your first text should be? Send an action bubble! These are one-tap actions attached to features that help you locate the person you're eating up with. For example, *What do you see right now?*, which when replied automatically launches the camera so you can take a snapshot of your surroundings. If texting, photos, or sharing location aren't enough, you can also use our AR finder to locate a 3D object superimposed in the location of the other person! 

| ![alt text](https://github.com/abreuboom/EatUps/blob/master/Screens/Choose%20EatUpee%402x.png "Choose Place to Eat") | ![alt text](https://github.com/abreuboom/EatUps/blob/master/Screens/Selected%20EatUpee.png "Choosing an EatUpee") | ![alt text](https://github.com/abreuboom/EatUps/blob/master/Screens/Received%20Invite.png "EatUp Invite") | ![alt text](https://github.com/abreuboom/EatUps/blob/master/Screens/Waiting.png "Waiting for EatUpee") | ![alt text](https://raw.githubusercontent.com/abreuboom/EatUps/master/Screens/Chat.png "Chat with Action Bubbles") |
| Choose Place to Eat | Choosing an EatUpee | EatUp Invite | Waiting for EatUpee | Chat with Action Bubbles |

# How we built it
⋅⋅* Swift 3
⋅⋅* Major Frameworks: ARKit, CoreLocation
⋅⋅* API's: Facebook GraphAPI, Firebase Authentication, Firebase Realtime Database, Google Maps
⋅⋅* Cocoapod: Alamofire, ActiveLabel, YYKit, ARCL, PKHUD, and more

# Challenges we ran into
This project was largely an exercise in iterating as part of a team. Having a three-person was a workflow none of us had experienced before. Couple this with the fact that much of the team was new to iOS development, we regularly faced technical and interpersonal obstacles.

# Accomplishments that we're proud of
We're particularly proud of our usage of the Facebook API and implementing features with mutual friends. Also, designing the schema for our backend (and re-designing it multiple times) was a huge accomplishment. Some individual features that were especially difficult to implement were action bubbles integrated into chat, AR locator, and the various ways we used background location to make the experience more effective.

# What we learned
This project was the first iOS project for many of our team members (an accomplishment in itself) though **EatUps** taught us how to effectively collaborate on a large scale project; both in terms of the technical implementation and the team dynamics.
