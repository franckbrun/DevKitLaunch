//
//  AppDelegate.swift
//  DevKitLaunch
//
//  Created by Franck Brun on 29/08/2016.
//  Copyright © 2016 Franck Brun. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  static let DevKitLaunchDomain = "DevKitLaunch"

  static let ErrorJavaNotFoundMessage = "Unable to find java_home command"
  static let ErrorBadJavaVersionMessage = "Required Java Platform (JDK) version 1.7 or higher not found. Please install Java Platform (JDK) from http://www.oracle.com/technetwork/java/javase/downloads/index.html."
  static let ErrorBadPathMessage = "The Intel(R) IoT Developer Kit installation directory cannot have spaces in the path. Please make sure that the absolute path to the IoT Developer Kit installation does not contain spaces."
  static let ErrorEclipseNotFoundMessage = "Eclipse Not Found. Be sure to copying this application in the directory where eclipse-mac folder is."
  static let ErrorInternalMessage = "Internal error"
  static let ErrorPathNotFoundMessage = "Unable to find path :"
  
  let java_home_command = "/usr/libexec/java_home"
  
  var devkitHome = ""
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let fm = NSFileManager.defaultManager()
    
    // Search java_home
    if !fm.fileExistsAtPath(java_home_command) {
      presentErrorMessage(AppDelegate.ErrorJavaNotFoundMessage, code: -16)
      exit(0)
    }
    
    guard SimpleTask(taskName: "", execPath: java_home_command, workPath: "", args: ["-v", "1.7+", "-F"]).result() != nil else {
      presentErrorMessage(AppDelegate.ErrorInternalMessage, code: -14)
      exit(0)
    }
    
    guard let home = NSURL(string: Process.arguments[0])?.URLByDeletingLastPathComponent?.path else {
      presentErrorMessage(AppDelegate.ErrorBadJavaVersionMessage, code: -11)
      exit(0)
    }
    
    devkitHome = NSString(string: home + "../../../../").stringByStandardizingPath
    
    if !devkitHome.hasSuffix("/") {
      devkitHome = devkitHome + "/"
    }
    
    if !devkitHome.hasPrefix("/") || devkitHome.rangeOfString("") != nil {
      presentErrorMessage(AppDelegate.ErrorBadPathMessage, code: -13)
      exit(0)
    }
    
    // Search eclipse
    let eclipsePath = devkitHome + getPath("DevKitEclipsePath")
    
    if !fm.fileExistsAtPath(eclipsePath) {
      presentErrorMessage(AppDelegate.ErrorEclipseNotFoundMessage, code: -15)
      exit(0)
    }
    
    guard let path = String(UTF8String: getenv("PATH")) else {
      presentErrorMessage(AppDelegate.ErrorInternalMessage, code: -14)
      exit(0)
    }
    
    var finalPath = path
    if !path.hasSuffix(":") {
      finalPath = finalPath + ":"
    }
    finalPath = finalPath + devkitHome + getPath("DevKitSDKPath")
    finalPath = finalPath + ":" + devkitHome + getPath("DevKitDebuggerPath")
    
    let pokyHome = devkitHome + getPath("DevKitSysRootPath")
    
    
    let env = ["DEVKIT_HOME" : devkitHome, "PATH" : finalPath, "POKY_HOME" : pokyHome, "DEVKIT_LAUNCHER" : "OSX"]
    
    let wk = NSWorkspace.sharedWorkspace()
    let eclipseURL = NSURL(fileURLWithPath: eclipsePath)
    
    do {
      try wk.launchApplicationAtURL(eclipseURL, options: [.Default], configuration: [NSWorkspaceLaunchConfigurationEnvironment : env])
    } catch let error as NSError {
      NSApplication.sharedApplication().presentError(error)
    }
    
    exit(0)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }

  func presentErrorMessage(message: String, code: Int) {
    let dict = [NSLocalizedDescriptionKey : message]
    let error = NSError(domain: AppDelegate.DevKitLaunchDomain, code: code, userInfo: dict)
    NSApplication.sharedApplication().presentError(error)
  }
  
  func getPath(key: String) -> String {
    guard let dict = NSBundle.mainBundle().infoDictionary, let path = dict[key] as? String else {
      presentErrorMessage(AppDelegate.ErrorPathNotFoundMessage + "\(key)", code: -17)
      exit(0)
    }
    
    return path
  }
  
}

