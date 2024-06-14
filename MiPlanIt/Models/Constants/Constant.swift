//
//  Constant.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

var isCalendar = false
var token = "ya29.a0AVvZVsr3LYmSWbyGA31q5YNV491yVKGkDJ1WhxIJtoReFUePyJYGH9OZOQiHqX_WWKSq8ZyHSe1uvLfplyQXjIPY5afCwjSE4oePpuh-55TYJK-KYoWUdDVj04pIzwWr4iQ-Bn1bvfOq_3U8k3plPIlHbicLaCgYKAUESARMSFQGbdwaIUg9K8lTIy_PlCy0CVPCS4A0163"
var email = "test@thesuitch.com"
var userId = "105343238157272265542"
var testing = true
var userM:SocialUser!
var isMenu:Bool = false
//userM.email = email
//userM.token = token
//userM.userId = userId

struct ConfigureKeys {
    static let awsErrorKey = 112233
//    "630632526986-h73l431qikhh25ae3lsgshkhkuckquq4.apps.googleusercontent.com"
    static let googleClientKey = "402792541132-mfgvak2bc69dsa4194dgj2p4u47ela1i.apps.googleusercontent.com"
//    static let FBClientKey = "1024113188078319"
    static let FBClientKey = "625945439383759"
    static let twitterConsumerKey = "9eNmHTsjNP8dRJODlepvQH9ed"
    static let twitterSecretKey = "sCqRNCkafBjn7m5CYqcIwrSJh9G3n0VZUa6ioBvbz1mfhtU7KU"
    //static let outlookClientKey = "1989c650-311b-4f72-be10-3be8e0cb080f"
//    static let outlookClientKey = "f53fb873-1cb4-4a1d-92ae-620f34039e89"
    static let outlookClientId = "0f1e3ee3-e19c-4cd6-a0df-fba8e48e4cd5"
    static let outlookSecretKey = "fV1n45cuFJqq-K~Kia3x0_.EIHMJie6W92"
    
    static let subscriptionProductId = "com.miplanitcorp.miplanit.subscription_yearly"//"com.miplanitcorp.miplanit.subscriptionmonthly"
    static let subscriptionProductIdMonthly = "com.miplanitcorp.miplanit.subscriptionmonthly"//"com.miplanitcorp.miplanit.subscriptionmonthly"
    static let productIdentifiers: Set<String> = [subscriptionProductId]
    static let productIdentifiersMonthly: Set<String> = [subscriptionProductIdMonthly]
    static let appSpecificSharedSecret: String = "566c3fe004fd4468be0be0d3c0c9f1ec"
    static let aesKey: String = "566c3fe004fd4468"
    static let purchaseFeatureEnabled: Bool = true
    static let adBannerUnitID = "ca-app-pub-1586031792606831/5715260482"
    static let adIntersticialUnitID = "ca-app-pub-1586031792606831/4019035438"//"ca-app-pub-1586031792606831/7006213666"
    static let adIntersticialTimeIntervalInSeconds: Int = 100
}


struct Segues {
    static let toCreateDashboard = "toCreateDashboard"
    static let toVerifyOTP = "toVerifyOTP"
    static let toImportScreen = "toImportScreen"
    static let toCalanderList = "toCalanderList"
    static let toSingleDayView = "toSingleDayView"
    static let toUpdateProfile = "toUpdateProfile"
    static let toProfileDropDown = "toProfileDropDown"
    static let toFilterDropDown = "toFilterDropDown"
    static let toPurchaseFilterDropDown = "toPurchaseFilterDropDown"
    static let toUpdatePassword = "toUpdatePassword"
    static let toMessageScreen = "toMessageScreen"
    static let toUsersCalendar = "toUsersCalendar"
    static let toShowAllCalendars = "toShowAllCalendars"
    static let toCalendarTypeDropDown = "toCalendarTypeDropDown"
    static let toAddOptionsScreen = "toAddOptionsScreen"
    static let toTabViewScreen = "toTabViewScreen"
    static let toAddCalendar = "toAddCalendar"
    static let toAddGiftCoupon = "toAddGiftCoupon"
    static let toAddShoppingList = "toAddShoppingList"
    static let toShoppingTag = "toShoppingTag"
    static let toShoppingShare = "toShoppingShare"
    static let toAddPurchase = "toAddPurchase"
    static let toPurchaseDetails = "PurchaseDetails"
    static let toGiftCouponDetails = "GiftCouponDetails"
    static let toShoppingDetails = "toShoppingDetails"
    static let toAttachments = "toAttachments"
    static let toAddNewEventScreen = "toAddNewEventScreen"
    static let toAddNewShareLink = "toAddNewShareLink"
    static let toInviteesList = "toInviteesList"
    static let toSharedUsers = "tosharedUsers"
    static let toAddNewTaskScreen = "toAddNewTaskScreen"
    static let toTaskDetail = "toTaskDetail"
    static let toAttachmentDetail = "toAttachmentDetail"
    static let toShowEvent = "toShowEvent"
    static let toViewCalendar = "toViewCalendar"
    static let toShareCalendar = "toShareCalendar"
    static let toHelpScreen = "toHelpScreen"
    static let toCreateShoppingListScreen = "toCreateShoppingListScreen"
    static let goToMap = "goToMap"
    static let goToCustomDashboard = "goToCustomDashboard"
    static let createDashboard = "createDashboard"
    static let toWebView = "toWebView"
    static let toEditCalendar = "toEditCalendar"
    static let toEditEvent = "toEditEvent"
    static let toCategoryToDoListView = "toCategoryToDoListView"
    static let toToDoFilter = "toToDoFilter"
    static let segueToDoDetail = "segueToDoDetail"
    static let toAddItemsDropDown = "toAddItemsDropDown"
    static let toCategoryList = "toCategoryList"
    static let segueToMoveList = "segueToMoveList"
    static let toMainCategoryToDoListView = "toMainCategoryToDoListView"
    static let toCustomCategoryToDoListView = "toCustomCategoryToDoListView"
    static let toAssignScreen = "toAssignUser"
    static let toToDoDueDate = "toToDoDueDate"
    static let pushToTagVC = "pushToTagVC"
    static let presetToTagVC = "presetToTagVC"
    static let presentWebView = "presentWebView"
    static let segueToCalendarSelection = "segueToCalendarSelection"
    static let toListDetail = "toListDetail"
    static let showShopItemDetail = "showShopItemDetail"
    static let showSearchShopItemVC = "showSearchShopItemVC"
    static let showToDoRepeat = "showToDoRepeat"
    static let showCategoryList = "showCategoryList"
    static let showShopListSelection = "showShopListSelection"
    static let toShopListDetail = "toShopListDetail"
    static let shoppingListItemDetail = "shoppingListItemDetail"
    static let showSearchFilter = "showSearchFilter"
    static let showCompletedItemDetail = "showCompletedItemDetail"
    static let showOutlookWebViewController = "showOutlookWebViewController"
    static let segueToPricing = "segueToPricing"
    static let showAttachmentPopUp = "showAttachmentPopUp"
    static let showPopUpDashboardDetail = "showPopUpDashboardDetail"
    static let segueToMoreList = "segueToMoreList"
    static let showInviteeStatus = "showInviteeStatus"
    static let segueAddShopCategory = "segueAddShopCategory"
    static let toInviteeUserLink = "toInviteeUserLink"
    static let showShareLink = "showShareLink"
    static let segueUpdateLinkExipry = "segueUpdateLinkExipry"
    static let segueToReorderCategory = "segueToReorderCategory"
    static let showInterstitialAds = "showInterstitialAds"
}

