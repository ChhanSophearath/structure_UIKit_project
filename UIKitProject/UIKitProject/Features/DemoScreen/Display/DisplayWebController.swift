//
//  DisplayWebController.swift
//  UIKitProject
//
//  Created by Rath! on 24/12/24.
//

import UIKit
import WebKit

class DisplayWebController: BaseUIViewConroller {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title  = "Loading WebView"
//        warmUpWebView()
        
        Loading.shared.showLoading()
        // Create the WKWebView instance
        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        self.view.addSubview(webView)

        // Or load generated HTML with CSS
        let stringHTML = "<h1>Hello World</h1><p>My name is Dara. I am a student. Every morning, I wake up at 6 o’clock. I wash my face, brush my teeth, and eat breakfast. After that, I go to school. At school, I study many subjects like English, math, and science. I like English because it is fun to learn new words. At lunchtime, I eat rice with my friends. We talk and laugh together. In the afternoon, I go back home. I help my mother with housework and sometimes I play football with my friends. In the evening, I do my homework. After dinner, I watch TV for a short time. Finally, I go to bed at 10 o’clock. I am happy every day because I learn new things and spend time with my family.</p>"
        
        webView.loadHTMLStringCustom(description: stringHTML)
    }
    
  
}

// Delegate
extension DisplayWebController: WKNavigationDelegate{
    
    /// Called when web content finishes loading
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading HTML successfully!")
            Loading.shared.hideLoading()
            // You can also show an alert, activity indicator stop, or other UI updates here
        }
        
        /// Called if web content fails to load
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed to load HTML: \(error.localizedDescription)")
            Loading.shared.hideLoading()
        }
        
        /// Called if web content fails during provisional load
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed provisional navigation: \(error.localizedDescription)")
            Loading.shared.hideLoading()
        }
}
