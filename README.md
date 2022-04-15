[![Build](https://github.com/Guardian-App-ATU/guardian_app/actions/workflows/flutter.yml/badge.svg)](https://github.com/Guardian-App-ATU/guardian_app/actions/workflows/flutter.yml)

# Guardian App - A Flutter Project (STUDENT ID: G00376658)
This project has been created as part of my ATU (Atlantic Technological University) dissertation project, the dissertation document is not publicly available.

## Learning Goals
Become familiarized with the Flutter infrastructure, as well as learn how to use the Firebase BaaS with tight coupling between both of those services. To learn services provided by Firebase, such as Authentication, Cloud Functions and Firestore.

## Apps Goal
The app was modelled after the popular Life360 mobile application - I wanted to recreate something basic along the lines of that app and how capable is the Flutter framework.

## To Run This Locally
1. Clone this repo
2. Install [Dart](https://dart.dev/get-dart) and [Flutter SDK](https://docs.flutter.dev/get-started/install) and follow their instructors (outlining them here would be redundant)
3. Add Flutter to your Path
4. Run `flutter doctor` in your terminal to ensure your installation is correct and that all licenses have been accepted.
5. Run `flutter pub get` in your terminal (in the folder you've cloned the project to) to download dependencies.
6. You should now be able to build this project yourself, follow [this](https://docs.flutter.dev/deployment/android).

Please mind, that there are several third-party APIs integrated into this project. As such, Google Login/Maps will not actually work due to the API key being limited to signed applications. You'll have to create your own API key and replace it in the code-base manually.
