//
//  AddToDoAccessoryView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Speech
import AudioToolbox

protocol AddToDoAccessoryViewDelegate: class {
    func addToDoAccessoryView(_ addToDoAccessoryView: AddToDoAccessoryView, textField: UITextField)
    func addToDoAccessoryView(_ addToDoAccessoryView: AddToDoAccessoryView, dismiss textField: UITextField)
}

class AddToDoAccessoryView: UIView {
    
    let kCONTENT_XIB_NAME = "AddToDoAccessoryView"
    weak var delegate: AddToDoAccessoryViewDelegate?
    
    var speechToTextRecorder: SpeechToTextRecorder?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textField: DictationAwareTextField!
    @IBOutlet weak var buttonAudio: UIButton!
    @IBOutlet weak var labelListening: UILabel!
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        self.delegate?.addToDoAccessoryView(self, textField: self.textField)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        self.textField.delegate = self
        contentView.fixInView(self)
        textField.dictationDelegate = self
        self.speechToTextRecorder = SpeechToTextRecorder()
        self.speechToTextRecorder?.delegate = self
    }
    
    @IBAction func audioKeyDown(_ sender: UIButton) {
        self.speechToTextRecorder?.recordAndRecognizeSpeech()
        self.labelListening.isHidden = false
    }
    
    @IBAction func audioButtonTaped(_ sender: UIButton) {
        self.speechToTextRecorder?.cancelRecording()
        self.labelListening.isHidden = true
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
}


extension AddToDoAccessoryView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        (textField.text?.isEmpty ?? Strings.empty.isEmpty) ? self.delegate?.addToDoAccessoryView(self, dismiss: textField) : self.delegate?.addToDoAccessoryView(self, textField: textField)
        textField.returnKeyType = .default
        textField.keyboardType = .emailAddress
        textField.reloadInputViews()
        textField.keyboardType = .default
        textField.reloadInputViews()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.returnKeyType = ((textField.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && string.isEmpty) ? .default : .done
        textField.reloadInputViews()
        return true

    }
}

extension AddToDoAccessoryView: DictationAwareTextFieldDelegate {
    
    func dictationDidEnd(_ textField: DictationAwareTextField) {
        self.buttonAudio.isHidden = false
    }
    
    func dictationDidFail(_ textField: DictationAwareTextField) {
        self.buttonAudio.isHidden = false
    }
    
    func dictationDidStart(_ textField: DictationAwareTextField) {
        self.buttonAudio.isHidden = true
    }
    
}

extension AddToDoAccessoryView: SpeechToTextRecorderDelegate {
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, showAlert message: String) {
        self.showAlertOntopMostViewController(message: message)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, setText text: String) {
        self.textField.text = text
        let responding = self.textField.isFirstResponder
        if responding == true {
            self.textField.returnKeyType = text.isEmpty ? .default : .done
            self.textField.reloadInputViews()
        }
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, multiChannel count: AVAudioChannelCount) {
        
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, speechSuggustionOff status: Bool) {
        if status {
            self.labelListening.isHidden = true
        }
    }
}



