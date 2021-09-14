import Foundation

extension FileManager {
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return fileExists && isDirectory.boolValue
    }
    
    func sortByCreateDate(paths: [URL]) throws -> [URL] {
        var pathsWithDate = [(path: URL, creationDate: Date)]()
        for path in paths {
            let attributes = try attributesOfItem(atPath: path.path)
            if let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                pathsWithDate.append((path, creationDate))
            }
        }
        
        return pathsWithDate.sorted { $0.creationDate < $1.creationDate }
            .map { $0.path }
    }
    
    func findInDirectory(url: URL, by suffix: String, isRecursively: Bool = true) throws -> [URL] {
        let contentsOfDirectory = try contentsOfDirectory(atPath: url.path)
        var foundURLs = [URL]()
        
        for item in contentsOfDirectory {
            let subPath = url.appendingPathComponent(item)
            
            if subPath.pathExtension.lowercased().hasSuffix(suffix) {
                foundURLs.append(subPath)
            } else {
                if isDirectory(path: subPath.path), isRecursively {
                    let urls = try findInDirectory(url: subPath, by: suffix, isRecursively: true)
                    foundURLs.append(contentsOf: urls)
                }
            }
        }
        
        return foundURLs
    }
}
