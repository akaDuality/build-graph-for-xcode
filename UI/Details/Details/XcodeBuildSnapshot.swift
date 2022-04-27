//
//  XcodeBuildSnapshot.swift
//  Details
//
//  Created by Mikhail Rubanov on 27.04.2022.
//

import Foundation
import BuildParser
import AppKit

// https://www.raywenderlich.com/5244-document-based-apps-tutorial-getting-started
// https://www.raywenderlich.com/1809473-uidocument-from-scratch
// http://paulsolt.com/blog/2012/02/creating-nsdocument-using-folder-bundles-and-uti-identifiers
// https://nshipster.com/filemanager/
// https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileWrappers/FileWrappers.html#//apple_ref/doc/uid/TP40010672-CH13-DontLinkElementID_10
// https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html#//apple_ref/doc/uid/10000123i-CH106

public class XcodeBuildSnapshot: NSDocument {
    public init(project: ProjectReference) {
        self.project = project
        self.rootPath = project.rootPath
    }
    
    public init(url: URL) throws {
        self.rootPath = url
        
        super.init()
        
        try read(from: url, ofType: Self.bgbuildsnapshot)
//        let fileWrapper = try! FileWrapper(url: url)
//        try read(from: fileWrapper, ofType: Self.bgbuildsnapshot)
    }
    
    private let rootPath: URL
    public var project: ProjectReference!
    
    public static let bgbuildsnapshot = "bgbuildsnapshot"

    let fileManager = FileManager.default
    public override func write(to rootUrl: URL, ofType typeName: String) throws {
        let derivedData = FileAccess().accessedDerivedDataURL()
        let _ = derivedData?.startAccessingSecurityScopedResource()
        defer {
            derivedData?.stopAccessingSecurityScopedResource()
        }
        
        let newFolder = activityLogFolder(rootUrl: rootUrl)
        let newFile = newFolder.appendingPathComponent(project.currentActivityLog.lastPathComponent)
        
        // TODO: Remove !
        try! fileManager.createDirectory(
            at: newFolder,
            withIntermediateDirectories: true,
            attributes: nil)
        try! fileManager.copyItem(
            at: project.currentActivityLog,
            to: newFile)
    }
    
    public override func read(from url: URL, ofType typeName: String) throws {
        self.project = ProjectReferenceFactory().projectReference(folder: url)
        
    }
    
    private func activityLogFolder(rootUrl: URL) -> URL {
        rootUrl
            .appendingPathComponent("Logs")
            .appendingPathComponent("Build")
    }
}

//    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
//        let derivedData = FileAccess().accessedDerivedDataURL()
//        let _ = derivedData?.startAccessingSecurityScopedResource()
//        defer {
//            derivedData?.stopAccessingSecurityScopedResource()
//        }
//
//        let activityLog = try FileWrapper(regularFileWithContents: Data(contentsOf: project.currentActivityLog))
//        let dependencies = try FileWrapper(regularFileWithContents: Data(contentsOf: project.depsURL!))
//
//        let wrapper = FileWrapper(directoryWithFileWrappers: [
//            "Logs": FileWrapper(
//                directoryWithFileWrappers:
//                    ["Build": FileWrapper(
//                        directoryWithFileWrappers: [project.currentActivityLog.lastPathComponent: activityLog])]),
//            "Build": FileWrapper(
//                directoryWithFileWrappers:
//                    ["Intermediates.noindex" : FileWrapper(
//                        directoryWithFileWrappers:
//                            ["XCBuildData": FileWrapper(
//                                directoryWithFileWrappers: [project.depsURL!.lastPathComponent: dependencies])])])
//            ,
//        ])
//
//        return wrapper
//    }
//
//    public override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
//        // TODO: Read correctly
//        let wrappers = fileWrapper.fileWrappers!
//
//        let activityLog = wrappers.first(where: { wrapper in
//            wrapper.value.filename!.hasSuffix("xcactivitylog")
//        })!.value.filename!
//        let dependencies = wrappers.first(where: { wrapper in
//            wrapper.value.filename!.hasSuffix("txt")
//        })!.value.filename!
//
//        self.project = ProjectReferenceFactory()
//            .projectReference(
//                activityLogURL: rootPath.appendingPathComponent(activityLog),
//                accessedDerivedDataURL: rootPath.appendingPathComponent(dependencies))
//
//    }

