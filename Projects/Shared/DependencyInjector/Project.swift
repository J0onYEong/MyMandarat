//
//  Project.swift
//
//  Created by choijunios on 2024/12/07
//

import ProjectDescription
import DependencyPlugin

let project = Project(
    name: "DependencyInjector",
    targets: [

        // Shared
        .target(
            name: "SharedDependencyInjector",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "\(Project.Environment.bundlePrefix).shared.DependencyInjector",
            sources: ["Sources/**"],
            dependencies: [
                .shared(interface: .DependencyInjector),
            ]
        ),

        // Interface
        .target(
            name: "SharedDependencyInjectorInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "\(Project.Environment.bundlePrefix).shared.DependencyInjector.interface",
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
    ]
)
