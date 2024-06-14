//
//  AttachmentDetailViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 22/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class AttachmentDetailViewController: UIViewController {

    @IBOutlet weak var imageViewAttachment: UIImageView!
    @IBOutlet weak var labelFileName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var attachment: UserAttachment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAttachment()
        // Do any additional setup after loading the view.
    }
    
    func showAttachment() {
        self.labelFileName.text = self.attachment?.file
        if let data = self.attachment?.data {
            self.imageViewAttachment.image = UIImage(data: data)
        }
        else if let fileUrl = self.attachment?.url {
            self.activityIndicator.startAnimating()
            self.imageViewAttachment.pinImageFromURL(URL(string: fileUrl), placeholderImage: nil) { (result) in
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {        }
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
