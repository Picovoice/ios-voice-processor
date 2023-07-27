# iOS Voice Processor Example

This is an example app that demonstrates how to ask for user permissions and capture output from the `VoiceProcessor`.

## Requirements

- [XCode](https://developer.apple.com/xcode/)
- [CocoaPods](https://cocoapods.org/)

## Compatibility

- iOS 11.0+

## Building

Install the `ios-voice-processor` pod:
```console
cd example
pod install
```

Open the generated `ios-voice-processor.xcworkspace` file with XCode and build the project (`Product > Build` or `Product > Run`).

## Usage

Toggle recording on and off with the button in the center of the screen. While recording, the VU meter on the screen will respond to the volume of incoming audio.

## Running the Unit Tests

Ensure you have an iOS device connected or simulator running. Run tests with XCode (`Product > Test`).