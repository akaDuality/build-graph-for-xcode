//
//  DerivedDataStub.swift
//  ProjectsTests
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import BuildParser

class DerivedDataStub {
    let derivedData = URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData")
    
    var buildGraph: ProjectReference {
        let rootPath = derivedData.appendingPathComponent("BulidGraph-dwlksaohfylpdedqejrvuuglqzeo")
        
        return ProjectReference(
            name: "Build Graph",
            rootPath: rootPath,
            activityLogURL: [
                rootPath.appendingPathComponent("Logs/Build/0539119C-C9F6-4C93-9FD4-C9B5E6DCCFC9.xcactivitylog")],
            depsURL: nil
        )
    }
    
    var mobileBank: ProjectReference {
        let rootPath = derivedData.appendingPathComponent("MB-dadwdawdwafewfew")
        
        return ProjectReference(
            name: "Mobile Bank",
            rootPath: rootPath,
            activityLogURL: [
                rootPath.appendingPathComponent("Logs/Build/3452119C-C9F6-3213-9FD4-C9B5E6DCCFC9.xcactivitylog")],
            depsURL: nil
        )
    }
}
