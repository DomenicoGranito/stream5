//
//  LoginViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LoginViewController: BaseViewController
{
    @IBOutlet var usernameTxt:UITextField?
    @IBOutlet var passwordTxt:UITextField?
    @IBOutlet var usernameImageView:UIImageView?
    @IBOutlet var passwordImageView:UIImageView?
    @IBOutlet var usernameBackgroundView:UIView?
    @IBOutlet var passwordBackgroundView:UIView?
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var username:String!
    var password:String!
    var email:String!
    let (appID, appSecret)=Config.shared.weChat()
    
    func buildAccessTokenLink(code:String)->String
    {
        return "oauth2/access_token?appid="+appID+"&secret="+appSecret+"&code="+code+"&grant_type=authorization_code"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        WXApi.registerApp(appID)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(onResp), name:"getCode", object:nil)
        
        usernameImageView?.image=usernameImageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        passwordImageView?.image=passwordImageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        usernameImageView?.tintColor=UIColor.darkGrayColor()
        passwordImageView?.tintColor=UIColor.darkGrayColor()
        
        if let _=A0SimpleKeychain().stringForKey("PHPSESSID")
        {
            UserConnector().get(nil, success:successUser, failure:forgotFailure)
            
            let vc=storyBoard.instantiateViewControllerWithIdentifier("RootViewControllerId")
            navigationController?.pushViewController(vc, animated:false)
        }
    }
    
    @IBAction func wechatLogin()
    {
        if(WXApi.isWXAppInstalled())
        {
            let req=SendAuthReq()
            req.scope="snsapi_userinfo"
            req.state="123"
            
            WXApi.sendReq(req)
        }
        else
        {
            SCLAlertView().showSuccess("MESSAGE", subTitle:"Please install WeChat application")
        }
    }
    
    func onResp(notification:NSNotification)
    {
        let code=notification.object as! String
        
        let accessTokenLinkString=buildAccessTokenLink(code)
        UserConnector().getWeChatAccessToken(accessTokenLinkString, success:successAccessToken, failure:forgotFailure)
    }
    
    func successAccessToken(data:NSDictionary)
    {
        let accessToken=data["access_token"] as! String
        let openID=data["openid"] as! String
        
        let userProfileLinkString="userinfo?access_token="+accessToken+"&openid="+openID
        UserConnector().getWeChatUserProfile(userProfileLinkString, success:successUserProfile, failure:forgotFailure)
    }
    
    func successUserProfile(data:NSDictionary)
    {
        username=data["openid"] as! String
        password="beinitpass"
        email=username+"@WeChat.com"
        
        signupWithBEINIT()
    }
    
    func signupWithBEINIT()
    {
        let loginData=NSMutableDictionary()
        
        loginData["id"]=email
        loginData["username"]=username
        loginData["password"]=password
        loginData["token"]="1"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(email, forKey:"id")
        A0SimpleKeychain().setString(password, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        
        if let deviceToken=(UIApplication.sharedApplication().delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        UserConnector().login(loginData, success:loginSuccess, failure:signupFailure)
    }
    
    func signupFailure(error:NSError)
    {
        let errorMessage=error.userInfo[NSLocalizedDescriptionKey] as! String
        
        if errorMessage=="Username is already taken."
        {
            loginWithBEINIT()
        }
    }
    
    func loginWithBEINIT()
    {
        let loginData=NSMutableDictionary()
        
        loginData["id"]=username
        loginData["password"]=password
        loginData["token"]="2"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(username, forKey:"id")
        A0SimpleKeychain().setString(password, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        
        if let deviceToken=(UIApplication.sharedApplication().delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        UserConnector().login(loginData, success:loginSuccess, failure:forgotFailure)
    }
    
    @IBAction func login()
    {
        username=usernameTxt!.text!
        password=passwordTxt!.text!
        
        loginWithBEINIT()
    }
    
    func loginSuccess(session:String)
    {
        A0SimpleKeychain().setString(session, forKey:"PHPSESSID")
        
        UserConnector().get(nil, success:successUser, failure:forgotFailure)
        
        let vc=storyBoard.instantiateViewControllerWithIdentifier("RootViewControllerId")
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func successUser(user:User)
    {
        UserContainer.shared.setLogged(user)
    }
    
    @IBAction func forgotPassword()
    {
        if(usernameTxt?.text=="")
        {
            UIAlertView.notAuthorizedAlert("Please enter your username").show()
        }
        else
        {
            UserConnector().forgot(username, success:forgotSuccess, failure:forgotFailure)
        }
    }
    
    func forgotSuccess()
    {
        UIAlertView.notAuthorizedAlert("Password reset").show()
    }
    
    func forgotFailure(error:NSError)
    {
        handleError(error)
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField:UITextField)->Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField:UITextField)->Bool
    {
        if(textField==usernameTxt)
        {
            usernameBackgroundView?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            passwordBackgroundView?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            usernameImageView?.tintColor=UIColor.whiteColor()
            passwordImageView?.tintColor=UIColor.darkGrayColor()
        }
        else
        {
            passwordBackgroundView?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            usernameBackgroundView?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            usernameImageView?.tintColor=UIColor.darkGrayColor()
            passwordImageView?.tintColor=UIColor.whiteColor()
        }
        
        return true
    }
}
