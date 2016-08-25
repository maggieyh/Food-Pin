//
//  WebViewController.swift
//  FoodPin_2
//
//  Created by yao  on 6/4/16.
//  Copyright © 2016 yao . All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let url = NSURL(string: "http://www.appcoda.com/contact") {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request);
        }
//        OR us local html
//        if let url = NSURL(fileURLWithPath: "about.html") {
//        let request = NSURLRequest(URL: url)
//        webView.loadRequest(request)
//    }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