struct ServiceData {
//    static let baseUrl = "https://a2r5il9qgl.execute-api.us-east-1.amazonaws.com/dev"
//    static let baseUrl = "https://a2r5il9qgl.execute-api.us-east-1.amazonaws.com/stg"
    static let baseUrl = "https://3cn4g3qms4.execute-api.us-east-1.amazonaws.com/prd"

    static let prediction = "https://2cz910a3ld.execute-api.us-east-1.amazonaws.com/prod"
    static let google = "https://www.googleapis.com/calendar/v3/"
    static let googleToken = "https://oauth2.googleapis.com/token"
    static let googleScope = ["https://www.googleapis.com/auth/calendar.readonly","https://www.googleapis.com/auth/calendar.events.owned"]
    static let outlookWebAuthorize = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
    static let outlookGetTokens = "https://login.microsoftonline.com/common/oauth2/v2.0/token"
    static let outlookGetUserInfo = "https://graph.microsoft.com/v1.0/me"
   // static let outlookAuthority = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
    static let outlookAuthority = "https://login.microsoftonline.com/organizations"
   // static let outlookReDirectURI = "msauth.com.microsoft.O365-iOS-Microsoft-Graph-Connect-Swift-REST://auth"
    static let outlookReDirectURI = "msauth.com.feathersoft.miplanitapp://auth"
    static let outlookScopes = ["User.Read Calendars.Read Calendars.ReadWrite"]
    static let outlookOfflineScopes = ["offline_access User.Read Calendars.Read Calendars.ReadWrite"]
    static let registration = "/users/registration"
    static let login = "/users/login"
    static let updateProfile = "/users/update-profile"
    static let uploadProfilePic = "/users/image-upload"
    static let uploadDashboardPic = "/dashboard/upload-image"
    static let importCalendar = "/calendar/import"
    static let calendarLog = "/log"
    static let socialCalendarUsers = "/calendar/user-social-calendars"
    static let syncSocialUser = "/users/refresh-social-token"
    static let calendarEvents = "/calendar/multiple-user-calendar"
    static let userShopListItems = "/shopping-list/user-data"
    static let customDashboardFetch = "/dashboard/user-data"
    static let calendarFetch = "/calendar/user-data"
    static let shareLinkFetch = "/booking-link/user-data"
    static let todoFetch = "/to-do-list/user-data"
    static let giftFetch = "/gift-coupon/user-data"
    static let purchaseFetch = "/purchase/user-data"
    static let userExist = "/users/exist"
    static let addCalendar = "/calendar/add"
    static let uploadCalendarImage = "/calendar/image-upload"
    static let uploadShopListImage = "/shopping-list/image-upload"
    static let notification = "/users/notifications"
    static let createEvent = "/event/add"
    static let notificationAction = "/users/notifications/action"
    static let notificationDelete = "/users/notifications/delete"
    static let remoteNotification = "/users/device-auth"
    static let notificationPayload = "/users/notifications/activity-data"
    static let eventDelete = "/event/delete"
    static let eventCancel = "/event/cancel"
    static let calendarDelete = "/calendar/delete"
    static let attachmentAdd = "/attachment/add"
    static let purchaseAdd = "/purchase/add"
    static let dashboardAdd = "/dashboard/add"
    static let purchaseDelete = "/purchase/delete"
    static let dashboardDelete = "/dashboard/delete"
    static let masterItems = "/master-items/list"
    static let userItems = "/user-items/list"
    static let addShopList = "/shopping-list/add"
    static let addShopCategory = "/category/add"
    static let deleteShopCategory = "/category/delete"
    static let upsertShopListItem = "/shopping-list-items/upsert"
    static let moveShopListItems = "/shopping-list-items/move"
    static let updateCategory = "/user-items/update-category"
    static let giftCouponAdd = "/gift-coupon/add"
    static let giftCouponDelete = "/gift-coupon/delete"
    static let giftCouponRedeem = "/gift-coupon/mark-as-redeem"
    static let shoppingListItemCompleteUpdate = "/shopping-list-items/mark-as-complete"
    static let shoppingListItemFavoriteUpdate = "/shopping-list-items/mark-as-favorite"
    static let deleteShoppingListData = "/shopping-list/delete"
    static let deleteShoppingListItemData = "/shopping-list-items/delete"
    static let tagPrediction = "/tag-prediction"
    static let tagFeedback = "/tag-feedback"
    static let syncCalendar = "/auto-sync"
    static let todoCategory = "/to-do-list/upsert"
    static let todos = "/to-do/upsert"
    static let todoMarkASRead = "/to-do/mark-as-read"
    static let todoMove = "/to-do-list/move"
    static let todoReOrder = "/to-do/order"
    static let calendarDefaultShare = "/calendar/default-share"
    static let calendarDefaultShareUsers = "/calendar/default-share-users"
    static let deletedOutlookInstances = "/delete-outlook-instances"
    static let deleteSharedCalendarInvitee = "/calendar/invitee"
    
    static let itunesService: String = {
       // #if DEBUG
//        return "https://sandbox.itunes.apple.com/verifyReceipt"
//        #else
        return "https://buy.itunes.apple.com/verifyReceipt"
//        #endif
    }()
    static let itunesSandboxService = "https://sandbox.itunes.apple.com/verifyReceipt"
    static let verifyPurchase = "/users/verify-purchase"
    static let subscriptionStatus = "/users/subscription-status"
    static let userDataSize = "/users/data-size"
    static let registeredContacts = "/users/registered-contacts"
    static let appVersion = "/app-version"
    static let appstoreURL = "https://apps.apple.com/us/app/miplanit/id1551807583"
    static let updateDueDate = "/shopping-list-items/update-due-date"
    static let activityData = "/activity-data"
    static let createShareLink = "/booking-link/add"
    static let deleteShareLink = "/booking-link/delete"
    static let linkUserExpiry = "/booking-link/user-expiry"
    static let addlinkUserExpiry = "/users/add-expiry"
}

