#
# Copyright 2021-2024 Picovoice Inc.
# You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
# file accompanying this source.
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#

Pod::Spec.new do |s|
  s.name             = 'ios-voice-processor'
  s.module_name      = 'ios_voice_processor'
  s.version          = '1.1.2'
  s.summary          = 'An asynchronous iOS audio recording library designed for real-time speech audio processing.'
  s.description      = <<-DESC
  The iOS Voice Processor is an asynchronous audio capture library designed for real-time audio processing.
  Given some specifications, the library delivers frames of raw audio data to the user via listeners.
                       DESC

  s.homepage         = 'https://github.com/Picovoice/ios-voice-processor'
  s.license          = { :type => 'Apache 2.0' }
  s.author           = { 'Picovoice' => 'hello@picovoice.ai' }
  s.source           = { :git => 'https://github.com/Picovoice/ios-voice-processor.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'src/ios_voice_processor/VoiceProcessor*.swift'
  s.frameworks = 'AVFoundation'

end
