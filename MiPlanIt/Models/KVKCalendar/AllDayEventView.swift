//
//  AllDayEventView.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 02/01/2019.
//

import UIKit

final class AllDayTitleView: UIView {
    init(frame: CGRect, style: AllDayStyle) {
        super.init(frame: frame)
        backgroundColor = style.backgroundColor
        
        let label = UILabel(frame: frame)
        label.frame.size.width = frame.width - 4
        label.frame.origin.x = 2
        label.frame.origin.y = 0
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = style.fontTitle
        if style.titleText == "Tees"{
            print("asd")
        }
        print(style.titleText)
        label.textColor = style.titleColor
        label.text = style.titleText
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol AllDayEventDelegate: AnyObject {
    func didSelectAllDayEvent(_ event: Event, frame: CGRect?)
}

final class AllDayEventView: UIView {
    private let events: [Event]
    weak var delegate: AllDayEventDelegate?
    
    init(events: [Event], frame: CGRect, style: AllDayStyle, date: Date?) {
        self.events = events
        super.init(frame: frame)
        backgroundColor = style.backgroundColor
        
        let startEvents = events.map({ AllDayEvent(id: $0.id, text: $0.text, date: $0.start, color: $0.colorText, bgcolor: $0.backgroundColor, accepted: $0.isAccepted)})
        let endEvents = events.map({ AllDayEvent(id: $0.id, text: $0.text, date: $0.end, color: $0.colorText, bgcolor: $0.backgroundColor, accepted: $0.isAccepted) })
        let result = startEvents + endEvents
        let distinct = result.reduce([]) { (acc, event) -> [AllDayEvent] in
            guard acc.contains(where: { "\($0.id)".hashValue == "\(event.id)".hashValue }) else {
                return acc + [event]
            }
            return acc
        }
//        let filtered = distinct.filter({ $0.date.day == date?.day })
        
        let eventWidth = frame.width / CGFloat(distinct.count)
        for (idx, event) in distinct.enumerated() {
            let label = UILabel(frame: CGRect(x: (CGFloat(idx) * eventWidth) + style.offset,
                                              y: style.offset,
                                              width: eventWidth - (style.offset * 2),
                                              height: frame.height - (style.offset * 2)))
            label.textColor = event.color
            label.isUserInteractionEnabled = true
            label.font = style.font
            label.text = " \(event.text)"
            label.backgroundColor = event.bgcolor
            label.textColor = event.accepted == false ? UIColor.white : event.color
            label.tag = "\(event.id)".hashValue
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnEvent))
            label.addGestureRecognizer(tap)
            addSubview(label)
            self.addDashedBorder(event.accepted, colorValue: event.color, label: label)
        }
    }
    
    func addDashedBorder(_ straightLine: Bool, colorValue: UIColor, label: UILabel) {
        let color = colorValue.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width: label.frame.width, height: label.frame.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: label.frame.width/2, y: label.frame.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = straightLine == false ? UIColor.white.cgColor : color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        if !straightLine {
            shapeLayer.lineDashPattern = [6,3]
        }
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
        label.layer.addSublayer(shapeLayer)
    }
    
    @objc private func tapOnEvent(gesture: UITapGestureRecognizer) {
        guard let hashValue = gesture.view?.tag else { return }
        if let idx = events.firstIndex(where: { "\($0.id)".hashValue == hashValue }) {
            let event = events[idx]
            delegate?.didSelectAllDayEvent(event, frame: gesture.view?.frame)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct AllDayEvent {
    let id: Any
    let text: String
    let date: Date
    let color: UIColor
    let bgcolor: UIColor
    let accepted: Bool
}

extension AllDayEvent: EventProtocol {
    func compare(_ event: Event) -> Bool {
        return "\(id)".hashValue == "\(event)".hashValue
    }
}
