//
//  AddActivityTagViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class AddActivityTagViewController: UIViewController {
    var canAddTag = true
    var tags: [String] = []
    var tagActivityType: SourceScreen = .event
    var textToPredict: String = Strings.empty
    var predictionId: String?
    var defaultTags: [PredictionTag] = []
    
    var titles: [String] = [] {
        didSet {
            self.collectionView.reloadData()
            self.tableViewTags.reloadData()
            self.updateTagCollectionViewHeight()
        }
    }
    
    var predictionTitles: [PredictionTag] = [] {
         didSet {
            self.lottieAnimationView.isHidden = true
            self.predictionCollectionView.reloadData()
            self.updatePredictedTagCollectionViewHeight()
            self.viewPredictionTags.isHidden = predictionTitles.isEmpty
            self.checkForHiddingAllAddedTag()
        }
    }
    
    lazy var localTags: [PlanItSuggustionTags] = {
        return DatabasePlanItSuggustionTags().readAllTags(of: self.tagActivityType)
    }()
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @IBOutlet weak var predictionCollectionLayout: UICollectionViewFlowLayout! {
        didSet {
            predictionCollectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @IBOutlet weak var tableViewTags: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var predictionCollectionView: UICollectionView!
    @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintPredictionCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonDone: UIButton?
    @IBOutlet weak var buttonAddAll: UIButton!
    @IBOutlet weak var viewPredictionTags: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var labelNoTagsFound: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.titles = tags
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.canAddTag {
            self.showPredictedTags()
        }
        super.viewDidAppear(animated)
    }
    
    @IBAction func addAllPredictedTag(_ sender: Any) {
        var addTitles: [String] = []
        self.predictionTitles.forEach { (titles) in
            if !self.titles.contains(titles.text) {
                addTitles.append(titles.text)
            }
        }
        self.titles.append(contentsOf: addTitles)
        self.reloadPredictedCollection()
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        self.sendPredictionFeedback()
    }
}
