//
//  OutlookWebViewController.swift
//  wkwebview
//

import UIKit
import WebKit

protocol OutlookWebViewControllerDelegate: class {
    func outlookWebViewController(_ outlookWebViewController: OutlookWebViewController, authenticationCode: String, redirectUri url: String)
}

class OutlookWebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    var redirectUri: String = Strings.redirectUrl
    weak var delegate: OutlookWebViewControllerDelegate?
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initializeView() {
        self.showActivityindicator()
        WKWebView.clean()
        self.webView.navigationDelegate = self
        guard let endcodeRedirectUri = self.redirectUri.encodeUrl() else {
            return
        }
        let url = URL(string: "\(ServiceData.outlookWebAuthorize)?client_id=\(ConfigureKeys.outlookClientId)&response_type=code&redirect_uri=\(endcodeRedirectUri)&response_mode=query&scope=User.Read+Calendars.Read+Calendars.ReadWrite+offline_access&state=12345")!
        self.webView.load(URLRequest(url: url))
        self.webView.allowsBackForwardNavigationGestures = true
    }
    
    func showActivityindicator() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideActivityindicator() {
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if(navigationAction.navigationType == .formSubmitted) {
            if let url = navigationAction.request.url, url.absoluteString.contains(self.redirectUri), let params = url.queryParameters, let code = params["code"] {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.outlookWebViewController(self, authenticationCode: code, redirectUri: redirectUri)
            }
            decisionHandler(.allow)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideActivityindicator()
    }


}

extension WKWebView {
    
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
    
}
