//
//  ViewController.swift
//  CovidCheck
//
//  Created by user178672 on 7/30/20.
//  Copyright © 2020 user178672. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        //Checking hardware permissions
//        self.checkCameraAccess()
//        self.checkMicrophoneAccess()
        
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        // register the bridge script that listens for the output
        webView.configuration.userContentController.add(self, name: "logHandler")
        
        
//        webView.navigationDelegate = self
//        //old url = let url = URL(string: "https://covidsafecheck-test.montefiore.org")
//        let url = URL(string: "https://safecheckfrontend.z13.web.core.windows.net/")
//        //let url = URL(string: "http://localhost:8080/Covid-19_test.php")
//
//        let urlRequest = URLRequest(url: url!)
//        // enable JS
//        //webView.configuration.preferences.javaScriptEnabled = true
//        webView.load(urlRequest)
        
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.ignoresViewportScaleLimits = true
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.allowsPictureInPictureMediaPlayback = false

        webConfiguration.mediaTypesRequiringUserActionForPlayback = .all


//        webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self

       // self.view = self.webView

      //Checking hardware permissions
      self.checkCameraAccess()
      self.checkMicrophoneAccess()

      webView.navigationDelegate = self

      let url = URL(string: "https://safecheckfrontend.z13.web.core.windows.net/")
      print(url?.path as Any)
      let urlRequest = URLRequest(url: url!)
      webView.configuration.preferences.javaScriptEnabled = true
      webView.load(urlRequest)
    }
    
    @objc(userContentController:didReceiveScriptMessage:) func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("LOG: \(message.body)")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          webView.evaluateJavaScript("your javascript string") { (value, error) in
              if let errorMessage = (error! as NSError).userInfo["WKJavaScriptExceptionMessage"] as? String {
                    print(errorMessage)
              }
          }
     }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url!)
        /*if let url = navigationAction.request.url, url.absoluteString.contains("pass_test"){
            //print(getQueryStringParameter(url: url.absoluteString, param: "reload"))
            if let reload = getQueryStringParameter(url: url.absoluteString, param: "reload"),
            !reload.isEmpty {
                
            }else{
                let result = URL(string: url.absoluteString + "&reload=false")
                webView.load(URLRequest(url: result!))
            }

        }*/
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix("covidsafecheck.montefiore.org"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
		            print("not a user click")
            decisionHandler(.allow)
        }
    }
    
    
    //Camera request and permission check
    func checkCameraAccess() {
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                } else {
                    //access denied
                    print("not granted")
                    DispatchQueue.main.async {

                    let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use the features of this app", preferredStyle: .alert)

                           // Add "OK" Button to alert, pressing it will bring you to the settings app
                           alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { action in
                               UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                           }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                            self.dismiss(animated: true)
                        }))
                           // Show the alert with animation
                    self.present(alert, animated: true)
                    }
                }
            })
        }
    }
    
    //Microphone request and persmission check
    func checkMicrophoneAccess() {
        
        let session = AVAudioSession.sharedInstance()
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                } else {
                    print("not granted")
                    DispatchQueue.main.async {

                    let alert = UIAlertController(title: "Microphone", message: "Microphone access is absolutely necessary to use the features of this app", preferredStyle: .alert)

                           // Add "OK" Button to alert, pressing it will bring you to the settings app
                           alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { action in
                               UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                           }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                            self.dismiss(animated: true)
                        }))
                           // Show the alert with animation
                    self.present(alert, animated: true)
                    }
                }
            })
        }
    }
}

