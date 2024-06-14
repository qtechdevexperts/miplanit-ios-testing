//
//  InviteUsersViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 10/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol InviteUsersViewControllerDelegate: class {
    func inviteUsersViewController(_ viewController: InviteUsersViewController, selected invitees: CalendarInvitees)
}

class InviteUsersViewController: UIViewController {

    var inviteesDragView: InviteesDragView!
    weak var delegate: InviteUsersViewControllerDelegate?
    
    @IBOutlet var lottieLoaderAnimation: LottieAnimationView!
    @IBOutlet weak var viewFetchContact: UIView!
    @IBOutlet weak var buttonClearSearch: UIButton!
    @IBOutlet weak var textFieldSearchUser: FloatingTextField!
    @IBOutlet weak var collectionViewAllUser: UICollectionView!
    @IBOutlet weak var collectionViewFullPartiaAccessUser: UICollectionView!
    @IBOutlet weak var viewFullAccess: UIView!
    @IBOutlet weak var constraintCollectionViewInviteesHeight: NSLayoutConstraint!
    @IBOutlet weak var labelSuggustedUser: UILabel!
    @IBOutlet weak var buttonHelpIcon: UIButton?
    @IBOutlet weak var viewLabelSuggustedUser: UIView?
    @IBOutlet weak var labelNoInviteesAdded: UILabel?
    
    lazy var calendar: CalendarInvitees = {
        return CalendarInvitees(start: {
            self.startContactLoaderAnimations()
        }, end: {
            self.refreshMiPlanItUsersView()
            self.stopContactLoaderAnimations()
        })
    }()
    
    var filteredUsers: [CalendarUser] = [] {
        didSet {
            self.sectionedUser.removeAll()
            let miPlanItUsers = filteredUsers.filter({ return $0.userType == .miplanit })
            let otherUsers = filteredUsers.filter({ return $0.userType != .miplanit })
            self.sectionedUser.append(miPlanItUsers)
            self.sectionedUser.append(otherUsers)
        }
    }
    
    var sectionedUser: [[CalendarUser]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        guard !self.textFieldSearchUser.isFirstResponder else { self.clearSearchButtonClicked(self.buttonClearSearch); return }
        self.delegate?.inviteUsersViewController(self, selected: self.calendar)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearSearchButtonClicked(_ sender: UIButton) {
        self.textFieldSearchUser.text = Strings.empty
        self.searchUsersListWithText(self.textFieldSearchUser.text)
    }
    
    @IBAction func textFieldDidChangeText(_ sender: FloatingTextField) {
        self.searchUsersListWithText(sender.text)
    }
    
    @IBAction func helpIconClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toHelpScreen, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is InviteesHelpViewController:
            break
//            let inviteesHelpViewController =  segue.destination as! InviteesHelpViewController
//            let partialAccessRect = self.viewPartialAccess.convert(self.viewPartialAccess.bounds, to: self.viewPartialAccess.superview?.superview?.superview)
//            let fullAccessRect = self.viewFullAccess.convert(self.viewFullAccess.bounds, to: self.viewFullAccess.superview?.superview?.superview)
//            inviteesHelpViewController.partialAccessFrameRect = CGRect(x: partialAccessRect.minX+10, y: partialAccessRect.minY, width: partialAccessRect.width-20, height: partialAccessRect.height)
//            inviteesHelpViewController.fullAccessFrameRect = CGRect(x: fullAccessRect.minX+10, y: fullAccessRect.minY, width: fullAccessRect.width-20, height: fullAccessRect.height)
//        case is ShowPopInfoViewController:
//            let showPopInfoViewController = segue.destination as! ShowPopInfoViewController
//            if let user = sender as? InviteesCollectionViewCell, let imageView = user.imageViewProfilePic {
//                var collection: UICollectionView?
//                if let view = user.superview as? UICollectionView, view == self.collectionViewFullAccessUser {
//                    collection = view
//                }
//                if let view = user.superview as? UICollectionView, view == self.collectionViewPartialAccessUser {
//                    collection = view
//                }
//                if let collectionView = collection {
//                    let point: CGPoint = imageView.convert(imageView.bounds.origin, to: collectionView.superview?.superview?.superview?.superview)
//                    if let planItInvitees = user.calenderUser as? PlanItInvitees {
//                        showPopInfoViewController.showPopInfo = ShowPopInfo(imageStartPoint: point, main: planItInvitees.fullName, sub: planItInvitees.email == Strings.empty ? planItInvitees.phone : planItInvitees.email)
//                        showPopInfoViewController.showPopInfo.image = imageView.image
//                    }
//                    else if let calendarUser = user.calenderUser as? CalendarUser {
//                        showPopInfoViewController.showPopInfo = ShowPopInfo(imageStartPoint: point, main: calendarUser.name, sub: calendarUser.email == Strings.empty ? calendarUser.phone : calendarUser.email)
//                        showPopInfoViewController.showPopInfo.image = imageView.image
//                    }
//                }
//            }
        default:
            break
        }
    }
}
