//
//  TestVC.swift
//  MiPlanIt
//
//  Created by Maaz Tauseef on 30/05/2023.
//  Copyright © 2023 Arun. All rights reserved.
//

import UIKit

class TestVC: UIViewController {

    @IBOutlet weak var ll: UILabel!
//    @IBOutlet weak var label: UILabel!
    //    @IBOutlet weak var lblTest: UILabel!
    var value = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(value)
        showAlert(message: value)
        var v = UserDefaults.standard.string(forKey: "test")
        UserDefaults.standard.set(value, forKey: "test")

//        ll.text = "value"
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    public func showAlertMessage(title : String, msg:String,btnTitle : String,vc : UIViewController)  {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { action in
            
        alert.dismiss(animated: true, completion: nil)
        }))
        vc.present(alert, animated: true, completion: nil)
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
