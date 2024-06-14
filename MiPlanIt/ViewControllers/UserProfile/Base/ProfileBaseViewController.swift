//
//  ProfileBaseViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 18/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ProfileBaseViewController: SwipeDrawerViewController {

    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var textFieldName: FloatingTextField!
    @IBOutlet weak var textFieldEmail: FloatingTextField!
    @IBOutlet weak var textFieldPhone: FloatingTextField!
    @IBOutlet weak var buttonCountryCode: UIButton!
    @IBOutlet weak var buttonUpdateProfile: ProcessingButton!
    @IBOutlet weak var buttonUploadProfilePic: ProcessingButton!
    @IBOutlet weak var buttonSkipNow: ProcessingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUserDetails()
        self.downloadUserProfileImageFromServer()
        setView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.manageProfilePicCornerRadius()
    }
    
    //MARK: - Override functions
    func uploadProfileSkipAction() {
        
    }
    
    func uploadProfileContinueAction() {
        
    }
    
    func uploadProfilePicAction() {
        
    }
    
    private func setView(){
        buttonUpdateProfile.setType(type: .primary)
       buttonSkipNow.setType(type: .primary)
    }
    
    //MARK: - IBActions

    @IBAction func profilePictureButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    @IBAction func uploadProfileButtonClicked(_ sender: UIButton) {
        guard self.buttonUploadProfilePic.isSelected else { return }
        self.uploadPicToServerUsingNetwotk()
    }
    
    @IBAction func buttonSkipForNowTouched(_ sender: UIButton) {
        self.uploadProfileSkipAction()
    }
    
    @IBAction func buttonContinueTouched(_ sender: UIButton) {
        if self.validateMandatoryFields() {
            if let email = self.textFieldEmail.text, let phone = self.textFieldPhone.text, email.isEmpty, phone.isEmpty {
                self.showAlertWithAction(message: Message.skipMessage, items: [Message.goBack, Message.ok]) { (index) in
                    if index == 0 {
                        self.updateProfileToServerUsingNetwotk()
                    }
                }
            }
            else {
                self.updateProfileToServerUsingNetwotk()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is CountrySelectionViewController:
            let countrySelectionViewController =  segue.destination as! CountrySelectionViewController
            countrySelectionViewController.delegate = self
        case is ProfileMediaDropDownViewController:
            let uploadOptionsDropDownViewController = segue.destination as? ProfileMediaDropDownViewController
            uploadOptionsDropDownViewController?.delegate = self
        case is CountrySelectionViewController:
            let countrySelectionViewController =  segue.destination as! CountrySelectionViewController
            countrySelectionViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
