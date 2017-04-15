//
//  SubscriptionVewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 8/2/2017.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

class SubscriptionViewController: UITableViewController
{
    var profileDelegate: ProfileDelegate?
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if let sid = segue.identifier
        {
            if sid=="ProfileToLegal"
            {
                let controller = segue.destinationViewController as! LegalViewController
                let index = (sender as! NSIndexPath).row
                controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }
            
            if sid=="ProfileToProfileStatistics"
            {
                let controller = segue.destinationViewController as! ProfileStatisticsViewController
                let index = (sender as! NSIndexPath).row
                controller.type = ProfileStatisticsType(rawValue: index)!
               // controller.profileDelegate = self
            }
        }
    }
}
