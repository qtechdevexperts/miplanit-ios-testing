//
//  DictationAwareTextField.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol DictationAwareTextFieldDelegate: class {
    func dictationDidEnd(_ textField: DictationAwareTextField)
    func dictationDidFail(_ textField: DictationAwareTextField)
    func dictationDidStart(_ textField: DictationAwareTextField)
}

class DictationAwareTextField: UITextField {

    public weak var dictationDelegate: DictationAwareTextFieldDelegate?
    private var lastInputMode: String?
    private(set) var isDictationRunning: Bool = false

    override func dictationRecordingDidEnd() {
        isDictationRunning = false
        dictationDelegate?.dictationDidEnd(self)
    }

    override func dictationRecognitionFailed() {
        isDictationRunning = false
        dictationDelegate?.dictationDidEnd(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(textInputCurrentInputModeDidChange), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func textInputCurrentInputModeDidChange(notification: Notification) {
        guard let inputMode = textInputMode?.primaryLanguage else {
            return
        }

        if inputMode == "dictation" && lastInputMode != inputMode {
            isDictationRunning = true
            dictationDelegate?.dictationDidStart(self)
        }
        lastInputMode = inputMode
    }
}

