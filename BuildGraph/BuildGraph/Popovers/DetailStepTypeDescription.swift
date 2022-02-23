//
//  DetailStepTypeDescription.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import XCLogParser

extension DetailStepType {
    var title: String {
        switch self {
            // Compile
        case .cCompilation: return "C"
            
        case .swiftCompilation: return "Swift"
            
        case .compileAssetsCatalog: return "Asset catalogs"
            
        case .compileStoryboard: return "Storyboard"
            
        case .XIBCompilation: return "Xib"
            
        case .swiftAggregatedCompilation: return "Swift Aggregated Compilation"
            
            // Non-compile
        case .scriptExecution: return "Script execution"
            
        case .createStaticLibrary: return "Create static library"
            
        case .linker: return "Linker"
            
        case .copySwiftLibs: return "Copy Swift Libs"
            
        case .writeAuxiliaryFile: return "Write auxiliary file"
            
        case .linkStoryboards: return "Link storyboards"
            
        case .copyResourceFile: return "Copy resourve files"
            
        case .mergeSwiftModule: return "Merge Swift module"
            
        case .precompileBridgingHeader: return "Precompile Bridging Header"
            
        case .other: return "Other"
            
        case .none: return "Unknown"
            
        }
    }
}
