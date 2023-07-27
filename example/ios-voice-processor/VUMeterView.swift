//
//  Copyright 2023 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import UIKit

class VUMeterView: UIView {

    private let dbfsOffset = 60.0
    private let volumeHistoryCapacity = 5

    private var volumeHistory: [Double] = []
    private var volumeAverage: Double = 0

    public func addVolumeValue(dbfsValue: Double) {

        var adjustedValue = dbfsValue + dbfsOffset
        adjustedValue = (max(0.0, adjustedValue) / dbfsOffset)
        adjustedValue = min(1.0, adjustedValue)

        if volumeHistory.count == volumeHistoryCapacity {
            volumeHistory.removeFirst()
        }
        volumeHistory.append(adjustedValue)
        volumeAverage = volumeHistory.reduce(0, +) / Double(volumeHistory.count)

        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)

        let emptyRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        context?.setFillColor(UIColor.gray.cgColor)
        context?.fill(emptyRect)

        let meterRect = CGRect(x: 0, y: 0, width: bounds.width * CGFloat(volumeAverage), height: bounds.height)
        context?.setFillColor(UIColor(red: 0.216, green: 0.49, blue: 1, alpha: 1).cgColor)
        context?.fill(meterRect)
    }
}
