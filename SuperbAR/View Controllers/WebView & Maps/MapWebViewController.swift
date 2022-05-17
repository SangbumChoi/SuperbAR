//
//  MapWebiewController.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 12/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit
import WebKit

class MapWebViewController: UIViewController {
    
    var isWebsite = true
    
    //---------------
    //MARK: - WebView
    //---------------
    var webView: WKWebView?
    var webAddress: String!
    
    
    //----------------------
    //MARK: - ViewLife Cycle
    //----------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
      
        if isWebsite{
            print("test")
            setupWebView()
        }
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView?.removeFromSuperview()
    }
    
    //---------------------
    //MARK: - Website Setup
    //---------------------
    
    private func setupWebView(){
        
        //1. Setup The WebView
        webView = WKWebView(frame: self.view.bounds)
        self.view.addSubview(webView!)
        webAddress = "https://www.google.co.kr"
        print(webAddress)

        //2. Load The URL
        guard let webURL = URL(string: webAddress) else { return }
        print(webURL)
        let request = URLRequest(url: webURL)
        print(request)
        webView?.load(request)
    }
}



