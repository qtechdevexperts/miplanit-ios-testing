//
//  SpeechToTextRecorder.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Speech
import AudioToolbox

protocol SpeechToTextRecorderDelegate: class {
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, showAlert message: String)
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, setText text: String)
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, multiChannel count: AVAudioChannelCount)
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, speechSuggustionOff status: Bool)
}

class SpeechToTextRecorder {
    
    var audioEngine: AVAudioEngine?
    var speechRecognizer: SFSpeechRecognizer?
    var speechRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    weak var delegate: SpeechToTextRecorderDelegate?
    
    init() {
        self.audioEngine = AVAudioEngine()
        self.speechRecognizer = SFSpeechRecognizer()
        self.speechRequest = SFSpeechAudioBufferRecognitionRequest()
        if #available(iOS 13, *) {
            self.speechRequest?.requiresOnDeviceRecognition = true
        }
    }
    
    @objc func recordAndRecognizeSpeech() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.requestSpeechAuthorization { (status) in
            if status {
                let node = self.audioEngine?.inputNode
                let recordingFormat = node?.outputFormat(forBus: 0)
                if recordingFormat?.channelCount != 1 {
                    self.delegate?.speechToTextRecorder(self, multiChannel: recordingFormat?.channelCount ?? 0)
                    return
                }
                node?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    self.speechRequest?.append(buffer)
                }
                self.audioEngine?.prepare()
                do {
                    try self.audioEngine?.start()
                } catch {
                    print(error)
                    return //message
                }
                guard let myRecognizer = SFSpeechRecognizer() else {
                    return //message
                }
                if !myRecognizer.isAvailable {
                    // Recognizer is not available right now
                    return //message
                }
                self.createRecogonisationTask()
            }
            else {
                self.delegate?.speechToTextRecorder(self, speechSuggustionOff: true)
            }
        }
    }
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization(callback: @escaping (Bool)->Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    callback(true)
                    break
                case .denied:
                    self.delegate?.speechToTextRecorder(self, showAlert: Message.speechRestricted)
                    callback(false)
                case .restricted:
                    self.delegate?.speechToTextRecorder(self, showAlert: Message.speechRestricted)
                    callback(false)
                case .notDetermined:
                   self.delegate?.speechToTextRecorder(self, showAlert: Message.speechRestricted)
                    callback(false)
                @unknown default:
                    callback(false)
                }
            }
        }
    }
    
    fileprivate func createRecogonisationTask() {
        guard let request = self.speechRequest else {
            return
        }
        self.recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let message = result.bestTranscription.formattedString
                print("Message :- \(message)")
                
                let bestString = result.bestTranscription.formattedString
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }
                self.setUpDataOnFields(with: lastString, fullString: message)
                self.clearFields(fullString: message, resultString: lastString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    fileprivate func setUpDataOnFields(with stringText: String, fullString: String){
        self.delegate?.speechToTextRecorder(self, setText: fullString)
    }
    
    fileprivate func clearFields(fullString: String, resultString: String) {
        if resultString == "Clear" || resultString == "clear" {
            self.cancelRecording()
            self.recordAndRecognizeSpeech()
            self.delegate?.speechToTextRecorder(self, setText: Strings.empty)
        }
    }
    
    @objc func cancelRecording() {
        self.recognitionTask?.finish()
        self.recognitionTask = nil
        self.speechRequest?.endAudio()
        self.audioEngine?.stop()
        self.audioEngine?.inputNode.removeTap(onBus: 0)
        self.audioEngine?.reset()
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        self.speechRequest = SFSpeechAudioBufferRecognitionRequest()
        self.speechRecognizer = nil
        self.speechRecognizer = SFSpeechRecognizer()
    }
}
