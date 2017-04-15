//
//  PlaylistViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PlaylistViewController: ARNModalImageTransitionViewController, ARNImageTransitionZoomable
{
    @IBAction func tapCloseButton()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func createTransitionImageView()->UIImageView
    {
        return UIImageView()
    }
}
