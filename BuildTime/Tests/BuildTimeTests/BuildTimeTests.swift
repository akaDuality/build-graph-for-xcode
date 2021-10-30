import XCTest
@testable import BuildTime
import CustomDump

final class BuildTimeTests: XCTestCase {
    func testSuccess() throws {
        let string = "2021-03-18T10:17:39+00:00,17,success,DodoPizza.xcworkspace,,12.4,12D4e"
        
        XCTAssertNoDifference(
            BuildTimeParser().parse(line: string,
                                    userName: "test"),
            Build(userName: "test",
                  date: "2021-03-18T10:17:39+00:00",
                  duration: 17,
                  result: .success,
                  workspace: "DodoPizza",
                  project: "",
                  xcode: Build.Xcode(
                    version: "12.4",
                    build: "12D4e")
                 )
            )
    }
    
    func testFail() {
        let string = "2021-10-21T17:24:34+00:00,1,fail,,DynamicTypeDemo.xcodeproj,13.0,13A233"
        
        XCTAssertNoDifference(
            BuildTimeParser().parse(line: string,
                                    userName: "test"),
            Build(userName: "test",
                  date: "2021-10-21T17:24:34+00:00",
                  duration: 1,
                  result: .fail,
                  workspace: "",
                  project: "DynamicTypeDemo",
                  xcode: Build.Xcode(
                    version: "13.0",
                    build: "13A233")
                 )
        )
    }
    
    func testFile(_ name: String) throws -> String {
        let url = Bundle.module.url(forResource: name, withExtension: "csv")!
        let file = try String(contentsOf: url)
        return file
    }
    
    func testFile() throws {
        let file = try testFile("buildTimes")
        
        let builds = BuildTimeParser().parse(file: file,
                                             userName: "test")
        
        XCTAssertEqual(builds.count, 12481)
        
        XCTAssertEqual(builds.number(of: .success), 6464)
        XCTAssertEqual(builds.number(of: .fail), 6017)
        
        XCTAssertNoDifference(
            builds.workspaces()
                .sorted(),
            [
                "",
                "\"Prep Station.xcworkspace\"",
                "ARKit-Sampler",
                "AccessibilitySnapshot",
                "Activity",
                "Chetvertak",
                "CodeMetrics",
                "DemoAppTemplate",
                "DemoAppTemplateWorkspace",
                "DodoPizza",
                "DodoPizzaTuist",
                "Drinkit",
                "DynamicType",
                "Linza",
                "Manifests",
                "MobileBackend",
                "PizzeriaDemo",
                "PrepStation",
                "PrepStationTuist",
                "TuistDemo",
                "TypaliasBug",
                "doner-mobile-ios",
                "package",
            ])
        
        XCTAssertNoDifference(
            builds.projects()
                .sorted(),
            [
                "",
                "AccessibilityCarouselSample",
                "AccessibilityExamples",
                "AccessibilityRotorSample",
                "AccessibilityTask",
                "AccessibilityTraits",
                "Activity",
                "CaptureSample",
                "DynamicType",
                "DynamicTypeDemo",
                "HapticLoading",
                "HeicTest",
                "HellWorld",
                "HelloPhotogrammetry",
                "LayoutTests",
                "Linza",
                "LocalizationMove",
                "LocalizationShift",
                "NavigationSample",
                "ProductCartWith3D",
                "RomanianNumbers",
                "TestReportParser",
                "ToneGenerator"
            ])
        
        XCTAssertEqual(builds.summaryDuration(workspace: "DodoPizza"),
                       290971)
    }
    
    func test_files() throws {
        let builds = BuildTimeParser().parse(
            files: [
                "1": try testFile("buildTimes"),
                "2": try testFile("buildTimes1"),
                "3": try testFile("buildTimes2"),
                "4": try testFile("buildTimes3"),
                "5": try testFile("buildTimes4"),
                ]
            )
        
        XCTAssertEqual(
            builds.count,
            41939)
        
        XCTAssertEqual(
            builds.summaryDuration(workspace: "DodoPizza"),
            1060455)
        
        XCTAssertEqual(
            builds.summaryDuration(workspace: "DemoAppTemplate"),
            14069)
        
        XCTAssertEqual(
            builds.summaryDuration(workspace: "DemoAppTemplateWorkspace"),
            284)
        
        XCTAssertEqual(
            builds.summaryDuration(workspace: "DodoPizzaTuist"),
            1372)
        
        let dodoBuilds = builds.filterWorkspace("DodoPizza")
        XCTAssertEqual(dodoBuilds.count, 23095)
        
//        printAsCSV(dodoBuilds)
//        try text.data(using: .utf8)?.write(to: URL(fileURLWithPath: "~/Users/rubanov/builds.csv"))
    }
    
    func printAsCSV(_ dodoBuilds: [Build]) {
        var text = ""
        for build in dodoBuilds {
            text.append("\(build.date),\(build.duration),\(build.userName)\n")
        }
        
        print(text)
    }
}
