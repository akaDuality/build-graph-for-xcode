//
//  ProjectsIngtegrationTests.swift
//  ProjectsIngtegrationTests
//
//  Created by Mikhail Rubanov on 16.04.2022.
//

import XCTest
@testable import Projects
import BuildParser

class ProjectsIngtegrationTests: XCTestCase {

    var presenter: ProjectsPresenter!
    
    // MARK: - Test doubles
    var ui: ProjectsUIMock!
    var delegate: ProjectsSelectionDelegateMock!
    var projectsFinder: ProjectsFinderMock!
    var projectSettings: ProjectSettingsMock!
    
    let stub = DerivedDataStub()
    
    // MARK: Test cycle
    override func setUpWithError() throws {
        self.projectsFinder = ProjectsFinderMock()
        self.delegate = ProjectsSelectionDelegateMock()
        self.projectSettings = ProjectSettingsMock()
        
        self.presenter = ProjectsPresenter(
            projectSettings: projectSettings,
            projectsFinder: projectsFinder,
            delegate: delegate)
        
        self.ui = ProjectsUIMock()
    }

    override func tearDownWithError() throws {
        self.presenter = nil
        self.ui = nil
    }
    
    // MARK: - Tests
    
    // TODO: Show loading state?
    
    func test_userRestrictsAccessToDerivedData_whenReloadDatat_shouldShowNoAccessState() {
        name("Отображаем специальное состояние, когда запрещён доступ к папке DerivedData.")
        
        // given
        projectsFinder.derivedDataPathResult = .failure(ProjectsFinder.Error.noDerivedData)
        
        // when
        presenter.reloadProjetcs(ui: ui)
        
        // then
        XCTAssertEqual(ui.states, [.noAccessToDerivedData])
        // TODO: should present empty state to details?
    }
    
    func test_userAllowAccessButThereInNoFile_whenReloadDatat_shouldShowEmptyState() {
        name("Показываемм экран - отображается список проектов.")
        
        // given
        projectsFinder.derivedDataPathResult = .success(stub.derivedData)
        
        // when
        presenter.reloadProjetcs(ui: ui)
        
        // then
        XCTAssertEqual(ui.states, [.empty(stub.derivedData)])
        // TODO: should present empty state to details?
    }
    
    func test_1ProjectInFolder_whenReleadData_shouldShowDataWithoutSelection() {
        name("Ничего не выбрано. После перезагрузки должно остаться также.")
        
        // given
        projectsFinder.derivedDataPathResult = .success(stub.derivedData)
        projectsFinder.projects = [stub.buildGraph]
        
        // when
        presenter.reloadProjetcs(ui: ui)
        
        // then
        XCTAssertEqual(ui.states, [.projects(nil)])
        XCTAssertTrue(delegate.didSelectNothing)
        XCTAssertNil(delegate.selectedProject, "Not select project yet")
        
        // Select
        presenter.select(from: .leftPanel(project: stub.buildGraph, lastBuildIndex: nil))
        XCTAssertEqual(delegate.selectedProject, stub.buildGraph)
        
        // TODO: Test that senconde selection doesn't change selected project
    }
    
    func test_hasSelectedProject_1ProjectInFolder_whenReleadData_shouldShowDataWithoutSelection() {
        
        // given
        projectsFinder.derivedDataPathResult = .success(stub.derivedData)
        projectsFinder.projects = [stub.buildGraph]
        projectSettings.selectedProject = stub.buildGraph.name
        
        // when
        presenter.reloadProjetcs(ui: ui)
        
        // then
        XCTAssertEqual(ui.states, [.projects(stub.buildGraph)])
        XCTAssertEqual(delegate.selectedProject, stub.buildGraph)
    }
    
    func test_expand_donot_reloadProject() {
        name("Разворачивание проекта не перезагружает его.")
        
        // given
        projectsFinder.derivedDataPathResult = .success(stub.derivedData)
        let projectToSelect = stub.buildGraph
        projectsFinder.projects = [projectToSelect]
        projectSettings.selectedProject = stub.buildGraph.name
        
        // when
        presenter.reloadProjetcs(ui: ui)
        XCTAssertEqual(delegate.selectedProjectCount , .projectOnceSelected)
        presenter.changeBuild(from: .leftPanel(project: projectToSelect, lastBuildIndex: 0))
        XCTAssertEqual(delegate.selectedProjectCount , .projectOnceSelected)
    }
    
    func test_collapsingAnotherProject_donotSelectIt() {
        name("Сорачивание другого проекта не выбирает его.")
        
        // given
        projectsFinder.derivedDataPathResult = .success(stub.derivedData)
        let selectedProject = stub.buildGraph
        let projectToCollapse = stub.mobileBank
        projectsFinder.projects = [selectedProject, projectToCollapse]
        projectSettings.selectedProject = stub.buildGraph.name
        
        // when
        presenter.reloadProjetcs(ui: ui)
        
        // then
        XCTAssertFalse(presenter.shouldSelectProject(project: projectToCollapse))
    }
    
    func test_collapseCurrentProject_donotReloadIt() {
        name("Сорачивание проекта не перезагружает его.")
        
        // given
        projectsFinder.derivedDataPathResult = .success(stub.derivedData)
        let selectedProject = stub.buildGraph
        projectsFinder.projects = [selectedProject]
        projectSettings.selectedProject = stub.buildGraph.name
        
        // when
        presenter.reloadProjetcs(ui: ui)
        
        // then
        XCTAssertEqual(delegate.selectedProjectCount , .projectOnceSelected)
        presenter.select(from: .leftPanel(project: selectedProject, lastBuildIndex: nil))
        XCTAssertEqual(delegate.selectedProjectCount , .projectOnceSelected)
    }
}

class ProjectSettingsMock: ProjectSettingsProtocol {
    var selectedProject: String? = nil
}

private extension Int {
    static let projectOnceSelected = 1
}
