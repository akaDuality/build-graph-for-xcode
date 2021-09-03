//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 03.09.2021.
//

import Foundation

class PodStatsPrinter {
    
    func output(
        externalPods: PodSet,
        internalPods: PodSet,
        projects: [Podfile]
    ) {
        outputTitles(projects: projects)
        output("External", pods: externalPods, in: projects)
        output("Internal", pods: internalPods, in: projects)
    }
    
    private func outputTitles(
        projects: [Podfile]
    ) {
        let titles = projects.map { project in
            project.name
        }.joined(separator: " ")
        
        print("Pods \(titles)")
    }
    
    private func output(
        _ title: String,
        pods: PodSet,
        in projects: [Podfile]) {
        print("\(title)")
        for pod in pods.sorted() {
            print(podState(of: pod, in: projects))
        }
        print("\n")
    }
    
    private func podState(
        of pod: Pod,
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
}
