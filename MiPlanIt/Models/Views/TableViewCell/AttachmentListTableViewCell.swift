//
//  PurchaseListTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AttachmentListTableViewCellDelegate: class {
    func attachmentListTableViewCell(_ cell: AttachmentListTableViewCell, removeAtIndexPath indexPath: IndexPath)
}

class AttachmentListTableViewCell: UITableViewCell {
    
    var indexpath: IndexPath!
    weak var delegate: AttachmentListTableViewCellDelegate?
    
    @IBOutlet weak var labelFileName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var imageViewAttachment: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureAttachment(_ attachment: UserAttachment, activityType: AttachmentType, atIndexPath index: IndexPath, callback: AttachmentListTableViewCellDelegate) {
        self.indexpath = index
        self.delegate = callback
        self.buttonDelete.isHidden = activityType == .none
        self.labelDate.text = attachment.createdDate.stringFromDate(format: DateFormatters.EEEMMMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
        self.labelFileName.text = attachment.file
        if attachment.data != nil {
            self.imageViewAttachment.image = UIImage(data: attachment.data)
        }
        else if !attachment.url.isEmpty  {
            self.imageViewAttachment.pinImageFromURL(URL(string: attachment.url), placeholderImage: nil)
        }
    }
    
    @IBAction func deleteAttachments(_ sender: Any) {
        self.delegate?.attachmentListTableViewCell(self, removeAtIndexPath: self.indexpath)
    }
}
