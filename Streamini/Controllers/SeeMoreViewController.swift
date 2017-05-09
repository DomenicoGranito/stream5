//
//  SeeMoreViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeeMoreViewController: UIViewController
{
    var t:String!
    var q:String!
    
    override func viewDidLoad()
    {
        self.title = t.capitalizedString
        navigationController?.navigationBarHidden=false
    }
}
