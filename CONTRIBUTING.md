# Contributing

## Setting up

1. Clone this repo.
2. `flutter pub get`
3. Install [Firebase CLI](https://firebase.google.com/docs/cli).
4. Install [Firebase emulator suite](https://firebase.google.com/docs/emulator-suite/install_and_configure).
5. Build firebase functions: `cd firebase/functions/; npm install; npm run build`.
6. Add your development machine's signing certificate SHA256 to Play Integrity / Safety Net as [described below](#play-integrity--safety-net) .

### Play Integrity / Safety Net

Play integrity is the replacement for Safety Net and they are both services which aim to ensure the installed app has not been modified. When running a VeriFi app build made with a dev machine you must add the dev machine's signing certificate SHA256 to an exceptions list as follows:

1. [Get your machine's signing certificate SHA256](https://developers.google.com/android/guides/client-auth?authuser=0&hl=en#using_keytool_on_the_certificate).
2. Add the SHA256 to Play Integrity and Safety Net exceptions. To do so open the [Firebase App Check](https://console.firebase.google.com/u/0/project/verifi-dev/appcheck/apps) page, go to the `Apps` tab and add your SHA256 to the Play Integrity and Safety Net sections for both Android and iOS. Note: you will need to do this for the Firebase environment you are running against, the above link is for VeriFi Dev.

## Running the app

1. Start firebase emulator: `cd firebase; firebase emulators:start`.
<<<<<<< HEAD
2. Build firebase functions: `cd firebase/functions/; npm install; npm run build`.
3. Run the script to populate firestore: `FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 FIRESTORE_EMULATOR_HOST=localhost:8080 python3 init_emulators.py [your latitude] [your longitude]` setting the latitude and longitude to the location where you want the users and access points to be created, probably your location.
4. Start an emulator, this can be done through your IDE or via `flutter emulators --launch [emulator id]`.
5. Run the app either via `./run.sh development` or `flutter run --target="lib/main_development.dart" --flavor development --dart-define=VERIFI_DEV_LOCAL_IP=[your local network ip address]`.
=======
2. Run the script to populate firestore: `FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 FIRESTORE_EMULATOR_HOST=localhost:8080 python3 init_emulators.py [your latitude] [your longitude]` setting the latitude and longitude to the location where you want the users and access points to be created, probably your location.
3. Start an emulator, this can be done through your IDE or via `flutter emulators --launch [emulator id]`.
4. Run the app either via `./run.sh development` or `flutter run --target="lib/main_development.dart" --flavor development --dart-define=VERIFI_DEV_LOCAL_IP=[your local network ip address]`.

## Running tests

### Flutter tests

To run all tests: `flutter test`

To re-record goldens: `flutter test --update-goldens --tags=golden`

### Firebase functions test

`cd firebase/functions/; npm run test`
>>>>>>> f65cd3ce9f84b080486963513dbaf62f1858e08d
