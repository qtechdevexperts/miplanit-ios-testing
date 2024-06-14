//
//  AssignViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol AssignToDoViewControllerDelegate: class {
    func assignToDoViewController(_ assignToDoViewController: AssignToDoViewController, selectedAssige: CalendarUser?, toDoItems: [PlanItTodo])
}

class AssignToDoViewController: UIViewController {
    
    var selectedUser: AssignUser?
    var filteredUsers: [AssignUser] = []
    var toDoItems: [PlanItTodo] = []
    lazy var calenderUsers: CalendarInvitees = {
        return CalendarInvitees(start: {
            self.startContactFetching()
        }, end: {
            self.stopContactFetching()
            self.refreshUsersView()
        })
    }()
    weak var delegate: AssignToDoViewControllerDelegate?
    var sectionedUser: [[AssignUser]] = []
    
    
    @IBOutlet weak var textFieldSearchUser: UITextField!
    @IBOutlet weak var labelSuggustedUser: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewNewEmail: UIView!
    @IBOutlet weak var labelNewEmail: UILabel!
    @IBOutlet var lottieLoaderAnimation: LottieAnimationView!
    @IBOutlet weak var viewFetchContact: UIView!
    @IBOutlet weak var buttonDone: ProcessingButton?
    
    @IBAction func addNewEmail(_ sender: UIButton) {
        self.assignSelectedUser(CalendarUser(self.textFieldSearchUser.text ?? Strings.empty))
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func textFieldDidChangeText(_ sender: FloatingTextField) {
        self.searchUsersListWithText(sender.text)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUIComponents()
        self.fillSelectedInvitees(user: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillHideNotification, object: nil)
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
