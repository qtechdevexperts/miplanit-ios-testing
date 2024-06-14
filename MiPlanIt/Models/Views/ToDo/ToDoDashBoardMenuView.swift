//
//  ToDoDashBoardMenuView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

protocol ToDoDashBoardMenuViewDelegate: class {
    func toDoDashBoardMenuView(_ toDoDashBoardMenuView: ToDoDashBoardMenuView, onSelected todos: [PlanItTodo], category: ToDoMainCategory)
}

class ToDoDashBoardMenuView: UIView {

    var todos: [PlanItTodo] = [] {
        didSet {
            self.hideLoader()
            self.manageTodos()
        }
    }
    weak var delegate: ToDoDashBoardMenuViewDelegate?
    
    @IBOutlet weak var labelAllListCount: UILabel!
    @IBOutlet weak var labelAllListNotificationCount: UILabel?
    @IBOutlet weak var imageViewCategory: UIImageView!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var viewNotificationCount: UIView?
    @IBOutlet weak var viewOverdueCount: UIView?
    @IBOutlet weak var labelOverdueCount: UILabel?
    
    lazy var mainCategory: ToDoMainCategory = {
        return ToDoMainCategory(rawValue: self.tag) ?? .custom
    }()
    
    @IBAction func menuSelected(_ sender: UIButton) {
        self.delegate?.toDoDashBoardMenuView(self, onSelected: self.todos, category: self.mainCategory)
    }
    
    func showLoader() {
        guard !self.viewCategory.isHidden else { return }
        self.viewCategory.isHidden = true
        self.lottieAnimationView.isHidden = false
        self.lottieAnimationView.loopMode = .loop
        self.lottieAnimationView.play()
    }
    
    func hideLoader() {
        self.viewCategory.isHidden = false
        self.lottieAnimationView.isHidden = true
        if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
    }
    
    func manageTodos() {
        self.updateCountOfCategoryList()
        if self.mainCategory == .assignedToMe {
            self.updateUnReadCountOfAssignedToMe()
        }
        else if self.mainCategory == .overdue {
            self.updateUnReadCountOfOverdue()
        }
        else if self.mainCategory == .completed {
            self.updateUnReadCountOfCompleted()
        }
    }
    
    func updateCountOfCategoryList() {
        if self.mainCategory == .all {
            let filterdTodos = self.todos.filter({ return !$0.readDeleteStatus() })
            self.labelAllListCount.text = "\(filterdTodos.count) \(filterdTodos.count == 1 ? "item" : "items")"
        }
        else {
            self.labelAllListCount.text = "\(self.todos.count) \(self.todos.count == 1 ? "item" : "items")"
        }
    }
    
    func updateUnReadCountOfAssignedToMe() {
        let unreadTodos = self.todos.flatMap({ return $0.readAllInvitees() }).filter({ return $0.readValueOfUserId() == Session.shared.readUserId() && !$0.isRead })
        self.labelAllListNotificationCount?.text = "\(unreadTodos.count)"
        self.viewNotificationCount?.isHidden = unreadTodos.isEmpty
    }
    
    func updateUnReadCountOfOverdue() {
//        let unreadTodos = self.todos.filter({ !$0.overdueViewStatus })
        let unreadTodos = self.todos
        self.labelOverdueCount?.text = "\(unreadTodos.count)"
        self.viewOverdueCount?.isHidden = unreadTodos.isEmpty
    }
    
    func updateUnReadCountOfCompleted() {
        let unreadTodos = self.todos.filter({ $0.isAssignedByMe && !$0.completedViewStatus && !$0.isAssignedToMe })
        self.labelAllListNotificationCount?.text = "\(unreadTodos.count)"
        self.viewNotificationCount?.isHidden = unreadTodos.isEmpty
    }
}