struct Strings {
    static let receiptExpired = "Receipt expired"
    static let empty = ""
    static let mylist = "My Lists"
    static let sharedList = "Shared Lists"
    static let sharedListWithMe = "Lists Shared With Me"
    static let unavailable = "Unavailable"
    static let notspecified = "Not Specified"
    static let space  = " "
    static let hyphen  = " - "
    static let comma = ","
    static let email = "Email"
    static let phone = "Phone"
    static let expired = "Expired"
    static let updated = "Updated"
    static let new = "New"
    static let deleted = "Deleted"
    static let chooseImage = "Choose Image"
    static let selectOption = "Choose Option"
    static let addItems = "Add Items"
    static let chooseRepeatType = "Repeat"
    static let chooseRemindType = "Remind Me"
    static let choosePriorityType = "Choose Priority Type"
    static let chooseCalendarType = "Choose Calendar Type"
    static let filter = "Filter by"
    static let camera = "Camera"
    static let gallery = "Gallery"
    static let giftcards = "Gift Cards"
    static let giftcoupons = "Coupons"
    static let switchDashboardType = "Switch to Custom Dashboard"
    static let createDashboard = "New Custom Dashboard"
    static let viewAttachment = "View Attachments"
    static let recentItems = "Recent Items"
    static let favorites = "Favorites"
    static let categories = "Categories"
    static let shoppingLists = "Shopping Lists"
    static let MyCalendars = "Mi Calendars"
    static let UserCalendars = "User Calendars"
    static let login = "Login"
    static let verifyUser = "Verify User"
    static let upload = "Upload"
    static let submit = "Submit"
    static let addGiftCoupon = "Add Coupons & Gifts"
    static let editGiftCoupon = "Edit Coupons & Gifts"
    static let addPurchase = "Add Purchase"
    static let editPurchase = "Edit Purchase"
    static let all = "All"
    static let event = "Event"
    static let calendar = "Calendar"
    static let shopping = "Shopping"
    static let card = "Card"
    static let cash =  "Cash"
    static let travelling =  "Traveling"
    static let busy =  "Busy"
    static let task = "To Do"
    static let usersCalendar = "Users Calendar"
    static let editCalnder = "Edit Calendar"
    static let viewCalendar = "View Calendar"
    static let fullAccess = "FULL ACCESS"
    static let particalAccess = "PARTIAL ACCESS"
    static let addUserPlaceHolder = "Add Users "
    static let userCalendar = "Users Calendar"
    static let addinvitees = "Add Invitees"
    static let notifyUser = "Notify User"
    static let addUsers = "Search (Name/Email/Phone)"
    static let addedinvitees = "INVITEES ADDED"
    static let userSelected = "USERS SELECTED"
    static let selectUser = "Search (Name/Email/Phone)"
    static let never = "Never"
    static let Sunday = "Sunday"
    static let Monday = "Monday"
    static let Tuesday = "Tuesday"
    static let Wednesday = "Wednesday"
    static let Thursday = "Thursday"
    static let Friday = "Friday"
    static let Saturday = "Saturday"
    static let everyDay = "Every Day"
    static let everyWeek = "Every Week"
    static let every2Weeks = "Every 2 Weeks"
    static let everyMonth = "Every Month"
    static let everyYear = "Every Year"
    static let fiveteenMinBefore = "15 mins Before"
    static let thirtyMinBefore = "30 mins Before"
    static let oneHourBefore = "1 hr Before"
    static let oneDayBefore = "1 Day Before"
    static let oneMonthBefore = "1 Month Before"
    static let calendarTitle = "MiPlaniT"
    static let addNewCalendar = "Add New Calendar"
    static let editCalendar = "Edit Calendar"
    static let createNewEvent = "Create New Event"
    static let editEvent = "Edit Event"
    static let editTask = "Edit Task"
    static let addTask = "Add New Task"
    static let low = "Low"
    static let medium = "Medium"
    static let high = "High"
    static let priorityLowImage = "priority-low"
    static let priorityHighImage = "priority-high"
    static let priorityMediumImage = "priority-medium"
    static let priorityLowLabel = "Low Priority"
    static let priorityHighLabel = "High Priority"
    static let priorityMediumLabel = "Medium Priority"
    static let locationSeperator: Character = "$"
    static let placeHolderSubString = ""
    static let color1 = "color1"
    static let color2 = "color2"
    static let color3 = "color3"
    static let color4 = "color4"
    static let color5 = "color5"
    static let color6 = "color6"
    static let color7 = "color7"
    static let color8 = "color8"
    static let color9 = "color9"
    static let defaultColor = "color10"
    static let color1Selected = "color1-selected"
    static let color2Selected = "color2-selected"
    static let color3Selected = "color3-selected"
    static let color4Selected = "color4-selected"
    static let color5Selected = "color5-selected"
    static let color6Selected = "color6-selected"
    static let color7Selected = "color7-selected"
    static let color8Selected = "color8-selected"
    static let color9Selected = "color9-selected"
    static let defaultColorSelected = "color10-selected"
    static let color1Code = "134 114 221"
    static let color2Code = "252 188 131"
    static let color3Code = "213 216 141"
    static let color4Code = "176 216 219"
    static let color5Code = "225 139 144"
    static let color6Code = "192 152 209"
    static let color7Code = "139 227 176"
    static let color8Code = "245 148 196"
    static let color9Code = "247 222 122"
    static let defaultColorCode = "143 198 235"
    static let null = "NULL"
    static let listening = "Listening..."
    static let oneWeek = "1 Week"
    static let oneDay = "1 Day"
    static let oneMonth = "1 Month"
    static let oneYear = "1 Year"
    static let alphabetically = "Alphabetically"
    static let favourite = "Favorite"
    static let dueDate = "Due Date"
    static let createdDate = "Created Date"
    static let imageSortAlphabeticaly = "sort-alphabeticaly"
    static let imageIconDueDate = "todo-dueDate-bottom"
    static let imageSortCreatedDate = "icon-sort-created-date"
    static let sortOption = "Sort by"
    static let imageSortOption = "icon-sort"
    static let share = "Share"
    static let imageShareIconBlue = "icon-share-blue"
    static let print = "Print"
    static let imagePrint = "icon-print"
    static let imageDelete = "todo-delete-bottom"
    static let delete = "Delete"
    static let sortBy = "Sort By"
    static let listOption = "List Option"
    static let moveTo = "Move To"
    static let unplanned = "Unplanned"
    static let overDue = "Overdue"
    static let assignedToMe = "Assigned to me"
    static let completed = "Completed"
    static let date = "Date"
    static let assignedByMe = "Assigned by me"
    static let minUnit = "min"
    static let hourUnit = "hour"
    static let dayUnit = "day"
    static let weekUnit = "week"
    static let monthUnit = "month"
    static let yearUnit = "year"
    static let deleteStatusCode = "ER005"
    static let ac = "Account: "
    static let defaultKey = "default"
    static let suggustedUsers = "Contacts"//Suggested MiPlaniT Contacts"
    static let otherUsers = "Phone Contacts"
    static let other = "Other"
    static let weekly = "Weekly"
    static let everyWeekOn = "every Week on"
    static let years = "Years"
    static let days = "Days"
    static let expiresToday = "Expires Today"
    static let expiresTomorrow = "Expires Tomorrow"
    static let namealreadyexists = "Name already exists..!"
    static let billDate = "Date: "
    static let dashboardDueDate = "Due Date: "
    static let details = "details"
    static let favoriteItems = "Favorite Items"
    static let categorys = "Categories"
    static let shopOtherCategoryName = "Others"
//    static let defaultShopItemImage = "default-shop-item-image" // Cart
    static let defaultShopItemImage = "Cartwhite"
    static let defaultshoppingcategoryicon = "defaultshoppingcategoryicon"
    static let defaultCalendaricon = "defaultCalendarIcon"
    static let dashboardDefaultIcon = "dashboardDefaultIconNew"
    static let shoppingDefaultIcon = "dashboardDefaultIcon"
    static let miPlaniT = "MiPlaniT"
    static let masterSearchPlaceHolder = "Type your text here..."
    static let receipts = "Receipts"
    static let bills = "Bills"
    static let receiptDateLabel = "Receipt Date"
    static let billDateLabel = "Bill Date"
    static let receiptDateLabelInView = "RECEIPT DATE"
    static let billDateLabelInView = "BILL DATE"
    static let importingLabel = "Importing events"
    static let fetchingLabel = "Fetching from Server"
    static let redirectUrl = "http://localhost/MiPlanIT"
    static let subActivityTitlesSeperator = ","
    static let appName: String = {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Strings.empty
    }()
    static let privacyPolicyLink = "https://www.miplanit.com/privacy-policy/"
    static let termsLink = "https://www.miplanit.com/terms-and-conditions/"
    static let receiptExipred = "Your current Subscription has been Expired..! Please Buy again."
    static let privateEmail = "@privaterelay.appleid.com"
    static let myDashboard = "My Dashboard"
    static let active = "Active"
    static let shareCalenlarLink = "Share Calendar Link"
    static let createMiplanitCalendar = "Create MiPlaniT Calendar"
    static let miplanitSite = "https://miplanit.com"
}

