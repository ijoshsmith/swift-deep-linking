//
//  AppDelegate.swift
//  DeepLinking
//
//  Created by Joshua Smith on 5/18/17.
//  Copyright © 2017 iJoshSmith. All rights reserved.
//

import UIKit

/*
 To try out the deep linking feature in this app:
 1) Run this app
 2) Open Safari on the device/simulator
 3) Enter one of these URLs into Safari's address bar:
    - demoapp://select/tab/1
    - demoapp://show/photo?name=dog
 4) Tap Go or press the Enter key in Safari
 5) This app becomes active and will navigate to the orange tab or a picture of a dog.
 
 Tip: Type Command+Shift+H to press the Home button in the simulator.
 */

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Handle the situation where the app is launched in response to a deep link.
        if let url = launchOptions?[.url] as? URL {
            return executeDeepLink(with: url)
        }
        else {
            return true
        }
    }
    
    func application(_: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return url.scheme == "demoapp" && executeDeepLink(with: url)
    }
    
    private func executeDeepLink(with url: URL) -> Bool {
        // Create a recognizer with this app's custom deep link types.
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [
            SelectTabDeepLink.self,
            ShowPhotoDeepLink.self])
        
        // Try to create a deep link object based on the URL.
        guard let deepLink = recognizer.deepLink(matching: url) else {
            print("Unable to match URL: \(url.absoluteString)")
            return false
        }
        
        // Navigate to the view or content specified by the deep link.
        switch deepLink {
        case let link as SelectTabDeepLink: return selectTab(with: link)
        case let link as ShowPhotoDeepLink: return showPhoto(with: link)
        default: fatalError("Unsupported DeepLink: \(type(of: deepLink))")
        }
    }
    
    private func selectTab(with deepLink: SelectTabDeepLink) -> Bool {
        guard let tabBarController = prepareTabBarController() else {
            return false
        }
        
        // Validate the tab index.
        guard let numberOfTabs = tabBarController.viewControllers?.count,
            deepLink.tabIndex < numberOfTabs,
            deepLink.tabIndex > -1
            else { return false }
        
        // Navigate to the specified tab.
        tabBarController.selectedIndex = deepLink.tabIndex
        return true
    }
    
    private func showPhoto(with deepLink: ShowPhotoDeepLink) -> Bool {
        guard let tabBarController = prepareTabBarController() else {
            return false
        }
        
        // Load an image from the bundle with the provided name.
        guard let image = UIImage(named: deepLink.imageName) else {
            print("There is no image named '\(deepLink.imageName)'")
            return false
        }
        
        // Navigate to the specified image.
        tabBarController.showPhoto(image: image, animated: false)
        return true
    }
    
    private func prepareTabBarController() -> DemoTabBarController? {
        guard let navController = window?.rootViewController as? UINavigationController else { return nil }
        guard let tabBarController = navController.viewControllers.first as? DemoTabBarController else { return nil }
        
        // If the tab bar controller is presenting a modal view controller, dismiss it immediately
        // so that the navigation performed in response to the deep link will be noticed/possible.
        if tabBarController.presentedViewController != nil {
            tabBarController.dismiss(animated: false, completion: nil)
        }
        
        return tabBarController
    }
    
}
