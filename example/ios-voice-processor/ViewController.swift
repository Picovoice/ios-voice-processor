//
//  Copyright 2021-2023 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import AVFoundation
import UIKit

import ios_voice_processor

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var vuMeterView: VUMeterView!

    private let frameLength: UInt32 = 512
    private let sampleRate: UInt32 = 16000
    private let dumpAudio: Bool = false

    private var isRecording: Bool = false
    private var recordedAudio: [Int16] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewSize = view.frame.size
        let startButtonSize = CGSize(width: 120, height: 120)

        startButton.frame.size = startButtonSize
        startButton.frame.origin = CGPoint(
                x: (viewSize.width - startButtonSize.width) / 2,
                y: (viewSize.height - startButtonSize.height - 40))
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        startButton.clipsToBounds = true

        let vuMeterSize = CGSize(width: view.frame.width - 20, height: 80)
        vuMeterView.frame.size = vuMeterSize
        vuMeterView.frame.origin = CGPoint(
                x: (viewSize.width - vuMeterSize.width) / 2,
                y: (viewSize.height - vuMeterSize.height) / 2)
        vuMeterView.clipsToBounds = true

        let frameListener = VoiceProcessorFrameListener(audioCallback)
        VoiceProcessor.instance.addFrameListener(frameListener)

        let errorListener = VoiceProcessorErrorListener(errorCallback)
        VoiceProcessor.instance.addErrorListener(errorListener)
    }

    private func audioCallback(frame: [Int16]) {
        if dumpAudio {
            recordedAudio.append(contentsOf: frame)
        }

        let sum = frame.reduce(0) { $0 + (Double($1) * Double($1)) }
        let rms = sqrt(sum / Double(frame.count))

        let dbfs = 20 * log10(rms / Double(INT16_MAX))

        DispatchQueue.main.async {
            self.vuMeterView.addVolumeValue(dbfsValue: dbfs)
        }
    }

    private func errorCallback(error: VoiceProcessorError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                    title: "Alert",
                    message: "Voice processor error: \(error)",
                    preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func toggleStartButton(_ sender: UIButton) {
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }

    private func startRecording() {
        do {
            guard VoiceProcessor.hasRecordAudioPermission else {
                VoiceProcessor.requestRecordAudioPermission(onUserPermissionResponse)
                return
            }

            if dumpAudio {
                recordedAudio.removeAll()
            }

            try VoiceProcessor.instance.start(frameLength: frameLength, sampleRate: sampleRate)
        } catch {
            let alert = UIAlertController(
                    title: "Alert",
                    message: "Could not start voice processor.",
                    preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        isRecording = true
        startButton.setTitle("STOP", for: UIControl.State.normal)
    }

    private func stopRecording() {
        do {
            try VoiceProcessor.instance.stop()
        } catch {
            let alert = UIAlertController(
                    title: "Alert",
                    message: "Could not stop voice processor.",
                    preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        isRecording = false

        if dumpAudio {
            do {
                try dumpAudio(audioData: recordedAudio, audioFileName: "ios_voice_processor.wav")
            } catch {
                print("Failed to dump audio: \(error)")
            }
        }
        startButton.setTitle("START", for: UIControl.State.normal)
    }

    private func onUserPermissionResponse(isGranted: Bool) {
        DispatchQueue.main.async {
            if isGranted {
                self.startRecording()
            } else {
                let alert = UIAlertController(
                        title: "Alert",
                        message: "Need record audio permission for demo.",
                        preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func dumpAudio(audioData: [Int16], audioFileName: String) throws {
        let outputDir = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
        let fileUrl = outputDir.appendingPathComponent(audioFileName)

        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try FileManager.default.removeItem(at: fileUrl)
        }
        let audioFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: Double(sampleRate),
                channels: 1,
                interleaved: true)!

        let audioFile = try AVAudioFile(
                forWriting: fileUrl,
                settings: audioFormat.settings,
                commonFormat: .pcmFormatInt16,
                interleaved: true)

        let writeBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(audioData.count))!
        memcpy(writeBuffer.int16ChannelData![0], audioData, audioData.count * 2)
        writeBuffer.frameLength = UInt32(audioData.count)

        try audioFile.write(from: writeBuffer)
    }
}
