import Foundation

/// Wrapper around shell command that prints line count for folder
class LineCount {
    
    func read() throws {
        let folders = try foldersService.folders()
        let stats = stats(from: folders)
        output(stats: stats)
    }
    
    private func stats(from folders: [URL]) -> Stats {
        var stats = [String: Int]()
        for folder in folders {
            let result = shell(shellCommand(path: folder.path))
            let lines = result.components(separatedBy: "\n")
            
            guard lines.count > 2 else {
                print("Skip \(folder)")
                continue
            }
            let total = lines[lines.count - 2]
            
            stats[folder.fileName] = total.digit
        }
        
        return stats
    }
    
    /// in format
    /// find . -name "*.swift" -print0 | xargs -0 wc -l
    private func shellCommand(path: String) -> String {
        "find \(path) -name \"*.\(fileExtension)\" -print0 | xargs -0 wc -l"
    }
    
    private func output(stats: Stats) {
        let total = stats.map { $0.value }.reduce(0, +)
        print("\n\(foldersService.folder.lastPathComponent): \(total)")
        stats.iterateAlphabetically { framework, linesCount in
            print("\(linesCount)    \(framework)")
        }
    }
    
    init(folder: URL, fileExtension: String = "swift") {
        self.foldersService = FoldersService(folder: folder)
        self.fileExtension = fileExtension
    }
    
    private let foldersService: FoldersService
    private let fileExtension: String
}

typealias Stats = [String: Int]
