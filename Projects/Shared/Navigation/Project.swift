//
//  Project.swift
//
//  Created by choijunios on 2024/12/10
//

import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "Navigation",
    targets: [

        // Shared
        .target(
            name: "SharedNavigation",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).shared.Navigation",
            sources: ["Sources/**"],
            dependencies: [
                .shared(interface: .Navigation),
            ]
        ),

        // Interface
        .target(
            name: "SharedNavigationInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "\(Project.Environment.bundlePrefix).shared.Navigation.interface",
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
    ]
)
