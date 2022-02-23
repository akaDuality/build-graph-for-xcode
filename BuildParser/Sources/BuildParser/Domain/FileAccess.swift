//
//  FileAccess.swift
//  
//
//  Created by Mikhail Rubanov on 14.11.2021.
//

import Foundation
import AppKit
import XCLogParser

class BookmarkSaver {
    let userDefaults = UserDefaults.standard
    
    func saveDerivedDataBookmark(data: Data) {
        userDefaults.set(data, forKey: "derivedDataBookmark")
    }
    
    func derivedDataBookmark() -> Data? {
        userDefaults.value(forKey: "derivedDataBookmark") as? Data
    }
    
    // TODO: Union with UISettings
}

public protocol FileAccessProtocol {
    func accessedDerivedDataURL() -> URL?
}

public class FileAccess: FileAccessProtocol {
    
    public init() {}
    
    public func accessedDerivedDataURL() -> URL? {
        guard let previousSessionURLData = bookmarkSaver.derivedDataBookmark() else {
            return nil
        }
        
        let url = restoreFileAccess(with: previousSessionURLData)
        return url
    }
    
    func promptForWorkingDirectoryPermission(directoryURL: URL) throws -> URL? {
        // TODO: accessedDerivedDataURL can be different to directoryURL
        if let url = accessedDerivedDataURL() {
            print("Restore access to \(url)")
            return url
        }
        
        let url = try requestAccess(to: directoryURL)

        return url
    }
    
    public func requestAccess(to directoryURL: URL) throws -> URL {
        let url = try showUIAccess(directoryURL: directoryURL)
        try saveBookmarkData(for: url)
        return url
    }
    
    private func showUIAccess(directoryURL: URL) throws -> URL {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = directoryURL
        openPanel.message = NSLocalizedString(
            "Choose your derived data directory",
            comment: "Open file dialog subtitle")
        openPanel.prompt = NSLocalizedString(
            "Choose",
            comment: "Open file dialog action button")
        
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        _ = openPanel.runModal()
        
        guard let url = openPanel.urls.first else {
            throw Error.noAccessFromUser
        }
        
        print("User grants access to \(url)")
        return url
    }
    
    let bookmarkSaver = BookmarkSaver()
    
    private func saveBookmarkData(for workDir: URL) throws {
        
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope,
                                                        includingResourceValuesForKeys: nil,
                                                        relativeTo: nil)
            bookmarkSaver.saveDerivedDataBookmark(data: bookmarkData)
        } catch let error {
            print("Failed to save bookmark data for \(workDir)", error)
            throw error
        }
    }
    
    private func restoreFileAccess(with bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                try saveBookmarkData(for: url)
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    enum Error: Swift.Error {
        case noAccessFromUser
    }
}
