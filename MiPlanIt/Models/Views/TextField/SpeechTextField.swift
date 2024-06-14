//
//  SpeechTextField.swift
//  MiPlanIt
//
//  Created by Mac8 on 29/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Speech
import IQKeyboardManagerSwift

protocol SpeechTextFieldDelegate: class {
    func speechTextField(_ speechTextField: SpeechTextField, valueChanged text: String)
    func speechTextField(_ speechTextField: SpeechTextField, valueAdded text: String)
}

class SpeechTextField : FloatingTextField {
    
    enum JumpSide {
        case previous , next
    }
    
    var speechToTextRecorder: SpeechToTextRecorder?
    var label: UILabel?
    var normalSpeechAccessoryView: NormalSpeechAccessoryView?
    weak var speechTextFieldDelegate: SpeechTextFieldDelegate?
    private var availableTags: [PlanItTags] = [] {
        didSet {
            showTags = availableTags
        }
    }
    var showTags: [PlanItTags] = []

    @IBInspectable var isSpeechEnabled: Bool = true
    @IBInspectable var isDoneButtonEnabled: Bool = false
    @IBInspectable var isTagAutoCompletionEnabled: Bool = false
    
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
        if self.isSpeechEnabled {
            self.speechToTextRecorder = SpeechToTextRecorder()
            self.speechToTextRecorder?.delegate = self
            self.setCustomSpeechView()
            self.inputAccessoryView = self.normalSpeechAccessoryView
            self.normalSpeechAccessoryView?.constraintButtonWidth.constant =  self.isDoneButtonEnabled ? 60.0 : 0
            if isTagAutoCompletionEnabled {
                let allPlanItTags = DatabasePlanItTags().readAllTags()
                var uniqueTag: [PlanItTags] = []
                allPlanItTags.forEach { (planItTag) in
                    if !uniqueTag.contains { (tag) -> Bool in
                        tag.readTag().lowercased()  == planItTag.readTag().lowercased()
                        } {
                        uniqueTag.append(planItTag)
                    }
                }
                self.availableTags = uniqueTag
            }
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
        let speechLabel = UIBarButtonItem(customView: self.label!)
        let doneButton  = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let speechButton = UIBarButtonItem(customView: self.toolBarButton)
        var items: [UIBarButtonItem]
        if self.isDoneButtonEnabled {
            items = [speechLabel,flexSpace,speechButton,fixedSpaceButton,doneButton ]
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
    
    func filterTag(by text: String) {
        if isTagAutoCompletionEnabled {
            self.showTags = self.availableTags.filter{( $0.readTag().lowercased().contains(text.lowercased()) )}
            self.normalSpeechAccessoryView?.updateAutoCompleteTag(self.showTags.map({ $0.readTag() }))
        }
    }
}


extension SpeechTextField: SpeechToTextRecorderDelegate {
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, speechSuggustionOff status: Bool) {
        
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, showAlert message: String) {
        self.showAlertOntopMostViewController(message: message)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, setText text: String) {
        self.text = text
        self.speechTextFieldDelegate?.speechTextField(self, valueChanged: text)
        if isTagAutoCompletionEnabled {
            self.showTags = self.availableTags.filter{( $0.readTag().lowercased().contains(text.lowercased()) )}
            self.normalSpeechAccessoryView?.updateAutoCompleteTag(self.showTags.map({ $0.readTag() }))
        }
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, multiChannel count: AVAudioChannelCount) {
        self.callInProgressLabel()
    }
}


extension SpeechTextField: NormalSpeechAccessoryViewDelegate {
    
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, autoCompleteTagSelected tag: String) {
        if self.isTagAutoCompletionEnabled {
            self.speechTextFieldDelegate?.speechTextField(self, valueAdded: tag)
        }
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
