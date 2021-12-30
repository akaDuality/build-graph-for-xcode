    import XCTest
    @testable import FileAnalyzer
    
    final class LineCountTests: XCTestCase {
        
        let projectsFolder = ProjectFolder(projectsFolder: "/Users/rubanov/Documents/Projects/")
        
        func testPizza() throws {
            let srcRoot: URL = projectsFolder.pizza
            
            // Overall
            try LineCount(folder: srcRoot).read(project: .pizza)
            try LineCount(folder: srcRoot.appendingPathComponent("DCommon/")).read()
            
            // App
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/Domain/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/Module/")).read()
        }
        
        func testDoner() throws {
            let srcRoot: URL = projectsFolder.doner
            
            try LineCount(folder: srcRoot).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Sources/")).read()

            try LineCount(folder: srcRoot.appendingPathComponent("Pods/")).read()
        }
        
        func testDrinkit() throws {
            let srcRoot: URL = projectsFolder.drinkit
            
            try LineCount(folder: srcRoot).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Core/")).read()
            
            try LineCount(folder: srcRoot.appendingPathComponent("Sources/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Sources/Screens")).read()
            
            try LineCount(folder: srcRoot.appendingPathComponent("Pods/")).read()
        }
    }
    
    
