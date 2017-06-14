# CoreMLVisionDJKhaled

An iOS app that tells you whether your camera is pointed at a lion, using apple's CoreML and Vision APIs.

<p align="center">
	<img src="https://raw.githubusercontent.com/G2Jose/https://github.com/G2Jose/CoreMLVisionDJKhaled/master/screenshots/khaled_another_one.gif"/>
</p>

## Screenshots

<p align="center">
	<img src="https://raw.githubusercontent.com/G2Jose/https://github.com/G2Jose/CoreMLVisionDJKhaled/master/screenshots/lion_detected.png"/>
	<img src="https://raw.githubusercontent.com/G2Jose/https://github.com/G2Jose/CoreMLVisionDJKhaled/master/screenshots/no_lion_detected.png"/>
</p>

## How to use

Make sure you have iOS 11 installed (currently in beta). [beta.applebetas.co](https://beta.applebetas.co/) hosts provisioning profiles for the latest betas for folks that are not signed up for the Apple Developer Program. Build and run the app using Xcode 9 (also currently in beta).

## How it works

The app uses [CoreML](https://developer.apple.com/documentation/coreml) and the inception v3 pre-trained neural network model to make predictions on a stream of images from your device's camera. A liooon is found when the model predicts it with a confidence of >= 30%.

The [Vision API](https://developer.apple.com/documentation/vision) is used in order to process images efficiently (scale & crop to input specs of the model). 
