//
//  AddInviteesViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie


protocol AddInviteesViewControllerDelegate: AnyObject {
    func addInviteesViewController(_ viewController: AddInviteesViewController, selected users: [OtherUser])
}

class AddInviteesViewController: UserSelectionBaseViewController {
    
    var selectedInvitees: [OtherUser] = []
    weak var delegate: AddInviteesViewControllerDelegate?
    
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
        return Strings.addinvitees
    }
    
    override func readTableTitle() -> String? {
        return Strings.addedinvitees
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
        if !options.isEmpty {
            self.readInviteesStatusUsingNetwotk(options)
        }
        else {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.addInviteesViewController(self, selected: [])
        }
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
