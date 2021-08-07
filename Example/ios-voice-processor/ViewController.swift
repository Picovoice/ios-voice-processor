//
//  Copyright 2018-2021 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import UIKit
import ios_voice_processor

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
    var isRecording: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let viewSize = view.frame.size
        let startButtonSize = CGSize(width: 120, height: 120)
        
        startButton.frame.size = startButtonSize
        startButton.frame.origin =
            CGPoint(x: (viewSize.width - startButtonSize.width) / 2, y: (viewSize.height - startButtonSize.height) / 2)
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        startButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleStartButton(_ sender: UIButton) {
        if !isRecording {
            
            do {
                guard try VoiceProcessor.shared.hasPermissions() else {
                    print("Permissions denied.")
                    return
                }
                
                try VoiceProcessor.shared.start(frameLength: 512, sampleRate: 16000, audioCallback: self.audioCallback)
            } catch {
                let alert = UIAlertController(
                        title: "Alert",
                        message: "Could not start voice processor.",
                        preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            isRecording = true
            startButton.setTitle("STOP", for: UIControlState.normal)
        } else {
            VoiceProcessor.shared.stop()
            isRecording = false
            startButton.setTitle("START", for: UIControlState.normal)
        }
    }
    
    private func audioCallback(pcm: UnsafePointer<Int16>) -> Void {
        // do something with pcm
        print("Recevied pcm.")
    }

}

