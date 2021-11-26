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
                  date: "2021-03-18",
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
                  date: "2021-10-21",
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
                "Intel": try testFile("buildTimes"),
                "M1": try testFile("buildTimes1_M1"),
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
        let averageTime = averageTime(for: dodoBuilds)
        XCTAssertEqual(averageTime, 45)
        
        let medianTime = medianTime(for: dodoBuilds)
        XCTAssertEqual(medianTime, 23)
        
        print("")
//        printAsCSV(dodoBuilds)
//        try text.data(using: .utf8)?.write(to: URL(fileURLWithPath: "~/Users/rubanov/builds.csv"))
    }
    
    func testDateTime() throws {
        let intelTimes = sumOfTime(files: ["Intel": try testFile("buildTimes")], workspace: "DodoPizza")
        let m1Times = sumOfTime(files: ["M1": try testFile("buildTimes1_M1")], workspace: "DodoPizza")
        
        let allDates = Set(intelTimes.keys).union(Set(m1Times.keys))
        
        print("Date, M1, Intel")
        for date in allDates {
            print("\(date), \(m1Times[date] ?? 0), \(intelTimes[date] ?? 0)")
        }
        
        print("")
    }
    
    func testAllFiles() throws {
        let files = [
            "Intel": try testFile("buildTimes"),
            "M1": try testFile("buildTimes1_M1"),
            "M1 also": try testFile("buildTimes2"),
            "4": try testFile("buildTimes3"),
            "5": try testFile("buildTimes4"),
        ]

        let allKeys = files.keys
        var times = [String: TimePerDay]()
        var allDates = Set<String>()
        for file in files {
            let timeSummary = sumOfTime(files: [file.key: file.value], workspace: "DodoPizza")
            times[file.key] = timeSummary
            allDates.formUnion(Set(timeSummary.keys))
        }
        
        // MARK: - Printing
        print("Date, \(times.keys.joined(separator: ", "))")
        
        for date in allDates {
            var text = ""
            for fileName in allKeys {
                let summaryForFile = times[fileName]
                let daySummary = summaryForFile?[date] ?? 0
                text.append("\(daySummary), ")
            }
            
            print("\(date), \(text)")
        }
        
        print("")
    }
    
    typealias TimePerDay = [String: Double]
    func sumOfTime(files: [String: String], workspace: String) -> TimePerDay {
        let builds = BuildTimeParser().parse(
            files: files
        ).filterWorkspace(workspace)
        
        let groups = Dictionary(grouping: builds) { element in
            element.date
        }
        
//        let sumTime = groups.map { key, builds in
//            (key, Double(self.sumTime(for: builds)) / 60)
//        }
        
        var sumTime = TimePerDay()
        for (key, builds) in groups {
            sumTime[key] = Double(self.averageTime(for: builds)) / 60
        }
        
        //        let averageTime = groups.map { key, builds in
        //            (key, self.averageTime(for: builds))
        //        }
        
        return sumTime
    }
    
    func sumTime(for builds: [Build]) -> Int {
        var sumOfTime = 0
        for build in builds {
            sumOfTime += build.duration
        }
        return sumOfTime
    }
    
    func averageTime(for builds: [Build]) -> Double {
        return Double(sumTime(for: builds) / builds.count)
    }
    
    func medianTime(for builds: [Build]) -> Double {
        let durations = builds.map { $0.duration }
        let sorted = builds.map { $0.duration }.sorted(by: <)
        let median = Double(sorted[sorted.count/2] + sorted.reversed()[sorted.count/2])/2.0
        return median
    }
    
    func printAsCSV(_ dodoBuilds: [Build]) {
        var text = ""
        for build in dodoBuilds {
            text.append("\(build.date),\(build.duration),\(build.userName)\n")
        }
        
        print(text)
    }
}
