//
//  ShareShoppingViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie


protocol ShareShoppingViewControllerDelegate: class {
    func shareShoppingViewController(_ viewController: ShareShoppingViewController, selected users: [OtherUser])
}

class ShareShoppingViewController: UserSelectionBaseViewController {

    var selectedInvitees: [OtherUser] = []
    weak var delegate: ShareShoppingViewControllerDelegate?
    
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
        return Strings.share
    }
    
    override func readTableTitle() -> String? {
        return Strings.userSelected
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
        self.navigationController?.popViewController(animated: true)
        self.delegate?.shareShoppingViewController(self, selected: options.map({ return OtherUser(calendarUser: $0) }))
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
