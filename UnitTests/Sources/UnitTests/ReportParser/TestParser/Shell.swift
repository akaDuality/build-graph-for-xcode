////
////  File.swift
////
////
////  Created by Mikhail Rubanov on 24.05.2021.
////
//
//import Foundation
//
//@discardableResult
//public func shell(_ args: String...) -> Int32 {
//    let task = Process()
//    task.launchPath = "/usr/bin/env"
//    task.arguments = args
//    if #available(macOS 10.13, *) {
////        task.currentDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
//    }
//
//    let pipe = Pipe()
//    task.standardOutput = pipe
//    task.standardError = pipe
//    task.launch()
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output = String(data: data, encoding: .utf8)
//
//    task.waitUntilExit()
//    return task.terminationStatus
//}
