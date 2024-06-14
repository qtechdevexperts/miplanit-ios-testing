//
//  SpeechTextView.swift
//  MiPlanIt
//
//  Created by Mac8 on 29/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import Speech

class SpeechTextView : UITextView {
    
    var label: UILabel?
    var speechToTextRecorder: SpeechToTextRecorder?
    
    @IBInspectable var isSpeechEnabled: Bool = true
    @IBInspectable var isDoneButtonEnabled: Bool = true
    
    lazy var toolBarButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(self, action: #selector(self.recordAndRecognizeSpeech), for: .touchDown)
        button.addTarget(self, action: #selector(self.cancelRecording), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "recordselected"), for: .normal)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func becomeFirstResponder() -> Bool {
        if isSpeechEnabled {
            self.speechToTextRecorder = SpeechToTextRecorder()
            self.speechToTextRecorder?.delegate = self
            self.inputAccessoryView = self.addButtonSpeechOnKeyboard()
        }
        return super.becomeFirstResponder()
    }
    
    @objc func recordAndRecognizeSpeech() {
        self.speechToTextRecorder?.recordAndRecognizeSpeech()
    }
    
    @objc func cancelRecording() {
        self.speechToTextRecorder?.cancelRecording()
    }
    
    fileprivate func addButtonSpeechOnKeyboard() -> UIToolbar
    {
        let speechToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        speechToolbar.barStyle = .default
        
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        self.label?.text = "Another call in progress."
        self.label?.isHidden = true
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceButton.width = 10
        let speechButton = UIBarButtonItem(customView: self.toolBarButton)
        let speechLabel = UIBarButtonItem(customView: self.label!)
        let doneButton  = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        var items: [UIBarButtonItem]
        if self.isDoneButtonEnabled {
            items = [speechLabel,flexSpace,speechButton,fixedSpaceButton,doneButton]
        } else {
            items = [speechLabel,flexSpace,speechButton]
        }
        speechToolbar.items = items
        speechToolbar.sizeToFit()
        return speechToolbar
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
}


extension SpeechTextView: SpeechToTextRecorderDelegate {
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, speechSuggustionOff status: Bool) {
        
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, showAlert message: String) {
        self.showAlertOntopMostViewController(message: message)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, setText text: String) {
        self.text = text
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, multiChannel count: AVAudioChannelCount) {
        self.label?.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.label?.isHidden = true
        }
    }
}
