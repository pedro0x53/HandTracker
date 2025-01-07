//
//  HandTrackerApp.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import HandSuite

@main
struct HandTrackerApp: App {
    let tracker = HandSuiteTools.Tracker()
    
    let gesture = HandSuiteTools.HandGesture(chirality: .either, [
        .init(name: .thumb, curlness: 0.1),
        .init(name: .index, curlness: 0.5),
        .init(name: .middle, curlness: 0.5),
        .init(name: .ring, curlness: 0.5),
        .init(name: .little, state: .straight)
    ])

    var body: some Scene {
        WindowGroup {
            ContentView(gesture: gesture)
                .task {
                    await tracker.requestAuthorization()
                }
        }

        ImmersiveSpace(id: ImmersiveView.identifier) {
            ImmersiveView(tracker: tracker, gesture: gesture)
        }
    }
}
