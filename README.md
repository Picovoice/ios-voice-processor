# ios-voice-processor

A Cocoa Pod library for real-time voice processing.

## Usage

### Create callback:

```swift
func audioCallback(pcm: [Int16]) -> Void {
    // do something with pcm
    print("Recevied pcm with length: ", pcm.count)
}
```

### Start Audio:

```swift
do {
    guard try VoiceProcessor.shared.hasPermissions() else {
        print("Permissions denied.")
        return
    }

    try VoiceProcessor.shared.start(
        frameLength: 512, 
        sampleRate: 16000, 
        audioCallback: self.audioCallback)
} catch {
    print("Could not start voice processor.")
    return
}
```

### Stop Audio:

```swift
VoiceProcessor.shared.stop()
```

## Example

To run the example, go to [Example](/Example).

Run `pod install` and then open the Example directory in xcode. Then run it in your device or simulator.
