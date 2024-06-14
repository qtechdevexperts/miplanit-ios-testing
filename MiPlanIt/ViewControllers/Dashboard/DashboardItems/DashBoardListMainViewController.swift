//
//  DashBoardListMainViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol DashBoardListMainViewControllerDelegate: class {
    func dashBoardListMainViewController(_ dashBoardListMainViewController: DashBoardListMainViewController, selectedItem: Any)
    func dashBoardListMainViewController(_ dashBoardListMainViewController: DashBoardListMainViewController, toDoToday: Any)
    func dashBoardListMainViewController(_ dashBoardListMainViewController: DashBoardListMainViewController, toDoOverdue: [PlanItTodo])
}

class DashBoardListMainViewController: UIViewController {
    
    var dashboardItems: [DashboardItems] = []
    var selectedItemIndex: Int = 1
    var dashBoardSection: DashBoardSection = .today
    weak var delegate: DashBoardListMainViewControllerDelegate?
    var layoutUpdated: Bool = false
    var isCustomDashboard: Bool = false
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewListContainer: UIView!
    var overDueToDo: [PlanItTodo] = []
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initComponent()
    }
    
    override func viewDidLayoutSubviews() {
        guard !self.layoutUpdated else { return }
        self.layoutUpdated = true
//        self.addBlurEffect()
        self.collectionView.isHidden = true
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.collectionView.scrollToItem(at: IndexPath(item: self.selectedItemIndex + 1, section: 0), at: .centeredHorizontally, animated: false)
            self.collectionView.isHidden = false
        }
        self.updatePageControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.layoutUpdated = true
    }
}
