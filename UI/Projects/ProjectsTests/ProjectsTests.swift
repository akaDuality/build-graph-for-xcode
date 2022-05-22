//
//  ProjectsTests.swift
//  ProjectsTests
//
//  Created by Mikhail Rubanov on 16.04.2022.
//

import XCTest
@testable import Projects
import BuildParser

class ProjectsTests: XCTestCase {

    var presenter: ProjectsPresenter!
    
    // MARK: - Test doubles
    var ui: ProjectsUIMock!
    var delegate: ProjectsSelectionDelegateMock!
    var projectsFinder: ProjectsFinderMock!
    var projectSettings: ProjectSettingsMock!
    
    // MARK: Constants
    private let derivedData = URL(fileURLWithPath: "/DerivedData")
    private let buildGraph = ProjectReference(
        name: "Build Graph",
        rootPath: URL(fileURLWithPath: "/DerivedData/BuildGraph"),
        activityLogURL: [URL(fileURLWithPath: "/Test")],
        depsURL: nil)
    
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
        projectsFinder.derivedDataPathResult = .failure(ProjectsFinder.Error.noDerivedData)
        
        presenter.reloadProjetcs(ui: ui)
        
        XCTAssertEqual(ui.states, [.noAccessToDerivedData])
        // TODO: should present empty state to details?
    }
    
    // 0. Когда показываю экран должен отобразиться список проектов.
    func test_userAllowAccessButThereInNoFile_whenReloadDatat_shouldShowEmptyState() {
        projectsFinder.derivedDataPathResult = .success(derivedData)
        
        presenter.reloadProjetcs(ui: ui)
        
        XCTAssertEqual(ui.states, [.empty(derivedData)])
        // TODO: should present empty state to details?
    }
    
    func test_1ProjectInFolder_whenReleadData_shouldShowDataWithoutSelection() {
        projectsFinder.derivedDataPathResult = .success(derivedData)
        projectsFinder.projects = [buildGraph]
        
        presenter.reloadProjetcs(ui: ui)
        
        XCTAssertEqual(ui.states, [.projects(nil)])
        XCTAssertTrue(delegate.didSelectNothing)
        XCTAssertNil(delegate.selectedProject, "Not select project yet")
        
        // Select
        presenter.select(project: buildGraph)
        XCTAssertEqual(delegate.selectedProject, buildGraph)
        
        // TODO: Test that senconde selection doesn't change selected project
    }
    
    func test_hasSelectedProject_1ProjectInFolder_whenReleadData_shouldShowDataWithoutSelection() {
        projectsFinder.derivedDataPathResult = .success(derivedData)
        projectsFinder.projects = [buildGraph]
        projectSettings.selectedProject = buildGraph.name
        
        presenter.reloadProjetcs(ui: ui)
        
        XCTAssertEqual(ui.states, [.projects(buildGraph)])
        XCTAssertEqual(delegate.selectedProject, buildGraph)
    }
    
    // 1. Есть выбранный проект
    // Разверенули список файлов
    // Не перезагрузили проект
    
    // 2. - Сворачивание
    
    // 3. Если сворачиваем другой проект, то не нужно перезагружать текущий выбранный
}

class ProjectSettingsMock: ProjectSettingsProtocol {
    var selectedProject: String? = nil
}
