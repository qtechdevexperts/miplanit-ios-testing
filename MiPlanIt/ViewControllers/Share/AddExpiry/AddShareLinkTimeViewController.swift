//
//  AddShareLinkTimeViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol AddShareLinkTimeViewControllerDelgate: AnyObject {
    func addShareLinkTimeViewController(_ addShareLinkTimeViewController: AddShareLinkTimeViewController, updatedTime: Double)
}

class AddShareLinkTimeViewController: UIViewController {
    
    weak var delegate: AddShareLinkTimeViewControllerDelgate?

    @IBOutlet weak var textFieldExpiryTime: PaddingTextField!
    @IBOutlet weak var buttonAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    @IBAction func closeCategoryClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        guard SocialManager.default.isNetworkReachable() else { return }
        self.createServiceAddShareLinkTime()
    }
    
    @IBAction func onCategoryTextChanges(_ sender: UITextField) {
//        self.buttonAdd.backgroundColor = (sender.text ?? Strings.empty).isEmpty ? UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0) : UIColor(red: 96/255, green: 201/255, blue: 220/255, alpha: 1.0)
    }

}
