//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 02.09.2021.
//

import Foundation


class PodAnalyzer {
    
    func analyze() {
        let folders = ProjectFolder()
        let pizzaPods   = Podfile(path: folders.pizza.podfile,   name: "Pizza")
        let donerPods   = Podfile(path: folders.doner.podfile,   name: "Doner")
        let drinkitPods = Podfile(path: folders.drinkit.podfile, name: "Drinkit")
        
        compare(projects: [pizzaPods, donerPods, drinkitPods])
    }
    
    private func compare(projects: [Podfile]) {
        let allPods = allPods(in: projects)
        
        for pod in allPods {
            print(podState(of: pod, in: projects))
        }
    }
    
    private func podState(of pod: Pod,
                          in projects: [Podfile]
    ) -> String {
        var text = "\(pod)"
        for project in projects {
            let contain = project.pods.contains(pod)
            let result = contain ? "TRUE": "FALSE"
            text.append(" \(result)")
        }
        return text
    }
    
    private func allPods(in pods: [Podfile]) -> PodSet {
        var allPods = PodSet()
        for pod in pods {
            allPods.formUnion(pod.pods)
        }
        return allPods
    }
}
