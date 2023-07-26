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

    private var isRecording: Bool = false
    private var recordedAudio: [Int16] = []

    let FRAME_LENGTH: UInt32 = 512
    let SAMPLE_RATE: UInt32 = 16000
    let DUMP_AUDIO: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewSize = view.frame.size
        let startButtonSize = CGSize(width: 120, height: 120)

        startButton.frame.size = startButtonSize
        startButton.frame.origin =
                CGPoint(x: (viewSize.width - startButtonSize.width) / 2, y: (viewSize.height - startButtonSize.height) / 2)
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        startButton.clipsToBounds = true

        let frameListener = VoiceProcessorFrameListener(audioCallback)
        VoiceProcessor.instance.addFrameListener(frameListener)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

            if DUMP_AUDIO {
                recordedAudio.removeAll()
            }

            try VoiceProcessor.instance.start(frameLength: FRAME_LENGTH, sampleRate: SAMPLE_RATE)
        } catch {
            let alert = UIAlertController(
                    title: "Alert",
                    message: "Could not start voice processor.",
                    preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
            self.present(alert, animated: true, completion: nil)
            return
        }
        isRecording = false

        if DUMP_AUDIO {
            do {
                try dumpAudio(audioData: recordedAudio, audioFileName: "ios_voice_processor.wav")
            } catch {
                print("Failed to dump audio: \(error)")
            }
        }
        startButton.setTitle("START", for: UIControl.State.normal)
    }

    private func onUserPermissionResponse(isGranted: Bool) -> Void {
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

    private func audioCallback(frame: [Int16]) -> Void {
        if DUMP_AUDIO {
            recordedAudio.append(contentsOf: frame)
        }
    }

    private func dumpAudio(audioData: [Int16], audioFileName: String) throws {
        let outputDir = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
        print(outputDir)
        let fileUrl = outputDir.appendingPathComponent(audioFileName)

        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try FileManager.default.removeItem(at: fileUrl)
        }
        let audioFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: Double(SAMPLE_RATE),
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

