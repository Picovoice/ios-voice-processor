//
//  Copyright 2023 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import AVFoundation
import XCTest

import ios_voice_processor

class VoiceProcessorTests: XCTestCase {

    let frameLength: UInt32 = 512
    let sampleRate: UInt32 = 16000

    var frameCount = 0
    var errorCount = 0

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testBasic() throws {
        let voiceProcessor = VoiceProcessor.instance

        let vpFrameListener = VoiceProcessorFrameListener { frame in
            XCTAssert(frame.count == self.frameLength)
            self.frameCount += 1
        }

        let vpErrorListener = VoiceProcessorErrorListener { error in
            print("\(error.errorDescription!)")
            self.errorCount += 1
        }

        XCTAssert(voiceProcessor.isRecording == false)
        voiceProcessor.addFrameListener(vpFrameListener)
        voiceProcessor.addErrorListener(vpErrorListener)
        try voiceProcessor.start(frameLength: frameLength, sampleRate: sampleRate)
        XCTAssertEqual(voiceProcessor.frameLength, frameLength)
        XCTAssertEqual(voiceProcessor.sampleRate, sampleRate)
        XCTAssert(voiceProcessor.isRecording == true)

        sleep(3)

        try voiceProcessor.stop()

        XCTAssert(frameCount > 0)
        XCTAssert(errorCount == 0)
        XCTAssert(voiceProcessor.isRecording == false)

        voiceProcessor.clearErrorListeners()
        voiceProcessor.clearFrameListeners()
        frameCount = 0
        errorCount = 0
    }

    func testInvalidSetup() throws {
        let voiceProcessor = VoiceProcessor.instance

        XCTAssertThrowsError(try voiceProcessor.start(frameLength: 0, sampleRate: 16000)) { error in
            XCTAssert(error is VoiceProcessorArgumentError)
        }

        XCTAssertThrowsError(try voiceProcessor.start(frameLength: 512, sampleRate: 0)) { error in
            XCTAssert(error is VoiceProcessorArgumentError)
        }

        try voiceProcessor.start(frameLength: frameLength, sampleRate: sampleRate)

        XCTAssertThrowsError(try voiceProcessor.start(frameLength: 1024, sampleRate: 44100)) { error in
            XCTAssert(error is VoiceProcessorArgumentError)
        }

        try voiceProcessor.stop()
    }

    func testAddRemoveListeners() {
        let voiceProcessor = VoiceProcessor.instance

        let frameListener1 = VoiceProcessorFrameListener({ _ in })
        let frameListener2 = VoiceProcessorFrameListener({ _ in })

        let errorListener1 = VoiceProcessorErrorListener({ _ in })
        let errorListener2 = VoiceProcessorErrorListener({ _ in })

        voiceProcessor.addFrameListener(frameListener1)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 1)
        voiceProcessor.addFrameListener(frameListener2)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 2)
        voiceProcessor.removeFrameListener(frameListener1)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 1)
        voiceProcessor.removeFrameListener(frameListener1)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 1)
        voiceProcessor.removeFrameListener(frameListener2)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 0)

        let frameListeners: [VoiceProcessorFrameListener] = [frameListener1, frameListener2]
        voiceProcessor.addFrameListeners(frameListeners)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 2)
        voiceProcessor.removeFrameListeners(frameListeners)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 0)
        voiceProcessor.addFrameListeners(frameListeners)
        XCTAssertEqual(voiceProcessor.numFrameListeners, 2)
        voiceProcessor.clearFrameListeners()
        XCTAssertEqual(voiceProcessor.numFrameListeners, 0)

        voiceProcessor.addErrorListener(errorListener1)
        XCTAssertEqual(voiceProcessor.numErrorListeners, 1)
        voiceProcessor.addErrorListener(errorListener2)
        XCTAssertEqual(voiceProcessor.numErrorListeners, 2)
        voiceProcessor.removeErrorListener(errorListener1)
        XCTAssertEqual(voiceProcessor.numErrorListeners, 1)
        voiceProcessor.removeErrorListener(errorListener1)
        XCTAssertEqual(voiceProcessor.numErrorListeners, 1)
        voiceProcessor.removeErrorListener(errorListener2)
        XCTAssertEqual(voiceProcessor.numErrorListeners, 0)
        voiceProcessor.addErrorListener(errorListener1)
        XCTAssertEqual(voiceProcessor.numErrorListeners, 1)
        voiceProcessor.clearErrorListeners()
        XCTAssertEqual(voiceProcessor.numErrorListeners, 0)
    }
}
