//
//  EventPageView.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 02/01/2019.
//

import UIKit

private let pointX: CGFloat = 2

class EventPageView: UIView {
    weak var delegate: EventPageDelegate?
    let event: Event
    private let timelineStyle: TimelineStyle
    private let color: UIColor
    
    private let textView: UITextView = {
        let text = UITextView()
        text.backgroundColor = .clear
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.textContainer.lineBreakMode = .byTruncatingTail
        text.textContainer.lineFragmentPadding = 0
        text.layoutManager.allowsNonContiguousLayout = true
        let padding = text.textContainer.lineFragmentPadding
        text.textContainerInset =  UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        return text
    }()
    
    private lazy var iconFileImageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 2, width: 10, height: 10))
        image.image = timelineStyle.iconFile?.withRenderingMode(.alwaysTemplate)
        image.tintColor = timelineStyle.colorIconFile
        return image
    }()
    
    private var eventLocationView: UIView = {
        let uiview = UIView()
        return uiview
    }()
    
    init(event: Event, style: Style, frame: CGRect) {  // notAccepted  TEST
        
            self.event = event
            self.timelineStyle = style.timeline
            self.color = .white//EventColor(event.color?.value ?? event.backgroundColor).value
            super.init(frame: frame)
            backgroundColor = event.backgroundColor
            var textFrame = frame
            textFrame.origin.x = pointX 
            textFrame.origin.y = 0
            
            if event.isContainsFile {
                textFrame.size.width = frame.width - iconFileImageView.frame.width - pointX
                iconFileImageView.frame.origin.x = frame.width - iconFileImageView.frame.width - 2
//                if self.event.isAccepted == true{
                    addSubview(iconFileImageView)
//                }
            }
            
            textFrame.size.height = textFrame.height
            textFrame.size.width = textFrame.width - pointX
            textView.frame = textFrame
            textView.font = style.timeline.eventFont
            textView.textColor = event.colorText
            textView.text = event.text
            
            textView.textColor = event.isAccepted == false ? UIColor.white : event.colorText
            
            if !event.location.isEmpty && bounds.width >= 50.0 && bounds.height >= 30.0 && self.willFitInEvent(title: event.text, frame: bounds) && !self.isBusyOrTravelling(event: event) {
                self.eventLocationView.frame = bounds
//                if self.event.isAccepted == true{
                textView.textColor = event.colorText

                    addSubview(eventLocationView)
//                }
                let calendarEventLocation = CalendarEventLocation(frame: self.eventLocationView.bounds)
                calendarEventLocation.configView(event: event)
                    self.eventLocationView.addSubview(calendarEventLocation)
            }
            else {
                    addSubview(textView)
            }
            tag = "\(event.id)".hashValue
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnEvent))
            addGestureRecognizer(tap)
            
            if style.event.isEnableMoveEvent {
                let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(activateMoveEvent))
                longGesture.minimumPressDuration = style.event.minimumPressDuration
                addGestureRecognizer(longGesture)
            }
            self.addDashedBorder(event.isAccepted)
    }
    
    func isBusyOrTravelling(event: Event) -> Bool {
        if let planItEvent = event.eventData as? PlanItEvent {
            let isFullAceesCalendar = event.calendar?.accessLevel == 2
            let eventAccessLevel = planItEvent.accessLevel == 1
            return (isFullAceesCalendar || eventAccessLevel) ? false : true
        }
        else if let otherUserEvent = event.eventData as? OtherUserEvent {
            let eventAccessLevel = otherUserEvent.accessLevel == "1"
            return eventAccessLevel || otherUserEvent.visibility == 0 ? false : true
        }
        return false
    }
    
    func willFitInEvent(title: String, frame: CGRect) -> Bool {
        let labelHeight = title.height(withConstrainedWidth: frame.size.width, font: self.textView.font ?? UIFont.systemFont(ofSize: 13.0))
        return labelHeight + 16 < frame.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapOnEvent(gesture: UITapGestureRecognizer) {
        delegate?.didSelectEvent(event, gesture: gesture)
    }
    
    @objc private func activateMoveEvent(gesture: UILongPressGestureRecognizer) {        
        switch gesture.state {
        case .began:
            delegate?.didStartMoveEventPage(self, gesture: gesture)
        case .changed:
            delegate?.didChangeMoveEventPage(self, gesture: gesture)
        case .cancelled, .ended, .failed:
            delegate?.didEndMoveEventPage(self, gesture: gesture)
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
    }
    
    func addDashedBorder(_ straightLine: Bool) { // stroke color
        let color = self.event.color?.value.cgColor

        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        if !straightLine {
            shapeLayer.lineDashPattern = [6,3]
        }
//        shapeLayer.fillColor = straightLine == false ? UIColor.red.cgColor : color
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
        self.layer.addSublayer(shapeLayer)
    }
}

protocol EventPageDelegate: class {
    func didStartMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer)
    func didEndMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer)
    func didChangeMoveEventPage(_ eventPage: EventPageView, gesture: UILongPressGestureRecognizer)
    func didSelectEvent(_ event: Event, gesture: UITapGestureRecognizer)
}
