//
//  AttachmentDetailViewController+Action.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 27/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension AttachmentDetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageViewAttachment
    }
    
}
