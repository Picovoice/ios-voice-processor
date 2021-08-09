#
# Copyright 2021 Picovoice Inc.
# You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
# file accompanying this source.
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#

Pod::Spec.new do |s|
  s.name             = 'ios-voice-processor'
  s.version          = '1.0.2'
  s.summary          = 'A cocoapod library for real-time voice processing.'
  s.description      = <<-DESC
A voice processing library for ios. Has basic functionality to check record permissions, start recording, stop recording and processor
frames while recording.
                       DESC

  s.homepage         = 'https://github.com/Picovoice/ios-voice-processor'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'ksyeo1010' => 'kyeo@picovoice.ai' }
  s.source           = { :git => 'https://github.com/Picovoice/ios-voice-processor.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'VoiceProcessor.swift'
  s.frameworks = 'AVFoundation'
  
end