struct Message {
    static let yes = "Yes"
    static let no = "No"
    static let ok = "Ok"
    static let save = "Save"
    static let cancel = "Cancel"
    static let error = "Error"
    static let success = "Success"
    static let alert = "Alert"
    static let confirm = "Confirm"
    static let settings = "Settings"
    static let update = "Updates"
    static let warning = "Warning"
    static let editSeries = "Edit series"
    static let tryAgain = "Try Again"
    static let unknownError = "Unknown Error occured"
    static let noitemstoprint = "No items to print in your shopping list"
    static let noitemstoprinttodo = "No To Do's to print in your To Do list"
    static let permissionError = "Permission Error"
    static let notSyncError = "Not Sync Error"
    static let eventNameError = "Event name required"
    static let taskNameError = "Task name required"
    static let startDateExpired = "Invalid start date"
    static let passwordMismatch = "Password Mismatch"
    static let invalidEmailAddress = "Invalid e-mail Address"
    static let requiredEmailAddress = "E-mail is Required"
    static let incorrectUserName =  "Name is Required"
    static let incorrectProductName =  "Product Name is Required"
    static let incorrectStoreName =  "Store Name is Required"
    static let incorrectShoppingListName =  "Shopping list title is Required"
    static let incorrectCouponName =  "Name is Required"
    static let incorrectCouponCode =  "Code is Required"
    static let incorrectCouponId =  "ID is Required"
    static let incorrectLocationName =  "Location is Required"
    static let incorrectAmount =  "Amount is Required"
    static let incorrectDate =  "Date is Required"
    static let incorrectCalendarName =  "Calendar Name is Required"
    static let calendarNameExist =  "Calendar name is already exist"
    static let incorrectPassword =  "Password is Required"
    static let invalidPassword =  "Password not reached valid criteria"
    static let invalidPhoneNumber = "Invalid Phone Number"
    static let requiredPhoneNumber = "Phone Number is Required"
    static let userAlreadyExist = "User already exist"
    static let cardNameIsRequired = "Card Name is Required"
    static let cardNumberIsRequired = "Card Number is Required"
    static let resendOTP = "Verification Code resent successfully"
    static let confirmLogout = "Are you sure you want to log out?"
    static let serviceDetected = "New change detected. Do you want to update?"
    static let notificationPermission = "Please allow permission to display notifications in Settings"
    static let eventCancelMessage = "You will be removed as a participant from this event and the same will be removed from your calendar . Do you wish to proceed?"
    static let eventDeleteMessage = "The event will be deleted for everyone. Do you wish to proceed?"
    static let toDoNotSaved = "Sorry, the To Do not get saved."
    static let calendarPermission = "Please allow permission to access calendar in Settings"
    static let somethingWrong = "Something went wrong and we can’t sign you in right now. Please try again later"
    static let videoDenied = "Access to the camera roll is switched off, please enable it in app settings to continue"
    static let galleryDenied = "Access to the gallery is switched off, please enable it in app settings to continue"
    static let calendarAddedSuccessfully = "Calendar added successfully"
    static let calendarEditedSuccessfully = "Calendar edited successfully"
    static let calendarImageUploadFailed = "Failed to upload image, please try after some time"
    static let eventAddedSuccessfully = "Event added successfully"
    static let giftCouponAddedSuccessfully = "Coupons / Gifts added successfully"
    static let giftCouponEditedSuccessfully = "Coupons / Gifts edited successfully"
    static let purchaseAddedSuccessfully = "Purchase added successfully"
    static let purchaseEditedSuccessfully = "Purchase edited successfully"
    static let shopAddedSuccessfully = "Shopping List added successfully"
    static let shopEditedSuccessfully = "Shopping List edited successfully"
    static let taskAddedSuccessfully = "Task added successfully"
    static let taskEditedSuccessfully = "Task edited successfully"
    static let taskDeletedSuccessfully = "Task deleted successfully"
    static let eventEditedSuccessfully = "Event edited successfully"
    static let downloadEventSuccess = "Events retrieved successfully"
    static let otpSentToMail = "Please enter the verification code\nwe just sent you on your email address."
    static let otpSentToPhone = "Please enter the verification code\nwe just sent you on your phone number."
    static let importOtherOptions = "Do you want to import calendars from other providers?"
    static let fullPermissionMessage = "Gives permission to add new events as well as view all events added in the calendar"
    static let partialPermissionMessage = "Gives permission to add new events, but can only view special events assigned to them"
    static let comingSoon = "Coming soon"
    static let feedbackSentSuccessfully = "Feedback sent successfully"
    static let errorMailSend = "Your Device not configured for sending mail!"
    static let remindMeNoValid = "Remind Me is not valid with the selected start date"
    static let socialLoginFailed = "Unable to retrieve user info. Please try again later."
    static let appleInValidCalendars = "The apple calendar you imported not matching with this device. Please try to import again."
    static let socialInvalidCalendarAccount = "Unable to collect calendar info. Do you want to try a different account?"
    static let eventEditAllEventInThisScreen = "If you changed specific events in the series, your changes will be canceled and those events will match the series again."
    static let occurrenceDelete = "This is a repeating task. Selection will move these all future To Do’s for this task to your Deleted list."
    static let downloadEventFailedFromCalander:(_ name: String) -> String = { name in
        return "Unable to retreive Events from \(name)"
    }
    static let signUpConfirm:(_ account: String) -> String = { account in
        return "We are registering your account using \"\(account)\". Do you wish to continue?"
    }
    static let deleteCalendar:(_ name: String) -> String = { name in
        return "Are you sure you want to delete \"\(name)\" calendar?"
    }
    static let deleteShareCalendar:(_ name: String) -> String = { name in
        return "Are you sure you want to delete default shared calendar?"
    }
    static let syncingWillNotify:(_ type: String) -> String = { type in
        return "Latest events from your \(type == "1" ? "Google" : "Office 365 account") is syncing now. You will be notified once syncing is complete."
    }
    static let deleteEventConfirmation = "Are you sure you want to delete this event?"
    static let deleteRepeatEventConfirmation = "Are you sure you want to delete this and future events?"
    static let deletePurchaseConfirmation = "Are you sure you want to delete this purchase item?"
    static let deleteGiftCoupnConfirmation = "Are you sure you want to delete this gifts card?"
    static let redeemGiftCoupnConfirmation = "Are you sure you want to redeem this gifts card?"
    static let eventDeletedSuccessfully = "Event Deleted successfully"
    static let calendarDeletedSuccessfully = "Calendar Deleted successfully"
    static let paymentInformationMissing = "Please Select or Add a new Card"
    static let shopListCompleted = "Shopping List marked as Completed"
    static let shopListDeleted = "Shop List Deleted"
    static let helpFullAccess = "Gives permission to add new events as well as view all events added in the calendar"
    static let helpPartialAccess = "Gives permission to add new events, but can only view specific events assigned to them"
    static let notSyncMessage = "Your calendar is not in sync with latest updates. Do you want to refresh it?"
    static let speechRestricted = "Speech recognition restricted on this device"
    static let speechNotAuthorized = "Speech recognition not yet authorized"
    static let editThisPerticularEvent = "This Event only"
    static let editAllFutureEvent = "This & All future Events"
    static let editThisSeriesEvent = "All Events in this Series"
    static let editEvent = "Edit Event"
    static let editShareLink = "Edit Share Link"
    static let deleteEvent = "Delete Event"
    static let editEventMessage = "Do you want to edit.."
    static let deleteEventMessage = "Do you want to delete.."
    static let deleteTodoCategory = "Delete Category"
    static let deleteShoppingList = "Delete Shopping List"
    static let deleteDashboard = "Delete Dashboard"
    static let defaultDashboard = "Default Dashboard"
    static let deleteCategoryMessage = "Do you want to delete this category?"
    static let deleteShoppingListMessage = "Do you want to delete this Shopping List?"
    static let deleteCustomDashboardMessage = "Do you want to delete this Custom Dashboard?"
    static let defaultCustomDashboardMessage = "Do you want to set this Custom Dashboard as Default?"
    static let createCategoryDuplicate = "The added category is either empty or already existing."
    static let deleteTodoItem = "Delete To Do's"
    static let deleteShoppingItem = "Delete Shopping Items"
    static let restoreTodoItem = "Restore To Do's"
    static let deleteTodoItemMessage = "Do you want to delete these To Do item(s)?"
    static let restoreTodoItemMessage = "Do you want to restore this To Do item?"
    static let deleteShoppingItemMessage = "Do you want to delete these Shopping item(s)?"
    static let assignedtomemessage = "This task is already assigned to you. You have no permission to change that...!"
    static let blankTitle = "To Do title should not be blank"
    static let shopItemNameBlankTitle = "Shop Item Name should not be blank"
    static let shopItemDueDateBlank = "Due Date Should not be blank"
    static let noToDoItemsSelectedAssign = "Kindly select a To Do item to assign it to someone."
    static let noToDoItemsSelectedMove = "Kindly select a To Do item to move it to another list."
    static let noShoppingItemsSelectedMove = "Kindly select a Shopping item to move it to another list."
    static let noShoppingItemsSelectedFavorite = "Kindly select a Shopping item to favorite."
    static let noShoppingItemsSelectedComplete = "Kindly select a Shopping item to complete."
    static let noShoppingItemsSelectedDueDate = "Kindly select a Shopping item to set a due date."
    static let noToDoItemsSelectedDueDate = "Kindly select a To Do item to set a due date."
    static let noToDoItemsSelectedDelete = "Kindly select To Do item for deleting."
    static let noShoppingItemsSelectedDelete = "Kindly select a Shopping item for deleting."
    static let validTitle = "Shopping List Title is either empty or already existing. Please enter a valid title."
    static let duplicateShopListName = "Shopping List Title is already exist."
    static let validTitleforItem = "Please enter a valid name for the shopping item or select from existing list"
    static let socialAccountsExpired = "Some of your accounts imported has been expired. Please re-login from Menu -> Settings -> Accounts"
    static let singleChildMove = "Cannot move this since this is part of a recurring To Do. You can move the recurring To Do to another list."
    static let singleChildAssign = "Cannot assign this since this is part of a recurring To Do. You can assign the recurring To Do."
    static let multipleChildMove = "You cannot move To Do's under a recurring To Do to another list."
    static let multipleChildDueDate = "The due date for To Do's under a recurring To Do cannot be changed."
    static let confirmationAddCompletedShopItem = "This item is already there in the Completed List. Do you want to add this item again?"
    static let confirmationAddInCompletedShopItem = "You have already added this item into your list. Do you want to edit it?"
    static let noPermissionToAssignTodo = "You have no permission to change Assignee for this To Do."
    static let multipleChildAssign = "You cannot assign To Do's under a recurring To Do"
    static let noEventDashboard: (_ section: DashBoardSection) -> String = { section in
        switch section {
        case .today:
            return "No Events for Today \n Start Adding Events From Calendar"
        case .tomorrow:
            return "No Events for Tomorrow \n Start Adding Events From Calendar"
        case .week:
            return "No Events for this Week \n Start Adding Events From Calendar"
        default:
            return "No Events Found \n Start Adding Events From Calendar"
        }
    }
    static let noItemsDashboard: (_ section: DashBoardSection) -> String = { section in
        switch section {
        case .today:
            return "No Items for Today"
        case .tomorrow:
            return "No Items for Tomorrow"
        case .week:
            return "No Items for this Week"
        default:
            return "No Items Found"
        }
    }
    static let noItemsFound = "No Items Found"
    static let restoreSubscriptionFailed = "Restore Subscription Failed"
    static let purchaseSubscriptionFailed = "Purchase Failed"
    static let switchTransactionPermission = "Subscription from this Apple ID is already linked with another MiPlaniT account. Do you want to switch it to your current Account?"
    static let transactionPermission = "Confirm Transfer"
    static let confirmSaveQuantity = "Do you want to save the updated quantity ?"
    static let newVersionAvailable = "New Version Available"
    static let newVersionAvailableMessage = "There is a new version available for download! Please update the app by visiting the Apple Store."
    static let versionUpdate = "Update"
    static let exceedDataStorageLimit = "You have exceeded the data limit. You must delete some data to continue or contact support."
    static let outOfStorage = "Out of Storage"
    static let shopItemAlreadyExist = "Shop Item Name already exist"
    static let skipMessage = "Please provide your email or mobile number to experience the full functionality of this application."
    static let goBack = "Skip"
    static let dashboardPopUpSubText:(_ count: Int, _ section: DashBoardSection) -> String = { count, section in
        var day = "Upcoming"
        switch section {
        case .today:
            day = "for today"
        case .tomorrow:
            day = "for tomorrow"
        case .week:
            day = "for this week"
        case .all:
            day = "Upcoming"
        }
        return "You have \(count) \(count == 1 ? "item" : "items") \(day)!"
    }
    static let inviteeMissingShareLink = "Invitee is missing."
    static let invalidShareLinkShareLink = "Date range selected has expired."
    static let userAlreadyExistInMiPlaniT = "User already exist in MiPlaniT"
    static let pastScheduleShareLink = "Are you sure you want to schedule a meeting in the past?"
}

