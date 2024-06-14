//
//  ImportCalendarBaseViewController.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ImportCalendarBaseViewController: UIViewController {
    
    var addedColorCodes: [ColorCode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getSavedCalendarColor()
    }
    
    @IBAction func calanderTypeIconClicked(_ sender: UIButton) {
        guard let calanderType = MiPlanItEnumCalendarType(rawValue: sender.tag), SocialManager.default.isNetworkReachable() else { return }
        if calanderType == .outlook {
            self.showOutlookWebViewController()
        }
        else {
            self.performSegue(withIdentifier: Segues.toCalanderList, sender: calanderType)
        }
    }
    
    @IBAction func skipButtonClicked(_ sender: Any) { }
    
    @IBAction func cancelButtonClicked(_ sender: Any) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is OutlookWebViewController:
            let outlookWebViewController = segue.destination as! OutlookWebViewController
            outlookWebViewController.delegate = self
        default: break
        }
    }
    
    func showOutlookWebViewController() {
        self.performSegue(withIdentifier: Segues.showOutlookWebViewController, sender: nil)
    }
    
    func getSavedCalendarColor() {
        let availableColorCodes = Storage().getAllColorCodes()
        let calendars = DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.calendarType == 0 || $0.createdBy?.readValueOfUserId() == Session.shared.readUserId() })
        self.addedColorCodes = availableColorCodes.filter({ calendars.compactMap({ $0.calendarColorCode }).contains($0.readColorCodeKey()) })
    }
}
