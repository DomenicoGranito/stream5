//
//  ProfileViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import MessageUI

enum ProfilesActionSheetType: Int {
    case ChangeAvatar
    case Logout
}

protocol ProfilesDelegate: class {
    func reload()
    func close()
}

class SettingsViewController: UITableViewController, UIActionSheetDelegate,ProfilesDelegate
{
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountValueLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var blockedValueLabel: UILabel!
    @IBOutlet weak var streamsLabel: UILabel!
    @IBOutlet weak var streamsValueLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    
    var user: User?
    var profilesDelegate: ProfilesDelegate?
    var selectedImage: UIImage?
    
    func configureView()
    {
        self.title = "Settings"
        accountLabel.text = "Account"
        followersLabel.text = "Playback"
        blockedLabel.text   = "Streaming Quality"
        streamsLabel.text   = "Social"
        notificationLabel.text = "Notifications"
        aboutLabel.text = "About"
        shareLabel.text     = "Devices"
        logoutLabel.text    = NSLocalizedString("profile_logout", comment: "")
    }
   
    func logout() {
       let actionSheet = UIActionSheet.confirmLogoutActionSheet(self)
       actionSheet.tag = ProfilesActionSheetType.Logout.rawValue
       actionSheet.showInView(self.view)
    }

    func successGetUser(user: User) {
        self.user = user
    }
    
    func successFailure(error: NSError) {
   //     handleError(error)
    }

    func logoutFailure(error: NSError) {
        print("failure", terminator: "")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureView()
        UserConnector().get(nil, success:successGetUser, failure:successFailure)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if actionSheet.tag == ProfilesActionSheetType.Logout.rawValue {
            if buttonIndex != actionSheet.cancelButtonIndex {
                UserConnector().logout(logoutSuccess, failure: logoutFailure)
            }
        }
    }

    func logoutSuccess()
    {
        if A0SimpleKeychain().stringForKey("PHPSESSID") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("PHPSESSID")
        }
        if A0SimpleKeychain().stringForKey("id") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("id")
        }
        if A0SimpleKeychain().stringForKey("password") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("password")
        }
        if A0SimpleKeychain().stringForKey("secret") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("secret")
        }
        if A0SimpleKeychain().stringForKey("type") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("type")
        }
        
        // deprecated Twitter.sharedInstance().logOut()
        
        /*let store = Twitter.sharedInstance().sessionStore
         
         if let userID = store.session()?.userID {
         store.logOutUserID(userID)
         }*/
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close() {
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 2 && indexPath.row == 0 { // logout
            logout()
        }
    }
   }
