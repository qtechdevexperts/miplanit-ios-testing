//
//  SharedViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class SharedViewController: UIViewController {

    @IBOutlet weak var collectionViewAllUser: UICollectionView!
    var selectedInvitees: [CalendarUser] = []
    var categoryOwnerId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }

    @IBAction func closeUserSelectionButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
