//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 02.09.2021.
//

import Foundation

class PodAnalyzer {
    
    func analyze() {
        let projects = projects()
        
        let allPods = projects.allPods()
            .withoutTestHelpers()
        
        let externalPods = allPods.subtracting(internalPods)
        
        PodStatsPrinter().output(externalPods: internalPods,
                                 internalPods: externalPods,
                                 projects: projects)
    }
    
    func projects() -> [Podfile] {
        let folders = ProjectFolder()
        let pizzaPods   = Podfile(path: folders.pizza.podfile,   name: "Pizza")
        let donerPods   = Podfile(path: folders.doner.podfile,   name: "Doner")
        let drinkitPods = Podfile(path: folders.drinkit.podfile, name: "Drinkit")
        return [pizzaPods, donerPods, drinkitPods]
    }
}

extension Array where Element == Podfile {
    func allPods() -> PodSet {
        var allPods = PodSet()
        for pod in self {
            allPods.formUnion(pod.pods)
        }
        
        return allPods
    }
}

extension Set where Element == Pod {
    func withoutTestHelpers() -> PodSet {
        filter { pod in
            !pod.isTestHelper
        }
    }
}

extension Pod {
    var isTestHelper: Bool {
        hasSuffix("TestHelpers")
    }
}
