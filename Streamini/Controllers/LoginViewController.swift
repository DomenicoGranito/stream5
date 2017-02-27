//
//  LoginViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LoginViewController: BaseViewController, WXApiDelegate
{
    @IBOutlet var usernameTxt:UITextField?
    @IBOutlet var passwordTxt:UITextField?
    @IBOutlet var usernameImageView:UIImageView?
    @IBOutlet var passwordImageView:UIImageView?
    @IBOutlet var usernameBackgroundView:UIView?
    @IBOutlet var passwordBackgroundView:UIView?
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    let appID="wxa0bd27aed1120e15"
    let appSecret="0b816cd869076add75641aa53a9479e1"
    let accessTokenPrefix="https://api.weixin.qq.com/sns/oauth2/access_token?"
    
    func buildAccessTokenLink(code:String)->String
    {
        return accessTokenPrefix+"appid="+appID+"&secret="+appSecret+"&code="+code+"&grant_type=authorization_code"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        WXApi.registerApp(appID)
        
        if(WXApi.isWXAppInstalled())
        {
            let req=SendAuthReq()
            req.scope="snsapi_userinfo"
            req.state="123"
            
            WXApi.sendReq(req)
        }
        else
        {
            let alert=SCLAlertView()
            alert.showSuccess("MESSAGE", subTitle:"Please install WeChat application")
        }
    }
    
    func onResp(resp:BaseResp)
    {
        if let authResp=resp as? SendAuthResp
        {
            if authResp.code != nil
            {
                let accessTokenLinkString=buildAccessTokenLink(authResp.code)
                UserConnector().getWeChatAccessToken(accessTokenLinkString, success:successAccessToken, failure:forgotFailure)
            }
            else
            {
                errorAlert()
            }
        }
        else
        {
            errorAlert()
        }
    }
    
    func successAccessToken(data:NSDictionary)
    {
        
    }
    
    func errorAlert()
    {
        let alert=SCLAlertView()
        alert.showSuccess("ERROR", subTitle:"Failed to get response")
    }
    
    @IBAction func login()
    {
        let loginData=NSMutableDictionary()
        
        loginData["id"]=usernameTxt!.text!
        loginData["password"]=passwordTxt!.text!
        loginData["token"]="2"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(usernameTxt!.text!, forKey:"id")
        A0SimpleKeychain().setString(passwordTxt!.text!, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        
        if let deviceToken=(UIApplication.sharedApplication().delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        let connector=UserConnector()
        connector.login(loginData, success:loginSuccess, failure:forgotFailure)
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
            let alertView=UIAlertView.notAuthorizedAlert("Please enter your username")
            alertView.show()
        }
        else
        {
            let connector=UserConnector()
            connector.forgot(usernameTxt!.text!, success:forgotSuccess, failure:forgotFailure)
        }
    }
    
    func forgotSuccess()
    {
        let alertView=UIAlertView.notAuthorizedAlert("Password reset")
        alertView.show()
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
