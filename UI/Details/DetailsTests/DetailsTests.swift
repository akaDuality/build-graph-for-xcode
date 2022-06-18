//
//  DetailsTests.swift
//  DetailsTests
//
//  Created by Mikhail Rubanov on 08.04.2022.
//

import XCTest
@testable import Details
import Snapshot

import CustomDump
import Projects

class DetailsStatePresenterTests: XCTestCase {

    var sut: DetailsStatePresenter!
    
    var ui: DetailStateUIMock!
    var delegate: DetailsDelegateMock!
    
    override func setUpWithError() throws {
        ui = DetailStateUIMock()
        delegate = DetailsDelegateMock()
         
        sut = DetailsStatePresenter()
        sut.ui = ui
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        ui = nil
        delegate = nil
        sut = nil
    }
    
    func test_whenLoadBrokeFile_shouldShowNoErrorState() throws {
        throw XCTSkip("Should find file sample that brokes test")
        
        try loadFile(name: "BrokenFile")

        XCTAssertEqual(ui.states, [
            .loading,
            .noEvents(.empty)
        ])
    }
    
    private func loadFile(name: String) throws {
        let snapshot = try TestBundle().snapshot(name: name)
        
        let completeExpect = expectation(description: "Set state to UI")
        
        sut.openProject(
            projectReference: snapshot.project,
            filter: .shared) {
                completeExpect.fulfill()
            }
        
        XCTAssertEqual(ui.states, [.loading], "Show loading immediately")
        wait(for: [completeExpect], timeout: 1)
    }

    func test_whenLoadEmptyFile_shouldShowNoEventsState() throws {
        try loadFile(name: "PrepareBuildOnly")
        
        XCTAssertEqual(ui.states, [
            .loading,
            .noEvents(.empty)
        ])
    }
    
    func test_whenLoadFile_shouldShowNoEventsState() throws {
        try loadFile(name: "SimpleClean")
        
        guard case let .data(project, title, _) = ui.states.last else {
            XCTFail("Expect data state on UI"); return
        }
        
        XCTAssertNoDifference(
            project.events.map(\.taskName),
            ["NQueue",
             "NInject",
             "NI18n",
             "DAcquirers",
             "CocoaDebug",
             "NCallback",
             "NRequest",
             "DCommon",
             "DFoundation",
             "DNetwork",
             "DUIKit",
             "SDK-ios"])
        
        XCTAssertEqual(title, "Build SDK-ios")
    }
    
    // TODO: all disabled filters should show empty state. Enabling some filter should present graph
}

extension Project {
    static var empty: Project {
        Project(events: [], relativeBuildStart: 0)
    }
}

class DetailStateUIMock: DetailStateUIProtocol {
    var state: DetailsState = .default {
        didSet {
            states.append(state)
            stateExpectation?.fulfill()
        }
    }
    
    var stateExpectation: XCTestExpectation?
    
    var states: [DetailsState] = []
}

import BuildParser
class DetailsDelegateMock: DetailsDelegate {
    
    func willLoadProject(project: ProjectReference) {
        
    }
    
    func didLoadProject(project: Project, projectReference: ProjectReference) {
        
    }
    
    func didFailLoadProject(projectReference: ProjectReference) {
    
    }
}