struct FileNames {
    static let country = "Country"
    static let iconGallery = "iconGallery"
    static let iconViewAttach = "iconViewAttach"
    static let iconCamera =  "iconCamera"
    static let shoppingIcon = "shopping-icon"
    static let giftCardDDicon = "giftCardDDicon"
    static let giftcouponDDicon = "giftcouponDDicon"
    static let purchasebillDicon = "bill"
    static let purchasereceipticon = "receipt"
    static let todolistIcon = "task_list_icon"
    static let todoIcon = "todoIcon"
    static let calendarIcon = "calendar-icon"
    static let ballonIcon = "ballon-icon"
    static let iconEditCalendar =  "editCalendar-icon"
    static let iconViewCalendar =  "viewCalendarIcon"
    static let imageTodoFavouriteIcon = "todo_favourite_icon"
    static let imageTodoFavouriteDropDown = "icon-favourite-dropdown"
    static let imageCategorysorticon = "icon-category-detail"
    static let imageTodoOverdueDropDown = "icon-overdue-dropdown"
    static let deleteDroDown = "todo-delete-bottom"
    static let imageTodoAssignToMeDropDown = "icon-assignedToMe-dropdown"
    static let imageTodoCameraDropDown = "iconCamera"
    static let imageTodoGalleryDropDown = "iconGallery"
    static let imageTodoViewImagesDropDown = "iconViewAttach"
    static let imageRecentItemssDropDown = "iconRecentItems"
    static let imageFavoritesDropDown = "todo-favourite-select-detail"
    static let imageCategoriesDropDown = "iconCategories"
    static let imageShoppingListsDropDown = "iconShoppingLists"
    static let imageTodoUnplanned = "todo_unplanned_icon"
    static let imageOverDue = "todo_overdue_icon"
    static let imageAssigneToMe = "todo_assigned_to_me_icon"
    static let imageToDoCompleted = "todo_completed_icon"
}

struct FilePath {
    static let appcontent = "/appcontent"
}

