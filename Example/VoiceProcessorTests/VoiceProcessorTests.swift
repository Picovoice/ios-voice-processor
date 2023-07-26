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

    override func tearDown() {
        super.tearDown()
    }
    
    func testGetInstance() {
        let vp = VoiceProcessor.instance
        if (!vp.hasRecordAudioPermission) {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    XCTFail()
                }
            }
        }
    }
    
    func testBasic() throws {
        let vp = VoiceProcessor.instance

        let vpFrameListener = VoiceProcessorFrameListener { frame in
            XCTAssert(frame.count == self.frameLength)
            self.frameCount += 1
        }

        let vpErrorListener = VoiceProcessorErrorListener { error in
            print("\(error.errorDescription!)")
            self.errorCount += 1
        }

        XCTAssert(vp.isRecording == false)
        vp.addFrameListener(vpFrameListener)
        vp.addErrorListener(vpErrorListener)
        try vp.start(frameLength: frameLength, sampleRate: sampleRate)
        XCTAssert(vp.isRecording == true)

        sleep(1)

        try vp.stop()

        XCTAssert(frameCount > 0)
        XCTAssert(errorCount == 0)
        XCTAssert(vp.isRecording == false)

        vp.clearErrorListeners()
        vp.clearFrameListeners()
        frameCount = 0
        errorCount = 0
    }
    
    func testInvalidSetup() throws {
        let vp = VoiceProcessor.instance

        XCTAssertThrowsError(try vp.start(frameLength: 0, sampleRate: 16000)) { error in
            XCTAssert(error is VoiceProcessorArgumentError)
        }

        XCTAssertThrowsError(try vp.start(frameLength: 512, sampleRate: 0)) { error in
            XCTAssert(error is VoiceProcessorArgumentError)
        }

        try vp.start(frameLength: frameLength, sampleRate: sampleRate)

        XCTAssertThrowsError(try vp.start(frameLength: 1024, sampleRate: 44100)) { error in
            XCTAssert(error is VoiceProcessorArgumentError)
        }

        try vp.stop()
    }

    func testAddRemoveListeners() {
        let vp = VoiceProcessor.instance

        let f1 = VoiceProcessorFrameListener({_ in })
        let f2 = VoiceProcessorFrameListener({_ in })

        let e1 = VoiceProcessorErrorListener({_ in })
        let e2 = VoiceProcessorErrorListener({_ in })

        vp.addFrameListener(f1);
        XCTAssertEqual(vp.numFrameListeners, 1);
        vp.addFrameListener(f2);
        XCTAssertEqual(vp.numFrameListeners, 2);
        vp.removeFrameListener(f1);
        XCTAssertEqual(vp.numFrameListeners, 1);
        vp.removeFrameListener(f1);
        XCTAssertEqual(vp.numFrameListeners, 1);
        vp.removeFrameListener(f2);
        XCTAssertEqual(vp.numFrameListeners, 0);

        let fs: [VoiceProcessorFrameListener] = [f1, f2];
        vp.addFrameListeners(fs);
        XCTAssertEqual(vp.numFrameListeners, 2);
        vp.removeFrameListeners(fs);
        XCTAssertEqual(vp.numFrameListeners, 0);
        vp.addFrameListeners(fs);
        XCTAssertEqual(vp.numFrameListeners, 2);
        vp.clearFrameListeners();
        XCTAssertEqual(vp.numFrameListeners, 0);

        vp.addErrorListener(e1);
        XCTAssertEqual(vp.numErrorListeners, 1);
        vp.addErrorListener(e2);
        XCTAssertEqual(vp.numErrorListeners, 2);
        vp.removeErrorListener(e1);
        XCTAssertEqual(vp.numErrorListeners, 1);
        vp.removeErrorListener(e1);
        XCTAssertEqual(vp.numErrorListeners, 1);
        vp.removeErrorListener(e2);
        XCTAssertEqual(vp.numErrorListeners, 0);
        vp.addErrorListener(e1);
        XCTAssertEqual(vp.numErrorListeners, 1);
        vp.clearErrorListeners();
        XCTAssertEqual(vp.numErrorListeners, 0);
    }
}
