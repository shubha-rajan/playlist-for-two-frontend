## Playlist for Two

Playlist for Two is a social music discovery app integrated with Spotify that enables users to generate playlists based on common songs, artists, and genres using Spotify's recommendation engine. The (back end)[https://github.com/shubha-rajan/playlist-for-two-backend] for the app was built with Flask and MongoDB and deployed on Heroku. The mobile client for the app is cross-platform (ios/Android) and was built using [Flutter](https://flutter.dev/)

Playlist for Two was developed by Shubha Rajan as a capstone project for [Ada Developers' Academy](https://adadevelopersacademy.org).

## Getting Started

Requirements to try it out:

- A [Spotify](spotify.com) account with a lengthy listening history or number of saved songs and followed artists.
- A mobile phone or emulator.
- A friend who also has both of the above!
- A computer (needs to be Mac if you're trying to run the app on iOS)

## For Developers
- Clone this repository.
- Create a (Spotify Developer)[https://developer.spotify.com/dashboard/] account and make an app to get a client ID and client secret
- (Install and set up Flutter)[https://flutter.dev/docs/get-started/install]
- (Set up the backend)(https://github.com/shubha-rajan/playlist-for-two-backend/) on a local server or deploy it.
- Create a .env file in the repository with the following keys:
``
SPOTIFY_CLIENT_ID={Your client ID}

SPOTIFY_REDIRECT_URI=playlistfortwo://login/callback 

SPOTIFY_USER_ID={Your user ID, this will be the ID of the account used to generate playlists} 

P42_API = {The url where your server is running}
``
- Connect your phone, if you are using a physical phone. Then select your device in your IDE. (If you're using a physical iPhone, you must use Xcode, otherwise, you can use VSCode or Android Studio).
-If you're using iOS, complete the (code signing steps)[https://medium.com/front-end-weekly/how-to-test-your-flutter-ios-app-on-your-ios-device-75924bfd75a8]
- Press the run button if using Xcode, otherwise type "flutter run" in the terminal to build the app on your device/emulator.
