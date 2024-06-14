//
//  ProfileMediaDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension AttachListFileDropDownViewController {
 
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.gallery, type: .eGallery, isNeedImage: true, imageName: FileNames.iconGallery), DropDownItem(name: Strings.camera, type: .eCamera, isNeedImage: true, imageName: FileNames.iconCamera)]
    }
}
