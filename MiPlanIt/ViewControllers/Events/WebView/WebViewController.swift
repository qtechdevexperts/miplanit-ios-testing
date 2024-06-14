//
//  WebViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewTopColorHeader: UIView!
    @IBOutlet weak var viewTopNonColorHeader: UIView!
    @IBOutlet weak var viewTopBarGradient: UIView!
    
    var htmlString: String! = Strings.empty

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadHTMLStringImage()
    }
    
    func loadHTMLStringImage() -> Void {
        self.viewTopColorHeader.isHidden = self.navigationController == nil
        self.viewTopNonColorHeader.isHidden = self.navigationController != nil
        self.viewTopBarGradient.isHidden = self.navigationController == nil
        self.webView.navigationDelegate = self
        self.activityIndicator.startAnimating()
        self.webView.loadHTMLString(self.htmlString, baseURL: nil)
    }
}


extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
    }
}
