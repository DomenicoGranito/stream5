//
//  ProfileViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import MessageUI

protocol ProfileDelegate:class
{
    func reload()
    func close()
}

class ProfileViewController: BaseTableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
ProfileDelegate
{
    @IBOutlet var userHeaderView: UserHeaderView!
    @IBOutlet var followingValueLabel: UILabel!
    @IBOutlet var followersValueLabel: UILabel!
    @IBOutlet var blockedValueLabel: UILabel!
    @IBOutlet var streamsValueLabel: UILabel!
    
    var user: User?
    var profileDelegate: ProfileDelegate?
    var selectedImage: UIImage?
    
    func configureView()
    {
        userHeaderView.delegate = self
    }
    
    func successGetUser(user: User)
    {
        self.user = user
        userHeaderView.update(user)
        
        followingValueLabel.text    = "\(user.following)"
        followersValueLabel.text    = "\(user.followers)"
        blockedValueLabel.text      = "\(user.blocked)"
        streamsValueLabel.text      = "\(user.streams)"
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func successFailure(error: NSError) {
        handleError(error)
    }
    
    override func viewDidLoad()
    {
        self.configureView()
        
        UserConnector().get(nil, success:successGetUser, failure:successFailure)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let sid = segue.identifier
        {
            if sid == "ProfileToProfileStatistics"
            {
                let controller = segue.destinationViewController as! ProfileStatisticsViewController
                let index = (sender as! NSIndexPath).row
                controller.type = ProfileStatisticsType(rawValue: index)!
                controller.profileDelegate = self
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 1
        {
            self.performSegueWithIdentifier("ProfileToProfileStatistics", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0
        {
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1
        {
            UINavigationBar.resetCustomAppereance()
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.mailUnavailableErrorAlert()
                alert.show()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Config.shared.feedback()])
        mailComposerVC.setSubject(NSLocalizedString("feedback_title", comment: ""))
        
        let appVersion  = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild    = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        let deviceName  = UIDevice.currentDevice().name
        let iosVersion  = "\(UIDevice.currentDevice().systemName) \(UIDevice.currentDevice().systemVersion)"
        let userId      = user!.id
        
        var message = "\n\n\n"
        message = message.stringByAppendingString("App Version: \(appVersion)\n")
        message = message.stringByAppendingString("App Build: \(appBuild)\n")
        message = message.stringByAppendingString("Device Name: \(deviceName)\n")
        message = message.stringByAppendingString("iOS Version: \(iosVersion)\n")
        message = message.stringByAppendingString("User Id: \(userId)")
        
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        mailComposerVC.delegate = self
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        //controller.dismissViewControllerAnimated(true, completion: nil)
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
           // if result.rawValue == MFMailComposeResultFailed.rawValue {
             //   let alert = UIAlertView.sendMailErrorAlert()
               // alert.show()
            //}
        })
    }
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close()
    {
    }
    
    func usernameLabelPressed()
    {
        
    }
    
    func descriptionWillStartEdit()
    {
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
    
    func doneButtonPressed(sender: AnyObject) {
        let text: String
        if userHeaderView.userDescriptionTextView.text == NSLocalizedString("profile_description_placeholder", comment: "") {
            text = " "
        } else {
            text = userHeaderView.userDescriptionTextView.text
        }
        
        let activator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activator)
        
        UserConnector().userDescription(text, success: userDescriptionTextSuccess, failure: userDescriptionTextFailure)
    }
    
    func userDescriptionTextSuccess() {
        self.navigationItem.rightBarButtonItem = nil
        userHeaderView.userDescriptionTextView.resignFirstResponder()
        
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func userDescriptionTextFailure(error:NSError)
    {
        handleError(error)
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
}
