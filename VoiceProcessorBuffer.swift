//
//  Copyright 2023 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

/// A circular buffer for storing 16-bit integer audio samples.
public class VoiceProcessorBuffer {
    private var buffer: [Int16]
    private var readIndex: Int = 0
    private var writeIndex: Int = 0

    /// Initializes a new instance of the circular buffer with the specified size, in number of samples.
    ///
    /// - Parameter size: The size of the circular buffer, in number of samples.
    public init(size: Int) {
        buffer = [Int16](repeating: 0, count: size)
    }

    /// Writes an array of audio samples to the circular buffer.
    ///
    /// - Parameter samples: An array of audio samples to write to the buffer.
    /// - Throws: A `VoiceProcessorReadError` if the buffer overflows and samples are dropped.
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

    /// Reads a specified number of audio samples from the circular buffer.
    ///
    /// - Parameter count: The number of samples to read from the buffer.
    /// - Returns: An array of audio samples read from the buffer.
    ///   Will either be the requested amount, or however many are available if that is less than `count`.
    public func read(count: Int) -> [Int16] {
        var samples: [Int16] = []

        let numToRead = min(Int(count), availableSamples())
        for _ in 0..<numToRead {
            samples.append(buffer[readIndex])
            readIndex = (readIndex + 1) % buffer.count
        }

        return samples
    }

    /// Returns the number of samples that are available to read from the buffer.
    ///
    /// - Returns: The number of available samples in the buffer.
    public func availableSamples() -> Int {
        let diff = writeIndex - readIndex
        return diff >= 0 ? diff : diff + buffer.count
    }
}
