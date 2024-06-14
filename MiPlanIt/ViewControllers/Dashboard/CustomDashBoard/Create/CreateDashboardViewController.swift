//
//  CreateDashboardViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 12/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CreateDashboardViewControllerDelegate: class {
    func createDashboardViewController(_ createDashboardViewController: CreateDashboardViewController, updatedDashBord: Dashboard)
}

class CreateDashboardViewController: UIViewController {
    
    var dashboardModel: Dashboard = Dashboard()
    
    lazy var userAvailablePlanItCalendars: [PlanItCalendar] = {
        let availableCalendars = DatabasePlanItCalendar().readAllPlanitCalendars()
        return availableCalendars.filter({ return $0.calendarType == 0 || $0.createdBy?.readValueOfUserId() == Session.shared.readUserId() })
    }()
    
    var allAddedTags: [DashboardTag] = []
    
    var showAddedTags: [DashboardTag] = [] {
        didSet {
            self.collectionViewTags.reloadData()
        }
    }
    
    var allSections: [DashboardSectionType] = [.event, .gift, .purchase, .shopping, .todo]
    
    var excludedSection: [DashboardSectionType] = []
    var customDashboardProfiles: [CustomDashboardProfile] = []
    
    weak var delegate: CreateDashboardViewControllerDelegate?

    @IBOutlet weak var buttonUploadProfilePic: ProcessingButton!
    @IBOutlet weak var imageViewDashboardPic: UIImageView!
    @IBOutlet weak var textFieldName: SpeechTextField!
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var buttonCloseSearch: UIButton!
    @IBOutlet weak var buttonShowHideSearch: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var buttonEvent: UIButton!
    @IBOutlet weak var buttonTodo: UIButton!
    @IBOutlet weak var buttonShopping: UIButton!
    @IBOutlet weak var buttonPurchase: UIButton!
    @IBOutlet weak var buttonGift: UIButton!
    @IBOutlet weak var buttonAddPic: UIButton!
    @IBOutlet weak var buttonEditPic: UIButton!
    @IBOutlet weak var collectionViewTags: UICollectionView!
    @IBOutlet weak var buttonDone: ProcessingButton!
    @IBOutlet weak var buttonSelectAll: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseDashboardDetails()
        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isHelpShown() {
            self.performSegue(withIdentifier: "toCreateDBHelp", sender: nil)
            Storage().saveBool(flag: true, forkey: UserDefault.createDashboardHelp)
        }
    }
    
    @IBAction func helpButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toCreateDBHelp", sender: nil)
        Storage().saveBool(flag: true, forkey: UserDefault.createDashboardHelp)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func buttonBackClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectUnselectAllClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.updateTagSelection(isSelected: sender.isSelected)
    }
    
    @IBAction func buttonDoneClicked(_ sender: UIButton) {
        if self.validateData() {
            self.updateDashboardModel()
            self.saveDashboardToServerUsingNetwotk()
        }
    }

    //MARK: - IBActions

    @IBAction func profilePictureButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    @IBAction func uploadProfileButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func showSearchClicked(_ sender: UIButton) {
        self.viewSearch.isHidden = false
    }
    @IBAction func hideSearchClicked(_ sender: UIButton) {
        self.textFieldSearch.text = Strings.empty
        self.viewSearch.isHidden = true
        self.setShowAddedTags(excludeSections: self.excludedSection.map({ $0.rawValue }), onSearchText: Strings.empty)
    }
    
    @IBAction func excludeSectionClicked(_ sender: UIButton) {
        if self.validateSectionSelection(sender) {
            self.textFieldSearch.text = Strings.empty
            self.viewSearch.isHidden = true
            sender.isSelected ? unSelectButton(sender) : selectButton(sender)
            self.updateSections()
        }
    }
    
    @IBAction func searchTextChanged(_ sender: UITextField) {
        self.updateShowTagOnSearch()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is ProfileMediaDropDownViewController:
            let uploadOptionsDropDownViewController = segue.destination as? ProfileMediaDropDownViewController
            uploadOptionsDropDownViewController?.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
