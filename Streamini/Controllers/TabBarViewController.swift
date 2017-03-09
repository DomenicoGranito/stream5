//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import Photos

class mTBViewController: UITabBarController , UITabBarControllerDelegate
{
    @IBOutlet var vtabBar:UITabBar!
    @IBOutlet var miniPlayerView:UIView!
  
    @IBOutlet var containerView:UIView!
    @IBOutlet var playView:UIView!
    @IBOutlet var miniPlayerButton : UIButton!
    
    func tapMiniPlayer()
    {
        presentViewController(modalVC, animated:true, completion:nil)
    }

    override func viewWillAppear(animated:Bool)
    {
        let index=self.selectedIndex
        
        print(index)
    }
    
    func hideButton()
    {
        playView.hidden=true
    }
    
    func showButton()
    {
        playView.hidden=false
        //  view.bringSubviewToFront(playView)
    }
    
    var animator:ARNTransitionAnimator!
    var modalVC:ModalViewController!
    var containerViewController:ContainerViewController?
    
    @IBAction func tapMiniPlayerButton()
    {
        presentViewController(modalVC, animated:true, completion:nil)
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
    
    func tabBarController(tabBarController:UITabBarController, shouldSelectViewController viewController:UIViewController)->Bool
    {
        let tabViewControllers=tabBarController.viewControllers
        let fromIndex=tabViewControllers?.indexOf(tabBarController.selectedViewController!)
        
        NSUserDefaults.standardUserDefaults().setInteger(fromIndex!, forKey:"previousTab")
        
        return true
    }
    
    @IBAction func recButtonPressed(sender:AnyObject)
    {
        self.performSegueWithIdentifier("RootToCreate", sender:self)
    }
    
    func setupMainNavigationItems()
    {
        self.title=""
        
        let button=UIButton(frame:CGRectMake(0, 0, 125, 25))
        button.setImage(UIImage(named:"global"), forState:.Normal)
        button.setImageTintColor(UIColor(white:1, alpha:0.5), forState:.Normal)
        button.setImageTintColor(UIColor(white:1, alpha:1), forState:.Highlighted)
        let item=UIBarButtonItem(customView:button)
        
        self.navigationItem.rightBarButtonItem=item
    }
    
    func searchTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let controller=storyboard.instantiateViewControllerWithIdentifier("SearchScreen")
        self.presentViewController(controller, animated:true, completion:nil)
    }
    
    override func viewDidLoad()
    {
        self.delegate = self
        self.tabBarController?.delegate = self
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as? ModalViewController
        
        setupAnimator()
        
        setupMainNavigationItems()
        
        // Ask for use Camera
        if AVCaptureDevice.respondsToSelector(#selector(AVCaptureDevice.requestAccessForMediaType(_:completionHandler:)))
        {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler:{(granted)->Void in })
        }
        
        // Ask for use Microphone
        if(AVAudioSession.sharedInstance().respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:))))
        {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted:Bool)->Void in })
        }
        
        // Ask for use Photo Gallery
        if NSClassFromString("PHPhotoLibrary") != nil
        {
            if #available(iOS 8.0, *)
            {
                PHPhotoLibrary.requestAuthorization{(status)->Void in }
            }
        }
        
       
        //  self.view.addSubview(playView)
    }

    
    func addCenterButton() {
        let xPosition: [CGFloat] = [5.0, 5.0]
        let yPosition: [CGFloat] = [5.0, 5.0]
        //let xPosition = 10.0
        //let yPosition = 10.0
        //self.tabBarController?.tabBar.frame.origin.x
        //View will slide 20px up
       // let yPosition = playView.frame.origin.y +
        
      //  let height = playView.frame.size.height
       // let width = playView.frame.size.width
//xPosition, yPosition, height, width
       // playView.frame = CGRectMake(300, 520,  50,  50)
//self.view.frame = CGRectMake(300, 520,  50,  50)
        
            //CGRectMake(300, 520,  50,  50)
       // playView.bounds.origin.y
    //    let bounds = self.playView.bounds
     
        
      // self.playView.bounds.origin.y = 300
       // self.playView.bounds.origin.x = 300
        self.playView.frame.origin.y = 20
        self.playView.frame.origin.x = 0
        self.playView.frame.size.width = 375
        self.view.addSubview(playView)
       // self.playView.bounds = CGRectMake( 600,  100, 60, 50)
        
      //  self.playView.bounds.origin.y = 100
    }
}
