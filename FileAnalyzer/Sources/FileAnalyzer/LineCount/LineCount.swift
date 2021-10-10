import Foundation

/// Wrapper around shell command that prints line count for folder
class LineCount {
    
    func read() throws {
        let folders = try foldersService.folders()
        let stats = stats(from: folders)
        outputAlphabetically(stats: stats)
    }
    
    func read(project: Project) throws {
        let folders = try foldersService.folders()
        let stats = stats(from: folders)
        output(stats: stats, project: project)
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
    
    private func outputAlphabetically(stats: Stats) {
        outputTotal(stats: stats)
        stats.iterateAlphabetically { framework, linesCount in
            print("\(linesCount), \(framework)")
        }
    }
    
    private func outputTotal(stats: Stats) {
        let total = stats.map { $0.value }.reduce(0, +)
        print("\n\(foldersService.folder.lastPathComponent): \(total)")
    }
    
    private func output(stats: Stats, project: Project) {
        outputTotal(stats: stats)
        
        var allModules = Array(stats.keys)
        
        for layer in project.layers {
            print("\nLayer \(layer.name)".capitalized)
            for module in layer.modules {
                guard let lines = stats[module] else {
                    print("skip \(module)")
                    continue
                }
                print("\(lines)\t\(module)")
                
                allModules.removeAll { name in
                    name == module
                }
            }
        }
        
        print("\nUnhandled \(allModules)")
        
//        stats.iterateAlphabetically { framework, linesCount in
//            print("\(linesCount), \(framework)")
//        }
    }
    
    init(folder: URL, fileExtension: String = "swift") {
        self.foldersService = FoldersService(folder: folder)
        self.fileExtension = fileExtension
    }
    
    private let foldersService: FoldersService
    private let fileExtension: String
}

typealias Stats = [String: Int]

struct Project {
    let layers: [Layer]
    
    struct Layer {
        let name: String
        let modules: [String]
    }
}

extension Project {
    static let pizza = Project(
        layers: [
            Project.Layer(name: "deps",
                          modules: [
                            "DMapKit",
                            "DynamicType",
                            "Kusto",
                            "Mindbox",
                            "Phone",
                            "hCaptcha",
                          ]),
            Project.Layer(name: "base",
                          modules: [
                            "DAnalytics",
                            "DataPersistence",
                            "DFoundation",
                            "DPushNotifications",
                            "DUIKit",
                            "Geolocation",
                            "ServicePush"
                          ]),
            Project.Layer(name: "domain",
                          modules: [
                            "State",
                            "MobileBackend",
                            "Domain",
                          ]),
            Project.Layer(name: "onboarding",
                          modules: [
                            "Address",
                            "Locality",
                            "Pizzeria",
                            "CityLanding",
                          ]),
            Project.Layer(name: "feature",
                          modules: [
                            "AreYouInPizzeria",
                            "AppSetup",
                            "Auth",
                            "Bonuses",
                            "Cart",
                            "Chat",
                            "CheckAPI",
                            "Checkout",
                            "DeliveryLocation",
                            "DeliveryLocationUI",
                            "DSecurity",
                            "Dune",
                            "Loyalty",
                            "Menu",
                            "MenuSearch",
                            "OrderHistory",
                            "OrderHistoryDomain",
                            "OrderTracking",
                            "Payment",
                            "ParallaxEditor",
                            "Product",
                            "Rate",
                            "Stories",
                          ]),
            Project.Layer(name: "App",
                          modules: [
                            "DodoPizza",
                            "DodoPizzaTests",
                            "E2ETests",
                            "PushNotificationContentExtension",
                          ]),
            
            Project.Layer(name: "Common",
                          modules: [
                            "Acquirers",
                            "Autocomplete",
                            "DCommon",
                            "DE2E",
                            "DID",
                            "DNetwork",
                            "Pods",
                          ]),
        ]
    )
}
