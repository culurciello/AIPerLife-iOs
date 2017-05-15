//
//  AppDelegate.swift
//  AIperLife-iOs
//
//  Created by Eugenio Culurciello on 2/17/17.
//  Copyright © 2017 Eugenio Culurciello. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let mainColor = UIColor(red: 74/255, green: 189/255, blue: 172/255, alpha: 1)
    let verColor = UIColor(red: 252/255, green: 74/255, blue: 26/255, alpha: 1)
    let sunColor = UIColor(red: 247/255, green: 183/255, blue: 51/255, alpha: 1)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = mainColor
        self.window!.makeKeyAndVisible()
        
        let main: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = main.instantiateViewController(withIdentifier: "navigationController") 
        self.window!.rootViewController = nav
        
        nav.view.layer.mask = CALayer()
        nav.view.layer.mask?.contents = UIImage(named: "Logo_cube_white")!.cgImage
        nav.view.layer.mask?.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        nav.view.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        nav.view.layer.mask?.position = CGPoint(x: nav.view.frame.width/2, y: nav.view.frame.height/2)
        
        let maskView = UIView(frame: nav.view.frame)
        maskView.backgroundColor = UIColor.white
        nav.view.addSubview(maskView)
        nav.view.bringSubview(toFront: maskView)
        
        let loadAnimation = CAKeyframeAnimation(keyPath: "bounds")
        loadAnimation.duration = 1.5
        
        let initial = NSValue(cgRect: (nav.view.layer.mask?.bounds)!)
        let decrease = NSValue(cgRect: CGRect(x: 0, y: 0, width: 80, height: 80))
        let increase = NSValue(cgRect: CGRect(x: 0, y: 0, width: 4000, height: 4000))
        
        loadAnimation.values = [initial, decrease, increase]
        loadAnimation.keyTimes = [0, 0.3, 0.7]
        loadAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        loadAnimation.isRemovedOnCompletion = false
        loadAnimation.fillMode = kCAFillModeForwards
        nav.view.layer.mask?.add(loadAnimation, forKey: "maskAnimation")
        
        UIView.animate(withDuration: 0.1, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            maskView.alpha = 0
            
        }) { (true) in
            maskView.removeFromSuperview()
        }
        
        //Set up Navigation bar
        UINavigationBar.appearance().barTintColor = mainColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = verColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: verColor]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

