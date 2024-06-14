//
//  UsersListView.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 06/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol UsersListViewDelegate: AnyObject {
    func showUsersListInLargeView(_ view: UsersListView)
    func showUsersCalendar(_ view: UsersListView)
    func showAllCalendars(_ view: UsersListView)
}

class UsersListView: UIView {
    
    private var bubblePictures: BubblePictures!
    var bubbleDirection: BPDirection = .leftToRight
    var bubbleAlignment: BPAlignment = .center
    var distanceInterBubbles: CGFloat? = nil
    var layoutConfigurator = BPLayoutConfigurator()
    var typeOfList: TypeOfBubbleList  = .eDefault
    var colorForBubbleTitles: UIColor = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
    var colorForBubbleBorders: UIColor = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
    var maxNumberOfBubbles: Int = 1
    var showCalendarColor = false
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: UsersListViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialiseBubbluesList()
    }
    
    func initialiseBubbluesList() {
         self.layoutConfigurator = BPLayoutConfigurator(
            backgroundColorForTruncatedBubble: UIColor.white,
            fontForBubbleTitles: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
            colorForBubbleBorders: UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0),
            colorForBubbleTitles: UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0),
            maxNumberOfBubbles: 3,
            direction: self.bubbleDirection,
            alignment: self.bubbleAlignment)
         self.bubblePictures = BubblePictures(collectionView: self.collectionView, configFiles: [], layoutConfigurator: layoutConfigurator, callBack: self)
    }
    
    func reloadUsersListWithUsers(_ users: [Any]) {
        self.layoutConfigurator.direction = self.bubbleDirection
        self.layoutConfigurator.alignment = self.bubbleAlignment
        self.layoutConfigurator.distanceInterBubbles = self.distanceInterBubbles
        let usersList = users.compactMap { (user) -> BPCellConfigFile? in
            if let attendee = user as? PlanItEventAttendees {
                return BPCellConfigFile(imageUrl: Strings.empty, title: Strings.empty, name: attendee.readName(), status: .eDefault, respondStatus: attendee.readSharedStatus == 1 ? .eAccepted : (attendee.readSharedStatus == 2 ? .eRejected : .eNotResponded))
            }
            else if let invitee = user as? PlanItInvitees {
                 return BPCellConfigFile(imageUrl: invitee.readValueOfProfileImage(), title: Strings.empty, name: invitee.readValueOfFullName(), status: .eDefault, respondStatus: invitee.sharedStatus == 1 ? .eAccepted : (invitee.sharedStatus == 2 ? .eRejected : .eNotResponded))
            }
            else if let creator = user as? PlanItCreator {
                 return BPCellConfigFile(imageUrl: creator.readValueOfProfileImage(), title: Strings.empty, name: creator.readValueOfFullName(), status: .eDefault, respondStatus: .eAccepted)
            }
            return nil
        }
        self.bubblePictures = BubblePictures(collectionView: self.collectionView, configFiles: usersList, layoutConfigurator: layoutConfigurator, callBack: self)
        DispatchQueue.main.async {self.bubblePictures.rotated()}
    }
    
    func reloadUsersListWithOtherUsers(_ users: [Any]) {
        self.layoutConfigurator.direction = self.bubbleDirection
        self.layoutConfigurator.alignment = self.bubbleAlignment
        self.layoutConfigurator.distanceInterBubbles = self.distanceInterBubbles
        let usersList = users.compactMap { (user) -> BPCellConfigFile? in
            if let attendee = user as? OtherUserEventAttendees {
                return BPCellConfigFile(  imageUrl: Strings.empty, title: Strings.empty, name: attendee.name, status: .eDefault, respondStatus: attendee.readSharedStatus == 1 ? .eAccepted : (attendee.readSharedStatus == 2 ? .eRejected : .eNotResponded))
            }
            else if let invitee = user as? OtherUserEventInvitees {
                return BPCellConfigFile(  imageUrl: invitee.profileImage, title: Strings.empty, name: invitee.fullName, status: .eDefault, respondStatus: invitee.sharedStatus == 1 ? .eAccepted : (invitee.sharedStatus == 2 ? .eRejected : .eNotResponded))
            }
            return nil
        }
        self.bubblePictures = BubblePictures(collectionView: self.collectionView, configFiles: usersList, layoutConfigurator: layoutConfigurator, callBack: self)
        DispatchQueue.main.async {self.bubblePictures.rotated()}
    }
    
    func reloadCalendarListWith(_ listData: [Any], enableEventColor: Bool = false, containsMiPlanItCalendarWithOtherUser: Bool = false) {
        self.layoutConfigurator.direction = self.bubbleDirection
        self.layoutConfigurator.alignment = self.bubbleAlignment
        self.layoutConfigurator.distanceInterBubbles = self.distanceInterBubbles
        self.layoutConfigurator.maxNumberOfBubbles = self.maxNumberOfBubbles
        self.layoutConfigurator.colorForBubbleTitles = self.colorForBubbleTitles
        self.layoutConfigurator.colorForBubbleBorders = self.colorForBubbleBorders
        self.layoutConfigurator.cellHeight = 40.0
        self.layoutConfigurator.cellWidth = 40.0
        var allUserCalendars = listData
        if containsMiPlanItCalendarWithOtherUser {
            allUserCalendars = listData.filter({ $0 is OtherUser })
            if let ownerUser = listData.filter({ $0 is PlanItCalendar }).first {
                allUserCalendars.append(ownerUser)
            }
        }
        let usersList = allUserCalendars.compactMap { (user) -> BPCellConfigFile? in
            if let otherUser = user as? OtherUser {
                return BPCellConfigFile(imageUrl: otherUser.profileImage, title: Strings.empty, name: otherUser.readDisplayName(), status: otherUser.currentStatus, respondStatus: .eDefault, eventColor: enableEventColor ? otherUser.color : nil)
            }
            else if let calendar = user as? PlanItCalendar {
                return self.getConfigFileFrom(calendar, containsMiPlanItCalendarWithOtherUser: containsMiPlanItCalendarWithOtherUser)
            }
            return nil
        }
        self.bubblePictures = BubblePictures(collectionView: self.collectionView, configFiles: usersList, layoutConfigurator: layoutConfigurator, useCustomBubbleCount: true, callBack: self)
        DispatchQueue.main.async {self.bubblePictures.rotated()}
    }
    
    func reloadUsersListWith(_ listData: [Any], enableEventColor: Bool = false, containsMiPlanItCalendarWithOtherUser: Bool = false) {
        self.layoutConfigurator.direction = self.bubbleDirection
        self.layoutConfigurator.alignment = self.bubbleAlignment
        self.layoutConfigurator.distanceInterBubbles = self.distanceInterBubbles
        self.layoutConfigurator.maxNumberOfBubbles = self.maxNumberOfBubbles
        self.layoutConfigurator.colorForBubbleTitles = self.colorForBubbleTitles
        self.layoutConfigurator.colorForBubbleBorders = self.colorForBubbleBorders
        var allUserCalendars = listData
        if containsMiPlanItCalendarWithOtherUser {
            allUserCalendars = listData.filter({ $0 is OtherUser })
            if let ownerUser = listData.filter({ $0 is PlanItCalendar }).first {
                allUserCalendars.append(ownerUser)
            }
        }
        let usersList = allUserCalendars.compactMap { (user) -> BPCellConfigFile? in
            if let otherUser = user as? OtherUser {
                return BPCellConfigFile(imageUrl: otherUser.profileImage, title: Strings.empty, name: otherUser.readDisplayName(), status: otherUser.currentStatus, respondStatus: .eDefault, eventColor: enableEventColor ? otherUser.color : nil)
            }
            else if let calendar = user as? PlanItCalendar {
                return self.getConfigFileFrom(calendar, containsMiPlanItCalendarWithOtherUser: containsMiPlanItCalendarWithOtherUser)
            }
            return nil
        }
        self.bubblePictures = BubblePictures(collectionView: self.collectionView, configFiles: usersList, layoutConfigurator: layoutConfigurator, callBack: self)
        DispatchQueue.main.async {self.bubblePictures.rotated()}
    }
    
    func getConfigFileFrom(_ calendar: PlanItCalendar, containsMiPlanItCalendarWithOtherUser: Bool) -> BPCellConfigFile {
        let imgName = calendar.readValueOfCalendarImage()
        var imageType: BPImageType? = nil
        if containsMiPlanItCalendarWithOtherUser, let user = Session.shared.readUser() {
            return BPCellConfigFile(imageType, imageUrl: user.readValueOfProfile(), title: Strings.empty, name: user.readValueOfName(), eventColor: Strings.defaultColorCode)
        }
        if imgName.isEmpty && calendar.parentCalendarId == 0, let user = Session.shared.readUser() {
            return BPCellConfigFile(imageType, imageUrl: user.readValueOfProfile(), title: Strings.empty, name: user.readValueOfName(), eventColor: self.showCalendarColor ? calendar.readValueOfColorCode(): nil)
        }
        if imgName.isEmpty {
            if let imageData = calendar.readValueOfCalendarImageData(), let orginalImage = UIImage(data: imageData) {
                imageType = .image(orginalImage)
            }
            else {
                switch calendar.readValueOfCalendarType() {
                case "1":
                    imageType = .image(#imageLiteral(resourceName: "googleIcon"))
                case "2":
                    imageType = .image(#imageLiteral(resourceName: "outlookIcon"))
                case "3":
                    imageType = .image(#imageLiteral(resourceName: "appleIcon"))
                default:
                    break
                }
            }
        }
        if imageType == nil && imgName.isEmpty {
            imageType = .color(self.setColorCalendar(calendar.readValueOfColorCode()))
        }
        return BPCellConfigFile(imageType, imageUrl: imgName, title: Strings.empty, name: calendar.readValueOfCalendarName(), eventColor: self.showCalendarColor ? calendar.readValueOfColorCode(): nil)
    }
    
    func setColorCalendar(_ colorCode: String?) -> UIColor {
        if let color = colorCode, !color.isEmpty {
            let colorRGB = color.components(separatedBy: " ")
            if colorRGB.count == 3 {
                let red = Double(colorRGB[0])
                let green = Double(colorRGB[1])
                let blue = Double(colorRGB[2])
                return UIColor.init(red: CGFloat(red!) / 255.0, green: CGFloat(green!) / 255.0, blue: CGFloat(blue!) / 255.0, alpha: 1)
            }
        }
        return UIColor.init(red: 239/255.0, green: 247/255.0, blue: 255/255.0, alpha: 1)
    }
}

extension UsersListView: BPDelegate {
    
    func didSelectTruncatedBubble() {
        if self.typeOfList == .eCalendar {
            self.delegate?.showAllCalendars(self)
        }
        else {
            self.delegate?.showUsersListInLargeView(self)
        }
    }
    
    func didSelectBubble(at index: Int) {
        if self.typeOfList == .eCalendar {
            self.delegate?.showAllCalendars(self)
        }
        else {
            self.delegate?.showUsersCalendar(self)
        }
    }
}
