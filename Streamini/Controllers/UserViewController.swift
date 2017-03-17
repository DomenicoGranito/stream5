//
//  UserViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol UserSelecting: class {
    func userDidSelected(user: User)
}

protocol StreamSelecting: class {
    func streamDidSelected(stream: Stream)
}

protocol UserStatisticsDelegate: class {
    func recentStreamsDidSelected(userId: UInt)
    func followersDidSelected(userId: UInt)
    func followingDidSelected(userId: UInt)
}

protocol UserStatusDelegate: class {
    func followStatusDidChange(status: Bool, user: User)
    func blockStatusDidChange(status: Bool, user: User)
}

class UserViewController: BaseViewController, ProfileDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AmazonToolDelegate
{
    @IBOutlet var changeAvatarButton:UIButton?
    @IBOutlet var userHeaderView:UserHeaderView!
    @IBOutlet var recentCountLabel:UILabel!
    @IBOutlet var recentLabel:UILabel!
    @IBOutlet var followersCountLabel:UILabel!
    @IBOutlet var followersLabel:UILabel!
    @IBOutlet var followingCountLabel:UILabel!
    @IBOutlet var followingLabel:UILabel!
    @IBOutlet var followButton:UIButton!
    @IBOutlet var activityIndicator:UIActivityIndicatorView!
    
    var user:User?
    var userStatisticsDelegate:UserStatisticsDelegate?
    var userStatusDelegate:UserStatusDelegate?
    var userSelectedDelegate:UserSelecting?
    var downloadManager: DownloadManager!
    var selectedImage: UIImage?
    var profileDelegate: ProfileDelegate?
    
    override func viewDidLoad()
    {
        if UserContainer.shared.logged().id==user!.id
        {
            changeAvatarButton?.enabled=true
        }
        
        configureView()
        
        update(user!.id)
        
        recentButtonPressed()
        
        navigationController?.navigationBarHidden=true
    }
    
    @IBAction func avatarButtonPressed()
    {
        let actionSheet=UIActionSheet.changeUserpicActionSheet(self)
        actionSheet.showInView(self.view)
    }

    func actionSheet(actionSheet:UIActionSheet, clickedButtonAtIndex buttonIndex:Int)
    {
        if buttonIndex==1
        {
            let controller=UIImagePickerController()
            controller.sourceType = .PhotoLibrary
            controller.allowsEditing=true
            controller.delegate=self
            self.presentViewController(controller, animated:true, completion:nil)
        }
        if buttonIndex==2
        {
            let controller=UIImagePickerController()
            controller.sourceType = .Camera
            controller.allowsEditing=true
            controller.delegate=self
            self.presentViewController(controller, animated:true, completion:nil)
        }
    }

    func imagePickerController(picker:UIImagePickerController, didFinishPickingImage image:UIImage!, editingInfo:[NSObject:AnyObject]!)
    {
        picker.dismissViewControllerAnimated(true, completion:
            {()->Void in
                self.selectedImage=image.fixOrientation().imageScaledToFitToSize(CGSizeMake(100, 100))
                self.uploadImage(self.selectedImage!)
        })
    }

