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
    private let numBuffers = 3
    private var audioQueue: AudioQueueRef?
    private var audioCallback: ((UInt32, UnsafePointer<Int16>) -> Void)?
    
    public init() {}
    
    public func hasPermissions() throws -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission() == .denied {
            return false
        }
        
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
        
        return true
    }
    
    public func start(
        frameLength: UInt32,
        sampleRate: UInt32,
        audioCallback: @escaping ((UInt32, UnsafePointer<Int16>) -> Void),
        formatID: AudioFormatID = kAudioFormatLinearPCM,
        formatFlags: AudioFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
        bytesPerPacket: UInt32 = 2,
        framesPerPacket: UInt32 = 1,
        bytesPerFrame: UInt32 =  2,
        channelsPerFrame: UInt32 = 1,
        bitsPerChannel: UInt32 = 16,
        reserved: UInt32 = 0
    ) throws {
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
        
        self.audioCallback = audioCallback
        
        let bufferSize = frameLength * 2
        for _ in 0..<numBuffers {
            var bufferRef: AudioQueueBufferRef? = nil
            AudioQueueAllocateBuffer(queue, bufferSize, &bufferRef)
            if let buffer = bufferRef {
                AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
            }
        }
        
        AudioQueueStart(queue, nil)
    }
    
    public func stop() {
        guard let audioQueue = audioQueue else {
            return
        }
        AudioQueueFlush(audioQueue)
        AudioQueueStop(audioQueue, true)
        AudioQueueDispose(audioQueue, true)
        audioCallback = nil
    }
    
    private func createAudioQueueCallback() -> AudioQueueInputCallback {
        return { userData, queue, bufferRef, startTimeRef, numPackets, packetDescriptions in
            
            // `self` is passed in as userData in the audio queue callback.
            guard let userData = userData else {
                return
            }
            let `self` = Unmanaged<VoiceProcessor>.fromOpaque(userData).takeUnretainedValue()
            
            let pcm = bufferRef.pointee.mAudioData.assumingMemoryBound(to: Int16.self)
            
            if let audioCallback = self.audioCallback {
                audioCallback(numPackets, pcm)
            }
            
            AudioQueueEnqueueBuffer(queue, bufferRef, 0, nil)
        }
    }
}
