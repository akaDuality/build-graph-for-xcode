//
//  SnapshotSaveService.swift
//  Details
//
//  Created by Mikhail Rubanov on 26.04.2022.
//

import Foundation
import BuildParser

class SnapshotSaveService {
    func save(project: ProjectReference, to url: URL) {
        let document = XcodeBuildSnapshot(project: project)
        
        do {
            document.save(to: url, ofType: XcodeBuildSnapshot.bgbuildsnapshot, for: .saveOperation) { error in
               
            }
        } catch let error {
            // TODO: Handle error
        }
    }
}