struct CellIdentifier {
    static let cell = "cell"
    static let cellData = "cellData"
    static let cellHeader = "cellHeader"
    static let dropDownCell = "dropDownCell"
    static let dropDownCellCalendar = "dropDownCellCalendar"
    static let userCellCalendar = "userCellCalendar"
    static let cellNoEvents = "cellNoEvents"
    static let requestNotificationPendingCell = "RequestNotificationPendingCell"
    static let eventTagCollectionViewCell = "eventTagCollectionViewCell"
    static let eventAddTagCollectionViewCell = "eventAddTagCollectionViewCell"
    static let giftCouponTagCollectionViewCell = "giftCouponTagCollectionViewCell"
    static let giftCouponAddTagCollectionViewCell = "giftCouponAddTagCollectionViewCell"
    static let activityTagCollectionViewCell = "activityTagCollectionViewCell"
    static let activityPredictedTagCollectionViewCell = "activityPredictedTagCollectionViewCell"
    static let activityAddTagCollectionViewCell = "activityAddTagCollectionViewCell"
    static let purchaseTagCollectionViewCell = "purchaseTagCollectionViewCell"
    static let purchaseAddTagCollectionViewCell = "purchaseAddTagCollectionViewCell"
    static let requestNotificationDoneCell = "RequestNotificationDoneCell"
    static let userCell = "cellUser"
    static let selectedUserCell = "cellSelectedUser"
    static let calendarInvitiesCell = "CalendarInvitiesCell"
    static let cellUserHeader = "cellUserHeader"
    static let notifiedCellCalendar = "notifiedCellCalendar"
    static let cellUserCalendarHeader = "userCalendarHeader"
    static let cellCalendarHeader = "calendarHeader"
    static let dateHeaderCell = "dateHeaderCell"
    static let cellShoppingItemHeader = "cellShoppingItemHeader"
    static let cellShoppingItemFooter = "cellShoppingItemFooter"
    static let cellTagSelect = "cellTagSelect"
    static let cellPurchase = "cellPurchaseItem"
    static let cellGiftCouponItem = "cellGiftCouponItem"
    static let cellDashboardItem = "cellDashboardItem"
    static let cellCustomDashboards = "cellCustomDashboards"
    static let cellShoppingListItem = "cellShoppingListItem"
    static let cellShoppingItemCompleted = "cellShoppingItemCompleted"
    static let cellShoppingItem = "cellShoppingItem"
    static let cellAttachments = "cellAttachments"
    static let cellCardSelected = "cellCardSelected"
    static let inviteesStatusTableViewCell = "InviteesStatusTableViewCell"
    static let cellCompletedData = "cellCompletedData"
    static let calendarViewHeaderCell = "calendarViewHeaderCell"
    static let calendarViewFooterCell = "calendarViewFooterCell"
    static let inviteesCell = "inviteesCell"
    static let inviteesCollectionViewCell = "inviteesCollectionViewCell"
    static let suggustCell = "suggustCell"
    static let userImageCell = "userImageCell"
    static let addInviteesListCell = "addInviteesListCell"
    static let listInviteesCell = "listInviteesCell"
    static let searchResultCell = "searchResultCell"
    static let calendarColorCell = "calendarColorCell"
    static let toDoTaskListViewCell = "toDoTaskListViewCell"
    static let toDoCategoryListCell = "toDoCategoryListCell"
    static let toDoCompletedTaskListViewCell = "toDoCompletedTaskListViewCell"
    static let assignUserCollectionViewCell = "AssignUserCollectionViewCell"
    static let collectionViewTagCell = "collectionViewTagCell"
    static let cellToDoAddItemCell = "cellToDoAddItemCell"
    static let toDoCategoryListHeaderCell = "toDoCategoryListHeaderCell"
    static let shoppingCategoryListHeaderCell = "shoppingCategoryListHeaderCell"
    static let assignUserHeaderView = "assignUserHeaderView"
    static let dateFooterCell = "dateFooterCell"
    static let shopListCompletedItemCell = "shopListCompletedItemCell"
    static let shopListItemViewCell = "shopListItemViewCell"
    static let mainCategoryCell = "mainCategoryCell"
    static let subCategoryCell = "subCategoryCell"
    static let shopListSelectionCell = "shopListSelectionCell"
    static let shoppingListTableViewCell = "shoppingListTableViewCell"
    static let shoppingAttachmentCell = "shoppingAttachmentCell"
    static let autoCompleteTagCell = "autoCompleteTagCell"
    static let shopAttachmentCell = "shopAttachmentCell"
    static let shoppingListItemHeaderTableViewCell = "shoppingListItemHeaderTableViewCell"
    static let eventShareLinkCell = "eventShareLinkCell"
}

struct StoryBoards {
    static let dashboard = "Dashboard"
    static let customDashboard = "CustomDashboard"
    static let main = "Main"
    static let myTask = "Task"
    static let profile = "Profile"
    static let settings = "Settings"
    static let requestNotification = "RequestNotification"
    static let calendar = "Calendar"
    static let purchases = "Purchases"
    static let giftCoupons = "GiftCoupons"
    static let shoppingList = "ShoppingList"
    static let NavigationDrawer = "NavigationDrawer"
    static let event = "Event"
    static let pricing = "Pricing"
}

struct StoryBoardIdentifier {
    static let dashboard = "DashBoardViewController"
    static let customDashboard = "CustomDashBoardHomeViewController"
    static let splash = "SplashViewController"
    static let profile = "UpdateProfileViewController"
    static let settings = "SettingsViewController"
    static let help = "HelpViewController"
    static let requestNotification = "RequestNotificationViewController"
    static let todoBase = "TodoBaseViewController"
    static let calendar = "CalanderViewController"
    static let purchases = "PurchaseViewController"
    static let giftCoupons = "GiftCouponsViewController"
    static let shoppingList = "ShoppingListViewController"
    static let notificationToDoDetailViewController = "NotificationToDoDetailViewController"
    static let viewEventViewController = "ViewEventViewController"
    static let viewCalendarDetailViewController = "ViewCalendarDetailViewController"
    static let accountListViewController = "AccountListViewController"
    static let shoppingItemDetailViewController = "ShoppingItemDetailViewController"
    static let ShopListItemViewDetails = "ShopListItemViewDetails"
    static let ShoppingListViewController = "ShoppingListViewController"
    static let AddShoppingItemsViewController = "AddShoppingItemsViewController"
    static let pricingViewController = "PricingViewController"
    static let customCategoryToDoViewController = "CustomCategoryToDoViewController"
    static let InterstitialAdsViewController = "InterstitialAdsViewController"
}

struct Extensions {
    static let fileTypePlist = "plist"
    static let png = ".png"
}

struct Fonts {
    static let SFUIDisplayMedium = "SFUIDisplay-Medium"
    static let SFUIDisplayRegular = "SFUIDisplay-Regular"
}

struct Table {
    static let planItUser = "PlanItUser"
    static let planItSocialUser = "PlanItSocialUser"
    static let planItSettings = "PlanItSettings"
    static let planItCalendar = "PlanItCalendar"
    static let planItOwner = "PlanItOwner"
    static let planItEvent = "PlanItEvent"
    static let planItEventCalendar = "PlanItEventCalendar"
    static let planItCreator = "PlanItCreator"
    static let planItModifier = "PlanItModifier"
    static let planItInvitees = "PlanItInvitees"
    static let planItTask = "PlanItTask"
    static let planItTags = "PlanItTags"
    static let planItExcludedSections = "PlanItExcludedSections"
    static let planItEventAttendees = "PlanItEventAttendees"
    static let planItEventAttachment = "PlanItEventAttachment"
    static let planItEventRecurrence = "PlanItEventRecurrence"
    static let planItUserPayment = "PlanItUserPayment"
    static let planItPurchase = "PlanItPurchase"
    static let planItPurchaseCard = "PlanItPurchaseCard"
    static let planItPurchaseAttachment = "PlanItPurchaseAttachment"
    static let planItShopMasterItem = "PlanItShopMasterItem"
    static let planItShopItems = "PlanItShopItems"
    static let planItUserAttachment = "PlanItUserAttachment"
    static let planItGiftCoupon = "PlanItGiftCoupon"
    static let planItDashboard = "PlanItDashboard"
    static let planItShopList = "PlanItShopList"
    static let planItShopListItems = "PlanItShopListItems"
    static let planItShopMainCategory = "PlanItShopMainCategory"
    static let planItShopSubCategory = "PlanItShopSubCategory"
    static let planItShopListDetail = "PlanItShopListDetail"
    static let planItSuggustionTags = "PlanItSuggustionTags"
    static let planItTodoRecurrence = "PlanItTodoRecurrence"
    static let planItTodo = "PlanItTodo"
    static let planItTodoCategory = "PlanItTodoCategory"
    static let planItSubTodo = "PlanItSubTodo"
    static let planItSharedUser = "PlanItSharedUser"
    static let planItReminder = "PlanItReminder"
    static let planItUserNotification = "PlanItUserNotification"
    static let planItUserNotificationEvent = "PlanItUserNotificationEvent"
    static let planItUserNotificationParent = "PlanItUserNotificationParent"
    static let planItDataStorage = "PlanItDataStorage"
    static let planItContacts = "PlanItContacts"
    static let planItSilentEvent = "PlanItSilentEvent"
    static let planItShareLink = "PlanItShareLink"
    static let planItEventShareLinkCalendar = "PlanItEventShareLinkCalendar"
    static let planItShopListCategoryOrder = "PlanItShopListCategoryOrder"
}

