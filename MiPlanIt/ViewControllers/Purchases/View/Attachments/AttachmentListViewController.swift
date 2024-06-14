//
//  AttachmentListViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 02/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AttachmentListViewControllerDelegate: class {
    func attachmentListViewController(_ viewController: AttachmentListViewController, updated items: [UserAttachment])
}

class AttachmentListViewController: UIViewController {
    
    var activityType = AttachmentType.none
    var attachments: [UserAttachment] = []
    weak var delegate: AttachmentListViewControllerDelegate?
    var itemOwnerId: String?
    
    @IBOutlet weak var viewNoItem: UIView!
    @IBOutlet weak var buttonAttachment: UIButton!
    @IBOutlet weak var tableViewAttachments: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.attachmentListViewController(self, updated: self.attachments)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case is AttachListFileDropDownViewController:
            let attachDropDownViewController = segue.destination as? AttachListFileDropDownViewController
            attachDropDownViewController?.delegate = self
        case is AttachmentDetailViewController:
            let attachmentDetailViewController = segue.destination as? AttachmentDetailViewController
            attachmentDetailViewController?.attachment = sender as? UserAttachment
        default:
            break
        }
    }
}
