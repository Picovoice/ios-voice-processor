# ios-voice-processor

A Cocoa Pod library for real-time voice processing.

## Usage

### Initialize:

```swift
let voiceProcessor: VoiceProcessor = VoiceProcessor()
```

### Create callback:

```swift
func audioCallback(length: UInt32, pcm: UnsafePointer<Int16>) -> Void {
    if length == 512 {
        print("Recevied pcm with length: ", length)
    }
}
```

### Start Audio:

```swift
do {
    if try !voiceProcessor.hasPermissions() {
        print("Permissions denied.")
        return
    }

    try voiceProcessor.start(
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
voiceProcessor.stop()
```

## Example

To run the example, go to [Example](/Example).

Run `pod install` and then open the Example directory in xcode. Then run it in your device or simulator.
