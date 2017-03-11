//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import MessageUI

class myProfileViewController: BaseViewController,
    UINavigationControllerDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
UserSelecting, ProfileDelegate {
    @IBOutlet weak var userHeaderView: UserHeaderView!
  
    var userStatisticsDelegate:UserStatisticsDelegate?
    var userStatusDelegate:UserStatusDelegate?
    
    var user: User?
    var profileDelegate: ProfileDelegate?
    
    func userDidSelected(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func configureView()
    {
        self.title = NSLocalizedString("profile_title", comment: "")
        
        userHeaderView.delegate = self
    }
    
    func successGetUser(user: User) {
        self.user = user
        userHeaderView.update(user)
        
       self.navigationItem.rightBarButtonItem = nil
    }
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if let sid=segue.identifier
        {
            if sid=="UserToLinkedUsers"
            {
                let controller=segue.destinationViewController as! LinkedUsersViewController
                controller.profileDelegate=self
                self.userStatisticsDelegate=controller
            }
        }
    }

    func successFailure(error: NSError) {
        handleError(error)
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool)
    {
        navigationController.navigationBar.tintColor = UIColor.blueColor()
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blueColor()]
    }
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureView()
        
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
        activator.startAnimating()
        
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
        UserConnector().get(nil, success:successGetUser, failure:successFailure)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
    }
        
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 2 && indexPath.row == 0 { // share
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 { // feedback
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
    
    func close() {
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
