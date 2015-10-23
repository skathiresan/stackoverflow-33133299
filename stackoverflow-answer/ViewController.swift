//
//  ViewController.swift
//  stackoverflow-answer
//
//  Created by Subramanian Kathiresan on 10/23/15.
//  Copyright © 2015 Subbu. All rights reserved.
//

import UIKit

class ViewController: UIViewController,NSURLSessionDelegate,NSURLSessionTaskDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startConnection()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startConnection () {
        let END_POINT_URL = "http://sftp.dewdrive.com:80";
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config,delegate: self,delegateQueue: nil)

        let url = NSURL(string: END_POINT_URL)
        let task = session.dataTaskWithURL(url!) {
            (let data, let response, let error) in
            // data - nil, response - nil
        }
        
        task.resume()

    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        let authMethod = challenge.protectionSpace.authenticationMethod;
        
        if authMethod == NSURLAuthenticationMethodServerTrust {
            
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!);
            let disposition = NSURLSessionAuthChallengeDisposition.UseCredential;
            completionHandler(disposition,credential);
            
        } else if authMethod == NSURLAuthenticationMethodDefault || authMethod == NSURLAuthenticationMethodHTTPBasic  || authMethod == NSURLAuthenticationMethodNTLM {
            
            let server = challenge.protectionSpace.host;
            let alert = UIAlertController(title: "Authentication Required", message: "The Server \(server) requires username and password", preferredStyle: UIAlertControllerStyle.Alert);
            
            
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
                textField.placeholder = "User Name";
            })
            alert.addTextFieldWithConfigurationHandler({ (txtField) -> Void in
                txtField.placeholder = "Password";
                txtField.secureTextEntry = true;
            })
            
            alert.addAction(UIAlertAction(title: "Log In", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                let username = alert.textFields?.first?.text;
                let pwd = alert.textFields?.last?.text
                
                let credential = NSURLCredential(user: username!, password: pwd!, persistence:NSURLCredentialPersistence.ForSession);
                
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential);
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge,nil );
                
            }))
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                    
                });
                
            })
            
        }
    }
}

