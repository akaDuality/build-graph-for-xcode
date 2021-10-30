import Foundation

class BuildTimeParser {
    
    func parse(files: [String: String]) -> [Build] {
        var builds = [Build]()
        for (userName, file) in files {
            let buildFromFile = parse(file: file, userName: userName)
            builds.append(contentsOf: buildFromFile)
        }
        return builds
    }
    
    func parse(file: String, userName: String) -> [Build] {
        let buildStrings = file
            .components(separatedBy: "\n")
            .dropLast()
        
        return buildStrings.map { parse(line: $0, userName: userName) }
    }
    
    func parse(line: String, userName: String) -> Build {
        let parts = line.components(separatedBy: ",")
        
        var xcode: Build.Xcode?
        
        if let version = parts[safe: 5],
           let build = parts[safe: 6] {
            xcode = Build.Xcode(version: version,
                                build: build)
        }
        return Build(
            userName: userName,
            date: parts[0],
            duration: Int(parts[1])!,
            result: Build.Result(rawValue: parts[2])!,
            workspace: parts[3].removing(suffix: ".xcworkspace"),
            project: parts[4].removing(suffix: ".xcodeproj"),
            xcode: xcode)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        if (startIndex..<endIndex).contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}

extension Array where Element == Build {
    func number(of result: Build.Result) -> Int {
        self.filter{ $0.result == result }
        .count
    }
    
    func workspaces() -> [String] {
        let groups = Dictionary(grouping: self, by: \.workspace)
        
        var keys = [String]()
        for group in groups {
            keys.append(group.key)
        }
        return keys
    }
    
    func projects() -> [String] {
        let groups = Dictionary(grouping: self, by: \.project)
        
        var keys = [String]()
        for group in groups {
            keys.append(group.key)
        }
        return keys
    }
    
    func filterWorkspace(_ workspace: String) -> [Build] {
        filter { $0.workspace == workspace }
    }
    
    func summaryDuration(workspace: String) -> Int {
        filterWorkspace(workspace)
            .map(\.duration)
            .reduce(0, +)
    }
}

extension String {
    func removing(suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(self.dropLast(suffix.count))
        } else {
            return self
        }
    }
}
