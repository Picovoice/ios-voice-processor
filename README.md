# iOS Voice Processor

[![GitHub release](https://img.shields.io/github/release/Picovoice/ios-voice-processor.svg)](https://github.com/Picovoice/ios-voice-processor/releases)
[![GitHub](https://img.shields.io/github/license/Picovoice/ios-voice-processor)](https://github.com/Picovoice/ios-voice-processor/)

[![Cocoapods](https://img.shields.io/cocoapods/v/ios-voice-processor)](https://github.com/CocoaPods/Specs/tree/master/Specs/8/5/4/ios-voice-processor)

Made in Vancouver, Canada by [Picovoice](https://picovoice.ai)

<!-- markdown-link-check-disable -->
[![Twitter URL](https://img.shields.io/twitter/url?label=%40AiPicovoice&style=social&url=https%3A%2F%2Ftwitter.com%2FAiPicovoice)](https://twitter.com/AiPicovoice)
<!-- markdown-link-check-enable -->
[![YouTube Channel Views](https://img.shields.io/youtube/channel/views/UCAdi9sTCXLosG1XeqDwLx7w?label=YouTube&style=social)](https://www.youtube.com/channel/UCAdi9sTCXLosG1XeqDwLx7w)

The iOS Voice Processor is an asynchronous audio capture library designed for real-time audio
processing. Given some specifications, the library delivers frames of raw audio data to the user via
listeners.

## Table of Contents

- [iOS Voice Processor](#ios-voice-processor)
    - [Table of Contents](#table-of-contents)
    - [Requirements](#requirements)
    - [Compatibility](#compatibility)
    - [Installation](#installation)
    - [Permissions](#permissions)
    - [Usage](#usage)
        - [Capturing with Multiple Listeners](#capturing-with-multiple-listeners)
    - [Example](#example)

## Requirements

- [XCode](https://developer.apple.com/xcode/)
- [CocoaPods](https://cocoapods.org/)

## Compatibility

- iOS 11.0+

## Installation

iOS Voice Processor is available via CocoaPods. To import it into your iOS project, add the following line to your Podfile:
```ruby
pod 'ios-voice-processor'
```

## Permissions

To enable recording with your iOS device's microphone you must add the following to your app's `Info.plist` file:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>[Permission explanation]</string>
```

See our [example app](./example) or [this guide](https://developer.apple.com/documentation/avfaudio/avaudiosession/1616601-requestrecordpermission) for how to properly request this permission from your users.

## Usage

Access the singleton instance of `VoiceProcessor`:

```swift
import ios_voice_processor

let voiceProcessor = VoiceProcessor.instance
```

Add listeners for audio frames and errors:

```swift
let frameListener = VoiceProcessorFrameListener { frame in
    // use audio
}

let errorListener = VoiceProcessorErrorListener { error in
    // handle error
}

voiceProcessor.addFrameListener(frameListener);
voiceProcessor.addErrorListener(errorListener);
```

Start audio capture with the desired frame length and audio sample rate:

```swift
do {
    try voiceProcessor.start(frameLength: 512, sampleRate: 16000);
} catch {
    // handle start error
}
```

Stop audio capture:
```swift
do {
    try voiceProcessor.stop();
} catch {
}
```

Once audio capture has started successfully, any frame listeners assigned to the `VoiceProcessor`
will start receiving audio frames with the given `frameLength` and `sampleRate`.

### Capturing with Multiple Listeners

Any number of listeners can be added to and removed from the `VoiceProcessor` instance. However,
the instance can only record audio with a single audio configuration (`frameLength` and `sampleRate`),
which all listeners will receive once a call to `start()` has been made. To add multiple listeners:
```swift
let listener1 = VoiceProcessorFrameListener({_ in })
let listener2 = VoiceProcessorFrameListener({_ in })
let listeners: [VoiceProcessorFrameListener] = [listener1, listener2];

voiceProcessor.addFrameListeners(listeners);

voiceProcessor.removeFrameListeners(listeners);
// or
voiceProcessor.clearFrameListeners();
```

## Example

The [iOS Voice Processor app](./example) demonstrates how to ask for user permissions and capture output from the `VoiceProcessor`.

## Releases

### v1.1.0 - July 31, 2023
- Numerous API improvements
- Error handling improvements
- Allow for multiple listeners instead of a single callback function
- Upgrades to testing infrastructure and example app

### v1.0.0 - August 5, 2021

- Initial public release.
