//
//  NavigationDrawerViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GoogleSignIn
class NavigationDrawerViewController: UIViewController {
    
    var selectedOption = NavigationDrawerItem.dashBoard
    
    @IBOutlet weak var imageViewExpiryIcon: UIImageView?
    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet var buttonNavigationItemList: [UIButton]!
    @IBOutlet var labelNavigationItemList: [UILabel]!
    @IBOutlet var iconNavigationItemList: [UIImageView]!
    @IBOutlet var viewNavigationItemList: [UIView]!
    
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var labelNotificationCount: UILabel!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var labelTodoCount: UILabel!
    @IBOutlet weak var viewTodo: UIView!
    @IBOutlet weak var labelShoppingCount: UILabel!
    @IBOutlet weak var viewShopping: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotifications()
        self.initialiseMenuButtons()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let parent = self.parent, parent.isBeingRemoved() {
            self.removeNotifications()
        }
        super.viewDidDisappear(animated)
    }
    
    @IBAction func navigationButtonClicked(_ sender: UIButton) {
        guard let option = NavigationDrawerItem(rawValue: sender.tag) else { return }
        sender.isSelected = true
        self.readMenuView()?.showMenu(show: false)
        switch option {
        case .profile:
            self.navigationController?.storyboard(StoryBoards.profile, setRootViewController: StoryBoardIdentifier.profile, animated: false, fromMenu: true)
//            self.navigationController?.storyboard(StoryBoards.profile, setRootViewController: "UserProfileViewController", animated: false, fromMenu: true) // For direct todo the signup profile screen

        case .dashBoard:
            if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
                self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard, animated: false, fromMenu: true)
            }
            else  {
                self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard, animated: false, fromMenu: true)
            }
        case .calendar:
            self.navigationController?.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar, animated: false, fromMenu: true)
        case .myTask:
             self.navigationController?.storyboard(StoryBoards.myTask, setRootViewController: StoryBoardIdentifier.todoBase, animated: false, fromMenu: true)
        case .shoppingList:
            self.navigationController?.storyboard(StoryBoards.shoppingList, setRootViewController: StoryBoardIdentifier.shoppingList, animated: false, fromMenu: true)
        case .purchase:
            self.navigationController?.storyboard(StoryBoards.purchases, setRootViewController: StoryBoardIdentifier.purchases, animated: false, fromMenu: true)
        case .requests:
            self.navigationController?.storyboard(StoryBoards.requestNotification, setRootViewController: StoryBoardIdentifier.requestNotification, animated: false, fromMenu: true)
        case .giftCoupon:
            self.navigationController?.storyboard(StoryBoards.giftCoupons, setRootViewController: StoryBoardIdentifier.giftCoupons, animated: false, fromMenu: true)
        case .settings:
            self.navigationController?.storyboard(StoryBoards.settings, setRootViewController: StoryBoardIdentifier.settings, animated: false, fromMenu: true)
        case .help:
            self.navigationController?.storyboard(StoryBoards.settings, setRootViewController: StoryBoardIdentifier.help, animated: false, fromMenu: true)
        case .logOut:
            self.showAlertWithAction(message: Message.confirmLogout, title:Message.confirm, items: [Message.ok, Message.cancel]) { (buttonIndex) in
                if buttonIndex == 0 {
                    GIDSignIn.sharedInstance.signOut()

                    self.forceSignOutUserFromAWSServer()
                }
            }
        case .pricing:
            isMenu = false
            selectedOption = .pricing
            self.navigationController?.storyboard(StoryBoards.pricing, setRootViewController: StoryBoardIdentifier.pricingViewController, animated: false, fromMenu: true)

        }
    }
}