struct UserDefault {
    static let deviceId = "deviceId"
    static let deviceToken = "deviceToken"
    static let calendarHelp = "calendarHelp"
    static let selectedDashboardHelp = "selectedDashboardHelp"
    static let customDashboardListHelp = "customDashboardListHelp"
    static let createDashboardHelp = "createDashboardHelp"
    static let notifyCalendarHelp = "notifyCalendarHelp"
    static let appVersion = "appVersion"
    static let forceUpdate = "forceUpdate"
    static let appVersionMessage = "appVersionMessage"
    static let currentDayEventCount = "currentDayEventCount"
    static let currentDayToDoCount = "currentDayToDoCount"
    static let currentDayShoppingCount = "currentDayShoppingCount"
    static let currentDayGiftCount = "currentDayGiftCount"
    static let currentDayReceiptBillCount = "currentDayReceiptBillCount"
}

struct DateFormatters {
    static let YYYYMMDDTHHMMSSSZ = "yyyyMMdd'T'HHmmssZ"
    static let YYYYHMMHDDTHHCMMCSSSZ = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let YYYYHMMHDDTHHCMMCSSS = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    static let YYYYHMMHDDTHHCMM = "yyyy-MM-dd'T'HH:mm"
    static let YYYYHMMHDDSHHCMMCSSSZ = "yyyy-MM-dd HH:mm:ss"
    static let DDSMMMSYYYYSHHCMMCSSSA = "dd MMM yyyy hh:mm:ss a"
    static let DDHMMMHYYYYSHHCMMCA = "dd-MMM-yyyy hh:mm a"
    static let DDHMMMHYYYYSHHCMMCSSSA = "dd-MMM-yyyy hh:mm:ss a"
    static let DDHMMMHYYYYSHHCMMCSSS = "dd-MMM-yyyy hh:mm:ss"
    static let DDHMMHYYYYSHHCMMCSSS = "dd-MMM-yyyy hh:mm:ss"
    static let YYYYHMMHDDSHHCMMCSSSA = "yyyy-MM-dd hh:mm:ss a"
    static let DDSMMMSYYYY = "dd MMM yyyy"
    static let YYYYHMMMHDD = "yyyy-MM-dd"
    static let HHSMMSA = "hh:mm a"
    static let HHHMMHSS = "HH-mm-ss"
    static let HHCMMCSS = "HH:mm:ss"
    static let HHMM = "HH:mm"
    static let YYYYHMMDDSHHMMSS = "yyyy-MM-dd HH:mm:ss"
    static let DDHMMMMHYYYY = "dd-MMM-yyyy"
    static let DDHMMHYYYY = "dd-MM-yyyy"
    static let MMDDYYYY = "MM/dd/yyyy"
    static let EEEEMMMDDYYYY = "EEEE MMMM d, yyyy"
    static let MMMDDYYYY = "MMM d, yyyy"
    static let EEEMMMDDYYYYHHSSA = "EEE, MMMM d, yyyy hh:mm a"
    static let HMMAEEEMMMDDYYYY = "h:mm a EEE, MMMM d, yyyy"
    static let EEEMMMDDYYYYHSSA = "EEE, MMM d yyyy, h:mm a"
    static let EEEMMMDDHHSSA = "EEE, MMMM d, hh:mm a"
    static let EEEMMDDHHSSA = "EEE, MMM d, hh:mm a"
    static let EEEMMDDHMMA = "EEE, MMM d, h:mm a"
    static let MMDDYYYYHMMSSA = "MM/dd/yyyy hh:mm:ss a"
    static let MMDDYYYYHMMSS = "MM/dd/yyyy HH:mm:ss"
    static let EEEMMMDDYYYY = "EEE, MMM d, yyyy"
    static let EEEDDMMMYYYY = "EEE, d MMM, yyyy"
    static let EEEDDMMM = "EEE, dd MMM"
    static let EEECMMMSDD = "EEE, MMM d"
    static let EEEDDHMMMHYYY = "EEE, dd-MMM-yyy"
    static let HHSA = "hh a"
    static let HHMMSA = "hh:mm a"
    static let HMMSA = "h:mm a"
    static let YYYMMDD = "yyyyMMdd"
    static let EEEESDDMMM = "EEEE dd MMM"
    static let HHCMMCSSSA = "hh:mm:ss a"
    static let dd = "dd"
    static let MMMSDCYYYY = "MMM d, yyyy"
    static let YYYYHMMHDDTHHCMMCSSSDSSS = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    static let YYYMMDDSHHCMMCSSVV = "yyyy-MM-dd HH:mm:ss VV"
}

struct Notifications {
    static let userNotifications = "User Notifications"
    static let calendarResetToInitialDate = "Calendar Reset To Initial Date"
    static let calendarUsersDataUpdated = "Calendar Users Data Updated"
    static let shareLinkUsersDataUpdated = "Share Link Users Data Updated"
    static let todoUsersDataUpdated = "To Do Users Data Updated"
    static let purchaseUsersDataUpdated = "Purchase Users Data Updated"
    static let shoppingUsersDataUpdated = "Shopping Users Data Updated"
    static let giftUsersDataUpdated = "Gift Users Data Updated"
    static let calendarFastestDataProcessFinished = "Calendar Fastest Data Processed"
    static let detectedSocialAccountsExpiry = "Detected Social Account Expiry"
    static let detectedSocialAccountsRenewal = "detectedSocialAccountsRenewal"
    static let dashboardEventUpdate = "dashboardEventUpdate"
    static let dashboardToDoUpdate = "dashboardToDoUpdate"
    static let dashboardShoppingUpdate = "dashboardShoppingUpdate"
    static let dashboardPurchaseUpdate = "dashboardPurchaseUpdate"
    static let dashboardGiftUpdate = "dashboardGiftUpdate"
    static let usersCalendarOnlyDataFetched = "usersCalendarOnlyDataFetched"
    static let updateAdSenceView = "updateAdSenceView"
    static let fetehUserContactProcessFinished = "Fetch User Contact Data Processed"
}

