//
//  ExpandedMenuViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ExpandedMenuViewControllerDelegate: class {
    func expandedMenuViewControllerAddingCalendar(_ expandedMenuViewController: ExpandedMenuViewController)
    func expandedMenuViewControllerAddingEvent(_ expandedMenuViewController: ExpandedMenuViewController)
    func expandedMenuViewControllerAddingShareLink(_ expandedMenuViewController: ExpandedMenuViewController)
}

class ExpandedMenuViewController: UIViewController {
    
    var menuButton: ExpandingMenuButton!
    var menuButtonFrame: CGRect!
    let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
    weak var delegate: ExpandedMenuViewControllerDelegate?
    var selectedMenu: ExpandMenuType?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       self.menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "calendar-dashboard-add-icon")!, highlightedImage: UIImage(named: "calendar-dashboard-close-icon")!, rotatedImage: UIImage(named: "calendar-dashboard-close-icon")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuButton.center = CGPoint(x: menuButtonFrame.midX, y: menuButtonFrame.midY)
        view.addSubview(menuButton)
        
        let item1 = ExpandingMenuItem(size: self.menuButtonSize, title: Strings.createMiplanitCalendar, image: UIImage(named: "calendar-dashboard-calendar-icon")!, highlightedImage: UIImage(named: "calendar-dashboard-calendar-icon")!, backgroundImage: UIImage(named: "calendar-dashboard-calendar-icon"), backgroundHighlightedImage: UIImage(named: "calendar-dashboard-calendar-icon")) { () -> Void in
            self.selectedMenu = .calendar
            self.menuButton.menuButton.sendActions(for: .touchDown)
        }
        item1.titleColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        let item2 = ExpandingMenuItem(size: self.menuButtonSize, title: Strings.createNewEvent, image: UIImage(named: "calendar-dashboard-event-icon")!, highlightedImage: UIImage(named: "calendar-dashboard-event-icon")!, backgroundImage: UIImage(named: "calendar-dashboard-event-icon"), backgroundHighlightedImage: UIImage(named: "calendar-dashboard-event-icon")) { () -> Void in
            self.selectedMenu = .event
            self.menuButton.menuButton.sendActions(for: .touchDown)
        }
        item2.titleColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        
        let item3 = ExpandingMenuItem(size: self.menuButtonSize, title: Strings.shareCalenlarLink, image: UIImage(named: "calendar-dashboard-shareLink-icon")!, highlightedImage: UIImage(named: "calendar-dashboard-shareLink-icon")!, backgroundImage: UIImage(named: "calendar-dashboard-shareLink-icon"), backgroundHighlightedImage: UIImage(named: "calendar-dashboard-shareLink-icon")) { () -> Void in
            self.selectedMenu = .share
            self.menuButton.menuButton.sendActions(for: .touchDown)
        }
        item3.titleColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        
        menuButton.addMenuItems([item1, item2, item3])
        menuButton.foldingAnimations = [.fade]
        menuButton.expandingAnimations = [.move, .fade]
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            guard let selectedMenu = self.selectedMenu else {
                self.dismiss(animated: false, completion: nil)
                return
            }
            self.dismiss(animated: false) {
                switch selectedMenu {
                case .calendar:
                    self.delegate?.expandedMenuViewControllerAddingCalendar(self)
                case .event:
                    self.delegate?.expandedMenuViewControllerAddingEvent(self)
                case .share:
                    self.delegate?.expandedMenuViewControllerAddingShareLink(self)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.menuButton.menuButton.sendActions(for: .touchDown)
    }
}
