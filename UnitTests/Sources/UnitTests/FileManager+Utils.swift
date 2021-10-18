import Foundation

extension FileManager {
    
    /// Определяет признак директории по пути
    /// - Parameter path: Путь в файловой системе
    /// - Returns: Признак директории
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return fileExists && isDirectory.boolValue
    }
    
    /// Сортирует список путей файлов по дате создания от старых к свежим
    /// - Parameter paths: Массив путей файлов для сортировки
    /// - Returns: Сортированный массив
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
    
    
    /// Ищет файлы конкретного расширения
    /// - Parameters:
    ///   - url: Директория для поиска
    ///   - fileExtension: Расширение файла
    ///   - isRecursively: false - ищет только в папке на первом уровне, true - перебирает все подпапки
    /// - Returns: Массив путей найденных файлов
    func findInDirectory(url: URL, by fileExtension: String, isRecursively: Bool = true) throws -> [URL] {
        let contentsOfDirectory = try contentsOfDirectory(atPath: url.path)
        var foundURLs = [URL]()
        
        for item in contentsOfDirectory {
            let subPath = url.appendingPathComponent(item)
            
            if subPath.pathExtension.lowercased().hasSuffix(fileExtension) {
                foundURLs.append(subPath)
            } else {
                if isDirectory(path: subPath.path), isRecursively {
                    let urls = try findInDirectory(url: subPath, by: fileExtension, isRecursively: true)
                    foundURLs.append(contentsOf: urls)
                }
            }
        }
        
        return try sortByCreateDate(paths: foundURLs)
    }
}
