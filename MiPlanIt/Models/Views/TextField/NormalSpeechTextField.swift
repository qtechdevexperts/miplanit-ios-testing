//
//  NormalSpeechTextField.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

import Foundation
import Speech
import IQKeyboardManagerSwift

protocol NormalSpeechTextFieldDelegate: class {
    func normalSpeechTextField(_ normalSpeechTextField: NormalSpeechTextField, test: String)
}

class NormalSpeechTextField : UITextField {
    
    enum JumpSide {
        case previous , next
    }
    
    var speechToTextRecorder: SpeechToTextRecorder?
    var normalSpeechAccessoryView: NormalSpeechAccessoryView?
    var label: UILabel?
    weak var normalSpeechDelegate: NormalSpeechTextFieldDelegate?

    @IBInspectable var isSpeechEnabled: Bool = true
    @IBInspectable var isDoneButtonEnabled: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func becomeFirstResponder() -> Bool {
        if self.isSpeechEnabled {
            self.speechToTextRecorder = SpeechToTextRecorder()
            self.speechToTextRecorder?.delegate = self
            self.setCustomSpeechView()
            self.inputAccessoryView = self.normalSpeechAccessoryView
            self.normalSpeechAccessoryView?.constraintButtonWidth.constant =  self.isDoneButtonEnabled ? 60.0 : 0
        }
        return super.becomeFirstResponder()
    }
    
    @objc func recordAndRecognizeSpeech() {
        self.listining(true)
        self.speechToTextRecorder?.recordAndRecognizeSpeech()
    }
    
    @objc func cancelRecording() {
        self.listining(false)
        self.speechToTextRecorder?.cancelRecording()
    }
    
    fileprivate func setCustomSpeechView() {
        self.normalSpeechAccessoryView = NormalSpeechAccessoryView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        self.normalSpeechAccessoryView?.backgroundColor = UIColor.clear
        self.normalSpeechAccessoryView?.delegate = self
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    fileprivate func showAlertOntopMostViewController(message: String) {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return
        }
        var topController = rootViewController
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        topController.showAlert(message: message, title: Message.warning, preferredStyle: .alert)
    }
    
    func callInProgressLabel() {
        self.normalSpeechAccessoryView?.labelListening.isHidden = false
        self.normalSpeechAccessoryView?.labelListening.text = "Another call in progress."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.normalSpeechAccessoryView?.labelListening.isHidden = true
        }
    }
    
    func listining(_ flag: Bool) {
        self.normalSpeechAccessoryView?.labelListening.isHidden = !flag
        self.normalSpeechAccessoryView?.labelListening.text = flag ? "Listening..." : Strings.empty
    }
}


extension NormalSpeechTextField: SpeechToTextRecorderDelegate {
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, speechSuggustionOff status: Bool) {
        
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, showAlert message: String) {
        self.showAlertOntopMostViewController(message: message)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, setText text: String) {
        self.text = text
        self.normalSpeechDelegate?.normalSpeechTextField(self, test: text)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, multiChannel count: AVAudioChannelCount) {
        self.callInProgressLabel()
    }
}

extension NormalSpeechTextField: NormalSpeechAccessoryViewDelegate {
    
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, autoCompleteTagSelected tag: String) {
        
    }
    
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, touchDown: Any) {
        self.recordAndRecognizeSpeech()
    }
    
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, touchUpInside: Any) {
        self.cancelRecording()
    }
    
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, doneClicked: Any) {
        self.resignFirstResponder()
    }
}