struct Colors {
    static let eventTimeSlotRedColor = UIColor.init(red: 220/225, green: 101/225, blue: 101/225, alpha: 1.0)
    static let eventTimeSlotGreenColor = UIColor.init(red: 110/225, green: 189/225, blue: 126/225, alpha: 1.0)
    static let eventTimeSlotStripeRedColor = UIColor.init(white: 1.0, alpha: 0.1)
    static let eventTimeSlotStripeGreenColor = UIColor.init(white: 1.0, alpha: 0.1)
    static let eventDefaultColor = UIColor.init(red: 239/255.0, green: 247/255.0, blue: 255/255.0, alpha: 1)
    static let dashBoardCardColorBorder:[(bg: UIColor, border: UIColor)] = [
    (UIColor(red: 240/255.0, green: 241/255.0, blue: 255/255.0, alpha: 1.0),UIColor(red: 185/255.0, green: 194/255.0, blue: 255/255.0, alpha: 1.0)),
    (UIColor(red: 255/255.0, green: 248/255.0, blue: 249/255.0, alpha: 1.0),UIColor(red: 255/255.0, green: 179/255.0, blue: 190/255.0, alpha: 1.0)),
    (UIColor(red: 242/255.0, green: 254/255.0, blue: 255/255.0, alpha: 1.0),UIColor(red: 87/255.0, green: 232/255.0, blue: 250/255.0, alpha: 1.0)),
    (UIColor(red: 237/255.0, green: 248/255.0, blue: 255/255.0, alpha: 1.0),UIColor(red: 161/255.0, green: 204/255.0, blue: 241/255.0, alpha: 1.0)),
    ]
}

struct Numbers {
    static let longPressDelay = 0.11
    static let silentSyncTimeInterval = 5
}

enum LoginType {
    case google, facebook, twitter, outlook, apple
}

enum MiPlanItEnumCalendarType: Int {
    case outlook = 0, google, apple
}

enum CalendarSelection {
    case allCalendar, eventCalendar, notifyCalendar
}

enum Filters: Int {
    case eProductName, eStoreName, eAddress, ePaymentType, eCouponName, eCouponCode, eCouponID, eIssuedBy, eReceivedFrom
}

enum SocialCalendarEventStatus {
    case pending, started, completed
}

enum DropDownOptionType: Int {
    case eDefault, eCamera, eGallery, eViewAttachment, eUsersCalendar, eMyCalendar, eEditCalendar, eViewCalendar, eCalendarName, eNever, eEveryDay, eEveryWeek, eEveryMonth, eEveryYear, e15MinBefore, e30MinBefore, e1HrBefore, e1DayBefore, e1MonthBefore, eEvent, eCalendar, eTask, eShopping, ePriorityLow, ePriorityHigh, ePriorityMedium, e1Day, e2Day, e3Day, e4Day, e5Day, e6Day, e7Day, e8Day, e9Day, e10Day, e1Week, e2Week, e3Week, e4Week, e5Week, e6Week, e7Week, e8Week, e9Week, e10Week, e1Month, e2Month, e3Month, e4Month, e5Month, e6Month, e7Month, e8Month, e9Month, e10Month, e1Year, e2Year, e3Year, e4Year, e5Year, e6Year, e7Year, e8Year, e9Year, e10Year, eSunday, eMonday, eTuesday, eWednesday, eThursday, eFriday, eSaturday, eAlphabetically, eFavourite, eDueDate, eCreatedDate, eSortOption, eShare, ePrint, eDelete, eUnplanned, eOverDue, eAssignedToMe, eCompleted, eAssignedByMe, eRecentItems, eShoppingLists, eCategories, eSwitchDashBoard, eNewDashBoard, eCouponTypeGift, eCouponTypeCoupon, eReceipt, eBill, eActive, eExpired
}

enum Weekday : Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

enum DropDownCategory: Int {
    case eFrequency = 0, eInterval, eUntil, eOnDays
}

public enum UserType: Int {
    case eAWSUser = 0, eFBUser, eGoogleUser, eTwitterUser, eOutlookUser, eAppleUser
}

enum NavigationDrawerItem: Int {
    case profile, dashBoard, calendar, shoppingList, myTask, purchase, requests, giftCoupon,settings ,   help, logOut , pricing
}

enum TabBarItem: Int {
    case dashBoard, myCalendar, myTask, shoppingList, notification, settings, purchase, giftCoupon, help
}

enum TabBarAddOptions: Int {
    case calendar, event, task, purchase, gift, shopping
}

enum OrginPoint: Int {
    case left, right, center
}

enum CalendarUserType: Int {
    case contact, miplanit, other
}

enum Counters: Int {
    case forwardEvent = 25, backwardEvent = 6
}

enum MiPlanItCalendarType: Int {
    case myCalendar = 0, OtherUser
}

enum ServiceDetection {
    case newCalendar(calendars: [Double])
    case calendarDeleted(calendars: [Double])
    case newEvent(events: [Double])
    case eventDeleted(events: [Double])
    case newPurchase
    case purchaseDeleted
    case newGiftCoupon
    case giftCouponDeleted
    case todo
    case todoDeleted
    case newShopping
    case shoppingDeleted
    case eventShareLink
    case eventShareLinkDeleted
}

enum ServiceOutPut: Int {
    case calendar, purchase, gift, todo, shop, eventShareLink
}

enum TaskDayType: Int {
    case all, overdue, today, tomorrow, upcoming, done
}

enum PasswordHintNames {
    case contains8Charecter(status: Bool)
    case containsSpecialCharecter(status: Bool)
    case containsNumber(status: Bool)
    case containsUppercase(status: Bool)
    case containsLowercase(status: Bool)
}

enum EventTimeViewPosition {
    case outside, inside
}

enum LocalNotificationType: Double {
    case new = 0, registered, expired, recurrent
}

enum LocalNotificationMethod: String {
    case event = "Event_", todo = "Todo_", shopping = "Shopping_"
}

enum AttachmentType: Int {
    case none = 0, purchase = 1, shopping = 2, giftCoupon = 3, task = 4
}

enum SourceScreen: Int {
    case event = 1, shopping = 2, task = 3, gift = 4, purchase = 5, shareLink = 6
}

enum GiftCouponType {
    case active, redeemed, expired
}

enum MiPlanItEnumDayType {
    case all, today, tomorrow, upcoming, overdue, completed
}

enum RecursiveEditOption {
    case `default`, thisPerticularEvent, allFutureEvent, allEventInTheSeries
}

enum ToDoMainCategory: Int {
    case all = 1, today = 2, upcomming = 3, favourite = 4, unplanned = 5, overdue = 6, assignedToMe = 7, completed = 8, assignedbyMe = 9, custom = 10
}

enum ToDoMode {
    case `default`, edit
}

enum ShopListMode {
    case `default`, edit
}

enum NotificationDelete: String {
    case deleteSpecific = "specific", all = "all", activityType = "activitytype"
}

enum ReminderOption {
    case fiveMinBefore, fifteenMinBefore, thirtyMinBefore, oneHourBefore, oneDayBefore, oneWeekBefore, oneMonthBefore, oneYearBefore, custom, twoHourBefore
}

enum ExpandMenuType {
    case event, calendar, share
}

enum FastestEventTypes {
    case all, today
}

enum DashBoardTitle {
    case event, toDo, purchase, giftCard, shopping
}

enum DashBoardSection {
    case today, tomorrow, week, all
}

enum ConferenceType: String {
    case video = "video", phone = "phone", sip = "sip"
}


enum ShoppingListOptionType {
    case base, categories, resentItems, favoritesList, collectionList, subCategoryItsItems
}

enum DashboardSectionType: String {
    case event = "event", shopping = "shopping", todo = "todo", gift = "gift", purchase = "purchase"
}

enum CouponDataType {
    case gift, coupon
}

enum PurchaseDataType {
    case receipt, bill
}

enum PurchaseRequestType {
    case new, expired, none
}

enum PurchseType {
    case purchase, restore, none
}


enum PurchaseServiceStatus {
    case success, refresh, failed
}

struct KeyChainStore {
    
    static let email:(_ id: String) -> String = { id in
        return "email" + id
    }
    
    static let name:(_ id: String) -> String = { id in
        return "name" + id
    }
}

enum InAppEnviornment {
    case production, sandbox
}

enum IsReminderList: String {
    case True = "True"
    case False = "False"
}
