import Foundation
import FileAnalyzer

/// Структура для доступа к настройкам Xcode проекта
public struct BuildSettingsParser {
    fileprivate(set) var settings: BuildSettingsModel?
    
    private var projectFileURL: URL?
    private let xCodeProjectFileExt = "xcodeproj"
    
    /// Стандартная инициализация
    /// - Parameter projectURL: Путь до папки с проектом (с файлом xcodeproj)
    public init(projectURL: URL) {
        if projectURL.path.lowercased().hasSuffix(xCodeProjectFileExt) {
            self.projectFileURL = projectURL
        } else if let foundProjectFile = self.findXCodeProjectFile(folderURL: projectURL) {
            self.projectFileURL = foundProjectFile
        } else {
            fatalError("Wrong XCode project file URL (or file not found in folder (\(projectURL)")
        }
        
        let settingsString = shell("xcodebuild -project \(projectFileURL!.path) -showBuildSettings")
        
        let arrayOfSettings = settingsString.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.contains("=") }
            
        let arrayOfSettingPairs = arrayOfSettings
            .map { $0.split(separator: "=")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            }

        var dict = [String: String]()
        for pair in arrayOfSettingPairs {
            if pair.count == 2 {
                dict[pair[0]] = pair[1]
            }
        }
        
        settings = BuildSettingsModel(raw: dict)
    }
    
    private func findXCodeProjectFile(folderURL: URL) -> URL? {
        let foundResults = try? FileManager.default.findInDirectory(url: folderURL, by: "xcodeproj", isRecursively: false)
        return foundResults?.first
    }
}
