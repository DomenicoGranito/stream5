//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import Photos

class TabBarViewController: UITabBarController, UITabBarControllerDelegate
{
    @IBOutlet var vtabBar:UITabBar!
    @IBOutlet var miniPlayerView:UIView!
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var videoArtistLbl:UILabel!
    @IBOutlet var videoThumbnailImageView:UIImageView!
    
    var animator:ARNTransitionAnimator!
    var modalVC:ModalViewController!
    var player:DWMoviePlayerController!
    var stream:Stream!
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func viewDidLoad()
    {
        player=DWMoviePlayerController(userId:"D43560320694466A", key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229")
        player.controlStyle = .None
        
        miniPlayerView.frame=CGRectMake(0, view.frame.size.height-99, view.frame.size.width, 50)
        view.addSubview(miniPlayerView)
        miniPlayerView.hidden=true
        
        getPermissions()
    }
    
    func updateMiniPlayerWithStream()
    {
        miniPlayerView.hidden=false
        
        videoTitleLbl.text=stream.title
        videoArtistLbl.text=stream.user.name
        videoThumbnailImageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream.id).jpg"))
    }
    
    func configure()
    {
        setupAnimator()
        updateMiniPlayerWithStream()
        tapMiniPlayerButton()
    }
    
    override func viewWillAppear(animated:Bool)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(goToChannels), name:"goToChannels", object:nil)
    }
    
    func goToChannels(notification:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"goToChannels", object:nil)
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=notification.object as? User
        
        let navigationController=self.viewControllers![self.selectedIndex] as! UINavigationController
        navigationController.pushViewController(vc, animated:true)
    }
    
    @IBAction func tapMiniPlayerButton()
    {
        presentViewController(modalVC, animated:true, completion:nil)
    }
    
    func tabBarController(tabBarController:UITabBarController, shouldSelectViewController viewController:UIViewController)->Bool
    {
        let tabViewControllers=tabBarController.viewControllers
        let fromIndex=tabViewControllers?.indexOf(tabBarController.selectedViewController!)
        
        NSUserDefaults.standardUserDefaults().setInteger(fromIndex!, forKey:"previousTab")
        
        return true
    }
    
    func setupAnimator()
    {
        let animation=MusicPlayerTransitionAnimation(rootVC:self, modalVC:modalVC)
        
        animation.completion={isPresenting in
            if isPresenting
            {
                let modalGestureHandler=TransitionGestureHandler(targetVC:self, direction:.bottom)
                modalGestureHandler.registerGesture(self.modalVC.view)
                modalGestureHandler.panCompletionThreshold=15.0
                self.animator.registerInteractiveTransitioning(.dismiss, gestureHandler:modalGestureHandler)
            }
            else
            {
                self.setupAnimator()
            }
        }
        
        let gestureHandler=TransitionGestureHandler(targetVC:self, direction:.top)
        gestureHandler.registerGesture(miniPlayerView)
        gestureHandler.panCompletionThreshold=15.0
        
        animator=ARNTransitionAnimator(duration:0.5, animation:animation)
        animator.registerInteractiveTransitioning(.present, gestureHandler:gestureHandler)
        
        modalVC.transitioningDelegate=animator
    }
    
    func getPermissions()
    {
        if AVCaptureDevice.respondsToSelector(#selector(AVCaptureDevice.requestAccessForMediaType(_:completionHandler:)))
        {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler:{(granted)->Void in})
        }
        
        if(AVAudioSession.sharedInstance().respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:))))
        {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted:Bool)->Void in})
        }
        
        if NSClassFromString("PHPhotoLibrary") != nil
        {
            PHPhotoLibrary.requestAuthorization{(status)->Void in}
        }
    }
}
