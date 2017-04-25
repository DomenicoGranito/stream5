//
//  LinkedUserCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol LinkedUserCellDelegate:class
{
    func willStatusChanged(cell:UITableViewCell)
}

class LinkedUserCell: UITableViewCell
{
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var usernameLabel:UILabel!
    @IBOutlet var userStatusButton:SensibleButton!
    @IBOutlet var unblockButton:UIButton!
    
    var delegate:LinkedUserCellDelegate?
    var blockedView=false
    
    var isStatusOn=false
        {
        didSet
        {
            let image=isStatusOn ? UIImage(named:"checkmark") : UIImage(named:"plus")
            
            userStatusButton.setImage(image, forState:.Normal)
        }
    }
    
    func update(user:User)
    {
        usernameLabel.text=user.name
        userImageView.contentMode = .ScaleToFill
        userImageView.sd_setImageWithURL(user.avatarURL())
        
        userStatusButton.hidden=UserContainer.shared.logged().id==user.id
        unblockButton.hidden=UserContainer.shared.logged().id==user.id
        
        if blockedView
        {
            userStatusButton.hidden=true
            unblockButton.addTarget(self, action:#selector(statusButtonPressed), forControlEvents:.TouchUpInside)
        }
        else
        {
            unblockButton.hidden=true
            isStatusOn=user.isFollowed
            userStatusButton.addTarget(self, action:#selector(statusButtonPressed), forControlEvents:.TouchUpInside)
        }
    }
    
    func updateRecent(recent:Stream, isMyStream: Bool = false)
    {
        userImageView.contentMode = .Center
        
        if isMyStream
        {
            self.textLabel!.text = recent.title
        }
        else
        {
            usernameLabel.text      = recent.title
            userImageView.image     = UIImage(named:"play")
            userImageView.tintColor = UIColor.navigationBarColor()
            userStatusButton.hidden = true
        }
    }
    
    func statusButtonPressed()
    {
        if let del=delegate
        {
            del.willStatusChanged(self)
        }
    }
}
