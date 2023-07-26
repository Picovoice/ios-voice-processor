public class VoiceProcessorBuffer {
    private var buffer: [Int16]
    private var readIndex: Int = 0
    private var writeIndex: Int = 0

    public init(size: Int) {
        buffer = [Int16](repeating: 0, count: size)
    }

    public func write(samples: [Int16]) throws {
        var numOverwrite = 0
        for sample in samples {
            buffer[writeIndex] = sample
            writeIndex = (writeIndex + 1) % buffer.count

            if writeIndex == readIndex {
                readIndex = (readIndex + 1) % buffer.count
                numOverwrite += 1
            }
        }
        
        if numOverwrite > 0 {
            throw VoiceProcessorReadError("Buffer overflow occurred - \(numOverwrite) samples dropped.")
        }
    }

    public func read(count: Int) -> [Int16] {
        var samples: [Int16] = []

        let numToRead = min(Int(count), availableSamples())
        for _ in 0..<numToRead {
            samples.append(buffer[readIndex])
            readIndex = (readIndex + 1) % buffer.count
        }

        return samples
    }

    public func availableSamples() -> Int {
        let diff = writeIndex - readIndex
        return diff >= 0 ? diff : diff + buffer.count
    }
}