    func uploadImage(image: UIImage)
    {
        let filename = "\(UserContainer.shared.logged().id)-avatar.jpg"
        
        if AmazonTool.isAmazonSupported() {
            AmazonTool.shared.uploadImage(image, name: filename) { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    self.userHeaderView.progressView.setProgress(progress, animated: true)
                })
            }
        } else {
            let data = UIImageJPEGRepresentation(image, 1.0)!
            UserConnector().uploadAvatar(filename, data: data, success: uploadAvatarSuccess, failure: uploadAvatarFailure, progress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                //let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                //self.userHeaderView.progressView.setProgress(progress, animated: true)
            })
        }
    }

    func uploadAvatarSuccess() {
        //userHeaderView.progressView.setProgress(0.0, animated: false)
        userHeaderView.updateAvatar(user!, placeholder: selectedImage!)
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func uploadAvatarFailure(error: NSError) {
        handleError(error)
    }
    
    func imageDidUpload() {
        UserConnector().avatar(uploadAvatarSuccess, failure: uploadAvatarFailure)
    }

    func imageUploadFailed(error: NSError) {
        handleError(error)
    }

    func configureView()
    {
        let recentLabelText=NSLocalizedString("user_card_recent", comment:"")
        recentLabel.text=recentLabelText
        
        let followersLabelText=NSLocalizedString("user_card_followers", comment:"")
        followersLabel.text=followersLabelText
        
        let followingLabelText=NSLocalizedString("user_card_following", comment:"")
        followingLabel.text=followingLabelText
        
        followButton.hidden=UserContainer.shared.logged().id==user!.id
    }
    
    @IBAction func more_dwnButtonPressed()
    {
       var stream: Stream
        var strurl:String
          //  strurl = "Http://spectator.live/media/\(stream.id)"
          //  downloadManager.startDownloadVideoOrPlaylist(url: strurl)
           // self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func recentButtonPressed()
    {
        if let del=userStatisticsDelegate
        {
            del.recentStreamsDidSelected(user!.id)
        }
    }
    
    @IBAction func followersButtonPressed()
    {
        if let del=userStatisticsDelegate
        {
            del.followersDidSelected(user!.id)
        }
    }
    
    @IBAction func followingButtonPressed()
    {
        if let del=userStatisticsDelegate
        {
            del.followingDidSelected(user!.id)
        }
    }
    
    @IBAction func followButtonPressed()
    {
        followButton.enabled=false
        
        if user!.isFollowed
        {
            SocialConnector().unfollow(user!.id, success:unfollowSuccess, failure:unfollowFailure)
        }
        else
        {
            SocialConnector().follow(user!.id, success:followSuccess, failure:followFailure)
        }
    }
    
    func reload()
    {
        update(user!.id)
    }
    
    func close()
    {
        
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
    
    func followSuccess()
    {
        followButton.enabled=true
        user!.isFollowed=true
        
        let buttonTitle=NSLocalizedString("user_card_unfollow", comment:"")
        followButton.setTitle(buttonTitle, forState:.Normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.followStatusDidChange(true, user:user!)
        }
        
        update(user!.id)
    }
    
    func followFailure(error:NSError)
    {
        handleError(error)
        followButton.enabled=true
    }
    
    func unfollowSuccess()
    {
        followButton.enabled=true
        user!.isFollowed=false
        
        let buttonTitle=NSLocalizedString("user_card_follow", comment:"")
        followButton.setTitle(buttonTitle, forState:.Normal)
        
        if let delegate=userStatusDelegate
        {
            delegate.followStatusDidChange(false, user:user!)
        }
        
        update(user!.id)
    }
    
    func unfollowFailure(error:NSError)
    {
        handleError(error)
        followButton.enabled=true
    }
    
    func getUserSuccess(user:User)
    {
        self.user=user
        
        userHeaderView.update(user)
        recentCountLabel.text="\(user.recent)"
        followersCountLabel.text="\(user.followers)"
        followingCountLabel.text="\(user.following)"
        
        if user.isFollowed
        {
            let buttonTitle=NSLocalizedString("user_card_unfollow", comment:"")
            followButton.setTitle(buttonTitle, forState:.Normal)
        }
        else
        {
            let buttonTitle=NSLocalizedString("user_card_follow", comment:"")
            followButton.setTitle(buttonTitle, forState:.Normal)
        }
        
        activityIndicator.stopAnimating()
    }
    
    func getUserFailure(error:NSError)
    {
        handleError(error)
        activityIndicator.stopAnimating()
    }
    
    func update(userId:UInt)
    {
        activityIndicator.startAnimating()
        UserConnector().get(userId, success:getUserSuccess, failure:getUserFailure)
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
}
