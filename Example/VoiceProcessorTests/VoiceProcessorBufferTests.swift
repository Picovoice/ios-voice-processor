import XCTest

import ios_voice_processor

class VoiceProcessorBufferTests: XCTestCase {

    let bufferSize = 512
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testWriteAndRead() {
        let vpBuffer = VoiceProcessorBuffer(size: bufferSize)

        let writeSamples: [Int16] = [1, 2, 3, 4, 5]
        try? vpBuffer.write(samples: writeSamples)

        let readSamples = vpBuffer.read(count: writeSamples.count)
        XCTAssertEqual(readSamples, writeSamples)
    }

    func testAvailableSamples() {
        let writeSamples: [Int16] = [1, 2, 3, 4, 5]
        let vpBuffer = VoiceProcessorBuffer(size: writeSamples.count + 1)
        XCTAssertEqual(vpBuffer.availableSamples(), 0)
        
        try? vpBuffer.write(samples: writeSamples)
        XCTAssertEqual(vpBuffer.availableSamples(), writeSamples.count)

        let readSamples = vpBuffer.read(count: 4)
        XCTAssertEqual(vpBuffer.availableSamples(), writeSamples.count - readSamples.count)
        
        let writeSamples2: [Int16] = [6, 7]
        try? vpBuffer.write(samples: writeSamples2)
        XCTAssertEqual(vpBuffer.availableSamples(), writeSamples.count - readSamples.count + writeSamples2.count)

        let _ = vpBuffer.read(count: 3)
        XCTAssertEqual(vpBuffer.availableSamples(), 0)
    }
    
    func testOverwrite() {
        let samplesToFill: [Int16] = [1, 2, 3, 4, 5]
        let vpBuffer = VoiceProcessorBuffer(size: samplesToFill.count + 1)
        try? vpBuffer.write(samples: samplesToFill)

        let additionalSamples: [Int16] = [6, 7]
        XCTAssertThrowsError(try vpBuffer.write(samples: additionalSamples)) { error in
            XCTAssert(error is VoiceProcessorError)
        }
        
        let expectedSamples: [Int16] = [3, 4, 5, 6, 7]
        let readSamples = vpBuffer.read(count: expectedSamples.count)
        XCTAssertEqual(readSamples, expectedSamples)
    }

    func testReadMoreThanAvailable() {
        let samplesToFill: [Int16] = [1, 2, 3, 4, 5]
        let vpBuffer = VoiceProcessorBuffer(size: samplesToFill.count + 1)
        
        try? vpBuffer.write(samples: samplesToFill)
        let readSamples = vpBuffer.read(count: 10)
        XCTAssertEqual(readSamples.count, samplesToFill.count)
    }

    func testEmpty() {
        let vpBuffer = VoiceProcessorBuffer(size: 5)
        let readSamples = vpBuffer.read(count: 3)
        XCTAssertTrue(readSamples.isEmpty)
    }
}
