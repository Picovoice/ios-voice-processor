//
//  Copyright 2021 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import AVFoundation

public class VoiceProcessor {
    public static let shared: VoiceProcessor = VoiceProcessor()
    
    private let numBuffers = 3
    private var audioQueue: AudioQueueRef?
    private var audioCallback: (([Int16]) -> Void)?
    private var frameLength: UInt32?
    private var bufferRef: AudioQueueBufferRef?
    
    private var started = false
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance())
    }
    
    public func hasPermissions() throws -> Bool {
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            return false
        }
        
        return true
    }
    
    public func start(
        frameLength: UInt32,
        sampleRate: UInt32,
        audioCallback: @escaping (([Int16]) -> Void),
        formatID: AudioFormatID = kAudioFormatLinearPCM,
        formatFlags: AudioFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
        bytesPerPacket: UInt32 = 2,
        framesPerPacket: UInt32 = 1,
        bytesPerFrame: UInt32 =  2,
        channelsPerFrame: UInt32 = 1,
        bitsPerChannel: UInt32 = 16,
        reserved: UInt32 = 0
    ) throws {
        if started {
            return
        }
        
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        var format = AudioStreamBasicDescription(
            mSampleRate: Float64(sampleRate),
            mFormatID: formatID,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
            mBytesPerPacket: bytesPerPacket,
            mFramesPerPacket: framesPerPacket,
            mBytesPerFrame: bytesPerFrame,
            mChannelsPerFrame: channelsPerFrame,
            mBitsPerChannel: bitsPerChannel,
            mReserved: reserved)
        
        let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        AudioQueueNewInput(&format, createAudioQueueCallback(), userData, nil, nil, 0, &audioQueue)
        
        guard let queue = audioQueue else {
            return
        }
        
        self.frameLength = frameLength;
        self.audioCallback = audioCallback

        let bufferSize = frameLength * 2
        for _ in 0..<numBuffers {
            AudioQueueAllocateBuffer(queue, bufferSize, &self.bufferRef)
            if let buffer = bufferRef {
                AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
            }
        }

        AudioQueueStart(queue, nil)
        started = true
    }
    
    public func stop() {
        guard self.started else {
            return
        }
        guard let audioQueue = audioQueue else {
            return
        }
        AudioQueueFlush(audioQueue)
        AudioQueueStop(audioQueue, true)
        AudioQueueDispose(audioQueue, true)
        audioCallback = nil
        started = false
    }
    
    private func createAudioQueueCallback() -> AudioQueueInputCallback {
        return { userData, queue, bufferRef, startTimeRef, numPackets, packetDescriptions in
            // `self` is passed in as userData in the audio queue callback.
            guard let userData = userData else {
                return
            }
            
            let `self` = Unmanaged<VoiceProcessor>.fromOpaque(userData).takeUnretainedValue()
            
            guard let frameLength = self.frameLength else {
                return
            }
            
            if frameLength == numPackets {
                let ptr = bufferRef.pointee.mAudioData.assumingMemoryBound(to: Int16.self)
                let pcm = Array(UnsafeBufferPointer(start: ptr, count: Int(frameLength)))
                
                if let audioCallback = self.audioCallback {
                    audioCallback(pcm)
                }
            }
            
            AudioQueueEnqueueBuffer(queue, bufferRef, 0, nil)
        }
    }
    
    @objc private func handleInterruption(_ notification: NSNotification) {
        guard self.started else {
            return
        }
        guard let audioQueue = audioQueue else {
            return
        }
        
        guard let info = notification.userInfo,
        let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
        let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .ended {
            guard let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                AudioQueueEnqueueBuffer(audioQueue, self.bufferRef!, 0, nil)
                AudioQueueStart(audioQueue, nil)
            }

        } else if type == .began {
            AudioQueueStop(audioQueue, true)
        }
    }
}
