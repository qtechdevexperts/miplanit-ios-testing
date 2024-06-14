//
//  ToDoListBaseViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol ToDoListBaseViewControllerDelegate: class {
    func todoListBaseViewControllerDidChangeTodoItems(_ viewController: ToDoListBaseViewController)
    func todoListBaseViewController(_ viewController: ToDoListBaseViewController, sendTodoReadStatus todos: [PlanItTodo])
}

class ToDoListBaseViewController: UIViewController {
    
    var isCategoryDataUpdated: Bool = false
    var categoryType: ToDoMainCategory = .custom
    var selectedSortValue: DropDownItem? {
        didSet {
            if selectedSortValue != nil {
                self.viewSort?.isHidden = false
                self.buttonSortType.setTitle( "Sort "+(selectedSortValue?.title ?? Strings.empty), for: .normal)
                self.buttonSortType.isSelected = true
                self.buttonSortArrow.isSelected = self.buttonSortType.isSelected
            }
            else {
                self.buttonSortType.isSelected = false
                self.buttonSortArrow.isSelected = self.buttonSortType.isSelected
            }
        }
    }
    var addToDoAccessoryView: AddToDoAccessoryView?
    var allToDoItemCellModels: [ToDoItemCellModel] = [] {
        didSet {
            if self.categoryType == .custom {
                self.toDoItemCellModels = self.allToDoItemCellModels.filter({ !$0.planItToDo.completed })
            }
            else {
                self.toDoItemCellModels = self.allToDoItemCellModels.filter({ !$0.planItToDo.readDeleteStatus() })
            }
            self.setVisibilityBGImage()
            self.setVisibilityNoToDoImage()
        }
    }
    weak var delegate: ToDoListBaseViewControllerDelegate?
    var completedQueue: [PlanItTodo] = []
    var timerSyncCompleted: Timer?
    var activeFilter: DropDownItem? {
        didSet {
            self.buttonFilter.isSelected = activeFilter != nil
            self.updateListByFilter()
        }
    }
    var toDoMode: ToDoMode = .default {
        didSet {
            self.buttonAddTodo?.isHidden = toDoMode == .edit
            self.toDoItemCellModels.forEach({ $0.editSelected = false })
            self.tableViewToDoItems.isEditing = toDoMode == .edit
            self.tableViewToDoItems.reloadData()
        }
    }
    var toDoItemCellModels: [ToDoItemCellModel] = []
    var currentEditingCellIndex: IndexPath?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var textFieldForToDo: UITextField?
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var textViewNewCategory: UITextView?
    @IBOutlet weak var tableViewToDoItems: UITableView!
    @IBOutlet weak var stackViewTop: UIStackView?
    @IBOutlet weak var imageViewBG: UIImageView!
    @IBOutlet weak var stackViewCompletedEditAction: CompletedEditActionToDoStackView!
    @IBOutlet weak var viewBGImageContainer: UIView?
    @IBOutlet weak var labelDayPart: UILabel!
    @IBOutlet weak var buttonAddTodo: UIButton?
    @IBOutlet weak var buttonHeaderEdit: UIButton?
    @IBOutlet weak var buttonHeaderInvitees: UIButton!
    @IBOutlet weak var buttonHeaderMoreAction: UIButton?
    @IBOutlet weak var constraintHeaderTitleXAxis: NSLayoutConstraint?
    @IBOutlet weak var labelHeaderTitle: UILabel!
    @IBOutlet weak var labelNoItemTitle: UILabel!
    @IBOutlet weak var constraintSearchHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonEditCancel: UIButton?
    @IBOutlet weak var viewEditView: UIView?
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldSearch: NormalSpeechTextField!
    @IBOutlet weak var buttonSelectAll: UIButton!
    @IBOutlet weak var viewSort: UIView?
    @IBOutlet weak var buttonSortType: UIButton!
    @IBOutlet weak var buttonSortArrow: UIButton!
    @IBOutlet weak var labelUndoCompletedCount: UILabel!
    @IBOutlet weak var viewCompletedPopUp: UIView!
    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet weak var viewFilterSection: UIView?
    @IBOutlet weak var constraintCompleteHeight: NSLayoutConstraint!
    @IBOutlet weak var viewItemSelection: UIView?
    @IBOutlet weak var imageViewNoToDoItem: UIView?
    @IBOutlet weak var labelShareCount: UILabel?
    @IBOutlet weak var buttonSearch: UIButton?
    @IBOutlet weak var viewShareLabelCount: UIView?
    @IBOutlet weak var buttonMoreOption: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        if self.isBeingRemoved() && self.isCategoryDataUpdated {
            self.delegate?.todoListBaseViewControllerDidChangeTodoItems(self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addNotifications()
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.removeNotifications()
        super.viewDidDisappear(animated)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewToDoItem(_ sender: UIButton) {
        self.hideCompleteSection()
        self.enableAccesoryView()
    }
    
    @IBAction func toggleSearchBox(_ sender: UIButton) {
        self.hideCompleteSection()
        self.setOnSearchActive(true)
    }
    
    @IBAction func editCancelClicked(_ sender: UIButton) {
        self.setBackToDefaultMode()
    }
    
    @IBAction func closeSearchClicked(_ sender: UIButton) {
        self.updateListByFilter()
        self.setBackToDefaultMode()
    }
    
    
    @IBAction func toggleEditModeSelected(_ sender: UIButton) {
        self.hideCompleteSection()
        self.setOnEditModeActive(true)
    }
    
    @IBAction func selectAllbuttonToggle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.toggleAllCellSelection(by: sender.isSelected)
    }
    
    @IBAction func closeSortClicked(_ sender: UIButton) {
        self.viewSort?.isHidden = true
        self.selectedSortValue = nil
    }
    
    @IBAction func toggleSortOrder(_ sender: UIButton) {
        self.buttonSortArrow.isSelected = !self.buttonSortArrow.isSelected
        self.sortToDoBy(self.selectedSortValue?.dropDownType ?? .eCreatedDate, ascending: self.buttonSortArrow.isSelected)
    }
    
    @IBAction func undoCompletedClicked(_ sender: UIButton) {
        self.undoCompleteToDo()
    }
    
    @IBAction func searchValueChanges(_ sender: UITextField) {
        self.filterListBySearchText(sender.text ?? Strings.empty)
    }
}
