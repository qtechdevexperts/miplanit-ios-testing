//
//  ProfileMediaDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension AttachFileDropDownViewController {
 
    func readDropDownOptions() -> [DropDownItem] {
        if self.countofAttachments > 0 {
            return [DropDownItem(name: Strings.viewAttachment, type: .eViewAttachment, isNeedImage: true, imageName: FileNames.imageTodoViewImagesDropDown), DropDownItem(name: Strings.gallery, type: .eGallery, isNeedImage: true, imageName: FileNames.imageTodoGalleryDropDown), DropDownItem(name: Strings.camera, type: .eCamera, isNeedImage: true, imageName: FileNames.imageTodoCameraDropDown)]
        }
        else {
            return [DropDownItem(name: Strings.gallery, type: .eGallery, isNeedImage: true, imageName: FileNames.imageTodoGalleryDropDown), DropDownItem(name: Strings.camera, type: .eCamera, isNeedImage: true, imageName: FileNames.imageTodoCameraDropDown)]
        }
        
    }
}
