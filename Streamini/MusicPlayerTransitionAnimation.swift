//
//  MusicPlayerTransitionAnimation.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2016/11/05.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import UIKit

final class MusicPlayerTransitionAnimation : TransitionAnimatable
{
    var rootVC:TabBarViewController!
    var modalVC:ModalViewController!
    var completion:((Bool)->Void)?
    var miniPlayerStartFrame:CGRect
    var tabBarStartFrame:CGRect
    var containerView:UIView?
    
    func sourceVC()->UIViewController
    {
        return rootVC
    }
    
    func destVC()->UIViewController
    {
        return modalVC
    }
    
    init(rootVC:TabBarViewController, modalVC:ModalViewController)
    {
        self.rootVC=rootVC
        self.modalVC=modalVC
        
        miniPlayerStartFrame=rootVC.miniPlayerView.frame
        tabBarStartFrame=rootVC.vtabBar.frame
    }
    
    func prepareContainer(transitionType:TransitionType, containerView:UIView, from fromVC:UIViewController, to toVC:UIViewController)
    {
        self.containerView=containerView
        
        rootVC.view.insertSubview(modalVC.view, belowSubview:rootVC.vtabBar)
        
        rootVC.view.setNeedsLayout()
        rootVC.view.layoutIfNeeded()
        modalVC.view.setNeedsLayout()
        modalVC.view.layoutIfNeeded()
    }
    
    func willAnimation(transitionType:TransitionType, containerView:UIView)
    {
        rootVC.beginAppearanceTransition(true, animated:false)
        
        if transitionType.isPresenting
        {
            modalVC.view.frame.origin.y=rootVC.miniPlayerView.frame.origin.y
        }
        else
        {
            rootVC.miniPlayerView.alpha=1
            rootVC.miniPlayerView.frame.origin.y = -rootVC.miniPlayerView.bounds.size.height
            rootVC.vtabBar.frame.origin.y=containerView.bounds.size.height
        }
    }
    
    func updateAnimation(transitionType:TransitionType, percentComplete:CGFloat)
    {
        if transitionType.isPresenting
        {
            let startOriginY=miniPlayerStartFrame.origin.y
            
            let tabStartOriginY=tabBarStartFrame.origin.y
            let tabEndOriginY=modalVC.view.frame.size.height
            let tabDiff=tabEndOriginY-tabStartOriginY
            
            let playerY=startOriginY-(startOriginY*percentComplete)
            rootVC.miniPlayerView.frame.origin.y=min(playerY, startOriginY)
            modalVC.view.frame.origin.y=min(playerY, startOriginY)
            
            let tabY=tabStartOriginY+(tabDiff*percentComplete)
            rootVC.vtabBar.frame.origin.y=max(tabY, tabStartOriginY)
            
            let alpha=1.0-(1.0*percentComplete)
            rootVC.vtabBar.alpha=alpha
            rootVC.miniPlayerView.subviews.forEach{$0.alpha=alpha}
        }
        else
        {
            let startOriginY = -rootVC.miniPlayerView.bounds.size.height
            let endOriginY=miniPlayerStartFrame.origin.y
            let diff = -startOriginY+endOriginY
            
            let tabStartOriginY=modalVC.view.frame.size.height
            let tabEndOriginY=tabBarStartFrame.origin.y
            let tabDiff=tabStartOriginY-tabEndOriginY
            
            rootVC.miniPlayerView.frame.origin.y=startOriginY+(diff*percentComplete)
            modalVC.view.frame.origin.y=rootVC.miniPlayerView.frame.origin.y+rootVC.miniPlayerView.frame.size.height
            
            rootVC.vtabBar.frame.origin.y=tabStartOriginY-(tabDiff*percentComplete)
            
            let alpha=percentComplete
            rootVC.vtabBar.alpha=alpha
            rootVC.miniPlayerView.alpha=1
            rootVC.miniPlayerView.subviews.forEach{$0.alpha=alpha}
        }
    }
    
    func finishAnimation(transitionType:TransitionType, didComplete:Bool)
    {
        rootVC.endAppearanceTransition()
        
        if transitionType.isPresenting
        {
            if didComplete
            {
                rootVC.miniPlayerView.alpha=0
                modalVC.view.removeFromSuperview()
                containerView?.addSubview(modalVC.view)
                
                completion?(transitionType.isPresenting)
            }
            else
            {
                rootVC.beginAppearanceTransition(true, animated:false)
                rootVC.endAppearanceTransition()
            }
        }
        else
        {
            if didComplete
            {
                modalVC.view.removeFromSuperview()
                completion?(transitionType.isPresenting)
            }
            else
            {
                rootVC.miniPlayerView.alpha=0
                modalVC.view.removeFromSuperview()
                containerView?.addSubview(modalVC.view)
                
                rootVC.beginAppearanceTransition(false, animated:false)
                rootVC.endAppearanceTransition()
            }
        }
    }
}
