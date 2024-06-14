//
//  ShareToDoListViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol ShareToDoListViewControllerDelegate: AnyObject {
    func shareToDoListViewController(_ viewController: ShareToDoListViewController, selected users: [OtherUser])
}

class ShareToDoListViewController: UserSelectionBaseViewController {
    
    var selectedIndexPath: IndexPath?
    var selectedInvitees: [OtherUser] = []
    weak var delegate: ShareToDoListViewControllerDelegate?

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
    override func closeUserSelection() {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        self.dismiss(animated: true) {
            self.delegate?.shareToDoListViewController(self, selected: options.map({ return OtherUser(calendarUser: $0) }))
        }
    }
    
    override func showSelectionUserInfo(_ user: InviteesCollectionViewCell) {
        guard user.imageViewProfilePic != nil else { return }
        self.performSegue(withIdentifier: "showInfoPopUp", sender: user)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is ShowPopInfoViewController:
            let showPopInfoViewController = segue.destination as! ShowPopInfoViewController
            if let user = sender as? InviteesCollectionViewCell, let imageView = user.imageViewProfilePic {
                let point: CGPoint = imageView.convert(imageView.bounds.origin, to: self.collectionViewSelectedUser.superview?.superview?.superview?.superview)
                if let planItInvitees = user.calenderUser as? PlanItInvitees {
                    showPopInfoViewController.showPopInfo = ShowPopInfo(imageStartPoint: point, main: planItInvitees.fullName, sub: planItInvitees.email == Strings.empty ? planItInvitees.phone : planItInvitees.email)
                    showPopInfoViewController.showPopInfo.image = imageView.image
                }
                else if let calendarUser = user.calenderUser as? CalendarUser {
                    showPopInfoViewController.showPopInfo = ShowPopInfo(imageStartPoint: point, main: calendarUser.name, sub: calendarUser.email == Strings.empty ? calendarUser.phone : calendarUser.email)
                    showPopInfoViewController.showPopInfo.image = imageView.image
                }
            }
        default: break
        }
    }

}
