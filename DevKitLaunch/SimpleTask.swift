//
//  SimpleTask.swift
//  DevKitLaunch
//
//  Created by Franck Brun on 29/08/2016.
//  Copyright © 2016 Franck Brun. All rights reserved.
//

import Foundation

class SimpleTask {

  var taskName = ""
  var execPath = ""
  var workPath = ""
  var args = [String]()
  
  init(taskName: String, execPath: String, workPath: String, args: [String]?) {
    self.taskName = taskName
    self.execPath = execPath
    self.workPath = workPath
    self.args.removeAll()
    if let validArgs = args {
      self.args.appendContentsOf(validArgs)
    }
  }

  func result() -> String? {
    
    let pipe = NSPipe()
    let file = pipe.fileHandleForReading
  
    let task = NSTask()
    task.launchPath = execPath
    if workPath != "" {
      task.currentDirectoryPath = workPath
    }
    task.arguments = args
    task.standardOutput = pipe
    
    task.launch()
    
    let data = file.readDataToEndOfFile()
    file.closeFile()
    
    return String(data: data, encoding: NSUTF8StringEncoding)
  }
  
}