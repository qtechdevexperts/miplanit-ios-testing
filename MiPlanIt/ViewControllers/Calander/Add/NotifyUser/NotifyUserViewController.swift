//
//  NotifyUserViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol NotifyUserViewControllerDelegate: AnyObject {
    func notifyUserViewController(_ viewController: NotifyUserViewController, selected users: [CalendarUser])
}

class NotifyUserViewController: UserSelectionBaseViewController {
    
    var selectedInvitees: [OtherUser] = []
    weak var delegate: NotifyUserViewControllerDelegate?
    
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet var lottieLoaderAnimation: LottieAnimationView!
    @IBOutlet weak var viewFetchContact: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        self.fillSelectedInvitees()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Override Methods
    override func readPageTitle() -> String? {
        return Strings.notifyUser
    }
    
    override func readTableTitle() -> String? {
        return Strings.empty
    }
    
    override func readPlaceHolder() -> String? {
        return Strings.selectUser
    }
    
    override func startContactFetching() {
        self.viewFetchContact.isHidden = false
        self.textFieldSearchUser.isEnabled = false
        self.lottieLoaderAnimation.loopMode = .loop
        self.lottieLoaderAnimation.play()
    }
    
    override func stopContactFetching() {
        self.viewFetchContact.isHidden = true
        self.textFieldSearchUser.isEnabled = true
        if self.lottieLoaderAnimation.isAnimationPlaying { self.lottieLoaderAnimation.stop() }
    }
    
    override func sendSelectedUsers(_ options: [CalendarUser]) {
        self.delegate?.notifyUserViewController(self, selected: options)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
