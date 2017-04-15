//
//  LegalViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 17/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

enum LegalViewControllerType
{
    case TermsOfService
    case PrivacyPolicy
}

class LegalViewController: BaseViewController, UIWebViewDelegate
{
    @IBOutlet weak var webView: UIWebView!
    var type: LegalViewControllerType?
    
    override func viewDidLoad()
    {
        let urlString: String
        switch type!
        {
        case .TermsOfService:
            urlString = Config.shared.legal().termsOfService
            self.title = NSLocalizedString("profile_terms", comment: "")
        case .PrivacyPolicy:
            urlString = Config.shared.legal().privacyPolicy
            self.title = NSLocalizedString("profile_privacy", comment: "")
        }
        
        webView.loadRequest(NSURLRequest(URL:NSURL(string:urlString)!))
    }
    
    func webView(webView:UIWebView, shouldStartLoadWithRequest request:NSURLRequest, navigationType:UIWebViewNavigationType)->Bool
    {
        if navigationType == .LinkClicked
        {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        return true
    }
}
