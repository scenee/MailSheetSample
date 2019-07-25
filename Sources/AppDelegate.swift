//
//  AppDelegate.swift
//  SheetModalSample
//
//  Created by Shin Yamamoto on 2019/07/16.
//  Copyright © 2019 Shin Yamamoto. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}

