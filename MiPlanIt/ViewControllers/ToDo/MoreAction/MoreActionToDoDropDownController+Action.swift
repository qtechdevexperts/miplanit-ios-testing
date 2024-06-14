//
//  MoreActionDropDownController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MoreActionToDoDropDownController {
    
    func readSortDropDownOptions() -> [DropDownItem]  {
        return [DropDownItem(name: Strings.alphabetically, type: .eAlphabetically, isNeedImage: true, imageName: Strings.imageSortAlphabeticaly), DropDownItem(name: Strings.favourite, type: .eFavourite, isNeedImage: true, imageName: FileNames.imageTodoFavouriteDropDown), DropDownItem(name: Strings.dueDate, type: .eDueDate, isNeedImage: true, imageName: Strings.imageIconDueDate), DropDownItem(name: Strings.createdDate, type: .eCreatedDate, isNeedImage: true, imageName: Strings.imageSortCreatedDate)]
    }
    
    func readListDropDownOptions() -> [DropDownItem]  {
        return [DropDownItem(name: Strings.sortOption, type: .eSortOption, isNeedImage: true, imageName: Strings.imageSortOption), DropDownItem(name: Strings.share, type: .eShare, isNeedImage: true, imageName: Strings.imageShareIconBlue), DropDownItem(name: Strings.print, type: .ePrint, isNeedImage: true, imageName: Strings.imagePrint), DropDownItem(name: Strings.delete, type: .eDelete, isNeedImage: true, imageName: Strings.imageDelete)]
//        if self.containsToDoItems {
//            return [DropDownItem(name: Strings.sortOption, type: .eSortOption, isNeedImage: true, imageName: Strings.imageSortOption), DropDownItem(name: Strings.share, type: .eShare, isNeedImage: true, imageName: Strings.imageShareIconBlue), DropDownItem(name: Strings.print, type: .ePrint, isNeedImage: true, imageName: Strings.imagePrint), DropDownItem(name: Strings.delete, type: .eDelete, isNeedImage: true, imageName: Strings.imageDelete)]
//        }
//        else {
//            return [DropDownItem(name: Strings.share, type: .eShare, isNeedImage: true, imageName: Strings.imageShareIconBlue), DropDownItem(name: Strings.print, type: .ePrint, isNeedImage: true, imageName: Strings.imagePrint), DropDownItem(name: Strings.delete, type: .eDelete, isNeedImage: true, imageName: Strings.imageDelete)]
//        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.sendSelectedOption(self.dropDownItems[indexPath.row])
    }
}

