//
//  FloatLabelTextField.swift
//  FloatLabelFields
//
//  Created by Fahim Farook on 28/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Objective-C version by Jared Verdi
//  https://github.com/jverdi/JVFloatLabeledTextField
//
import UIKit

class FloatingTextField: PaddingTextField {
    let animationDuration = 0.3
    var title = UILabel()
    var error = UILabel()
    var underLine: UIImageView!
    var dropDownInput = false
    // MARK:- Properties
    override var accessibilityLabel:String? {
        get {
            if let txt = text , txt.isEmpty {
                return title.text
            } else {
                return text
            }
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
    
    override var placeholder:String? {
        didSet {
            title.text = placeholder
            title.sizeToFit()
        }
    }
    
    override var attributedPlaceholder:NSAttributedString? {
        didSet {
            title.text = attributedPlaceholder?.string
            title.sizeToFit()
        }
    }
    
    var titleFont:UIFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            title.font = titleFont
            title.sizeToFit()
        }
    }
    
    @IBInspectable var hintYPadding:CGFloat = 0.0
    
    @IBInspectable var underLineHeight:CGFloat = 1.0
    
    @IBInspectable var titleYPadding:CGFloat = 0.0 {
        didSet {
            var r = title.frame
            r.origin.y = titleYPadding
            title.frame = r
        }
    }
    
    @IBInspectable var titleTextColour:UIColor = UIColor.gray {
        didSet {
            if !isFirstResponder {
                title.textColor = .gray//titleTextColour
            }
        }
    }
    
    @IBInspectable var titleActiveTextColour:UIColor! {
        didSet {
            if isFirstResponder {
                title.textColor = .gray//titleActiveTextColour
            }
        }
    }
    
    @IBInspectable var underLineColor:UIColor =  UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0) {
        didSet {
            if isFirstResponder {
                title.textColor = .gray//titleActiveTextColour
            }
        }
    }
    
    @IBInspectable var errorText:String? {
        didSet {
            error.text = errorText
            error.sizeToFit()
        }
    }
    
    @IBInspectable var errorTextColour:UIColor = UIColor.red {
        didSet {
            if !isFirstResponder {
                error.textColor = errorTextColour
            }
        }
    }
    
    @IBInspectable var bottomLineEnabled: Bool = true {
        didSet {
            self.underLine.isHidden = !bottomLineEnabled
        }
    }
    
    // MARK:- Init
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    // MARK:- Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitlePositionForTextAlignment()
        setErrorPositionForTextAlignment()
        let isResp = isFirstResponder
        if let txt = text , !txt.isEmpty && isResp {
            title.textColor = .gray//titleActiveTextColour
        } else {
            title.textColor = .gray//titleTextColour
        }
        self.underLine.frame = CGRect(x: 0, y: self.frame.size.height-1, width : self.frame.size.width, height : self.underLineHeight)
        // Should we show or hide the title label?
        if let txt = text , txt.isEmpty {
            // Hide
            hideTitle(isResp)
        } else {
            // Show
            showTitle(isResp)
        }
    }
    
    @discardableResult override open func becomeFirstResponder() -> Bool {
        self.hideError(true)
        return super.becomeFirstResponder()
    }
    
    override func textRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.textRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return r.integral
    }
    
    override func editingRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.editingRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return r.integral
    }
    
    override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.clearButtonRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = CGRect(x:r.origin.x, y:r.origin.y + (top * 0.5), width:r.size.width, height:r.size.height)
        }
        return r.integral
    }
    
    // MARK:- Public Methods
    
    // MARK:- Private Methods
    fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
        titleActiveTextColour = UIColor.lightGray
        // Set up title label
        title.alpha = 0.0
        title.font = titleFont
        title.textColor = .gray//titleTextColour
        if let str = placeholder , !str.isEmpty {
            title.text = str
            title.sizeToFit()
        }
        self.addSubview(title)
        
        error.alpha = 0.0
        error.font = titleFont
        error.textColor = errorTextColour
        error.textAlignment = .right
        self.addSubview(error)
        ///
        self.underLine = UIImageView()
        underLine.backgroundColor = UIColor.init(red: 197/255.0, green: 197/255.0, blue: 197/255.0, alpha: 0.8)
        underLine.frame = CGRect(x: 0, y: self.frame.size.height-1, width : self.frame.size.width, height : 2)
        underLine.clipsToBounds = false
        self.addSubview(underLine)
    }
    
    fileprivate func maxTopInset()->CGFloat {
        if let fnt = font {
            return max(0, floor(bounds.size.height - fnt.lineHeight - 4.0))
        }
        return 0
    }
    
    fileprivate func setTitlePositionForTextAlignment() {
        let r = textRect(forBounds: bounds)
        var x = r.origin.x
        if textAlignment == NSTextAlignment.center {
            x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
        } else if textAlignment == NSTextAlignment.right {
            x = r.origin.x + r.size.width - title.frame.size.width
        }
        title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width, height:title.frame.size.height)
    }
    
    fileprivate func setErrorPositionForTextAlignment() {
        let r = textRect(forBounds: bounds)
        let x = 0
        let y =  underLine.frame.minY
        error.frame = CGRect(x:CGFloat(x), y:y, width:self.frame.width - 2, height:title.frame.size.height)
    }
    
    
    fileprivate func showTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
            // Animation
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding
            self.title.frame = r
            self.underLine.backgroundColor = self.error.alpha == 0 ? #colorLiteral(red: 0.3647058824, green: 0.3529411765, blue: 0.4431372549, alpha: 1) : self.underLine.backgroundColor
        }, completion:nil)
    }
    
    fileprivate func hideTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
            // Animation
            self.title.alpha = 0.0
            var r = self.title.frame
            r.origin.y = self.title.font.lineHeight + self.hintYPadding
            self.title.frame = r
            self.underLine.backgroundColor = UIColor.init(red: 197/255.0, green: 197/255.0, blue: 197/255.0, alpha: 0.8)
        }, completion:nil)
    }
    
    func showError(_ error: String? = Strings.empty, animated:Bool) {
        self.error.text = error ?? self.errorText
        let dur = animated ? animationDuration : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: dur, delay:0.0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
                // Animation
                self.error.alpha = 1.0
                var r = self.error.frame
                r.origin.y =  self.underLine.frame.maxY + 5
                self.error.frame = r
                self.underLine.backgroundColor = self.errorTextColour
            }, completion:nil)
        }
    }
       
    func hideError(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
            // Animation
            self.error.alpha = 0.0
            var r = self.error.frame
            r.origin.y = self.underLine.frame.minY
            self.error.frame = r
            self.underLine.backgroundColor = self.underLineColor
        }, completion:nil)
    }
}
