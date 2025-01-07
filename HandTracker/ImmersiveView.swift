//
//  ImmersiveView.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import ARKit
import RealityKit

struct ImmersiveView: View {
    public static let identifier = "ImmersiveSpace"

    @State var tracker: HandSuiteTools.Tracker
    @State var gesture: HandSuiteTools.HandGesture

    let leftSphere = ModelEntity.createSphere(radius: 10.0, hexColor: "FAF9F6")
    let rightSphere = ModelEntity.createSphere(radius: 10.0, hexColor: "FAF9F6")

    var body: some View {
        RealityView { content in
            tracker.addToContent(content)
        } update: { content in
            tracker.processGestures()
            if gesture.wasRecognized {
               if let event = gesture.leftEvent,
                  let anchor = event.anchor,
                  event.wasRecognized {
                   content.add(leftSphere)
                   self.transform(model: leftSphere, using: anchor)
               } else {
                   content.remove(leftSphere)
               }

                if let event = gesture.rightEvent,
                   let anchor = event.anchor,
                   event.wasRecognized {
                    content.add(rightSphere)
                    self.transform(model: rightSphere, using: anchor)
                } else {
                    content.remove(rightSphere)
                }
            } else {
                content.remove(leftSphere)
                content.remove(rightSphere)
            }
        }
        .upperLimbVisibility(.hidden)
        .ignoresSafeArea()
        .onAppear {
            tracker.install(gesture: gesture)
        }
        .task {
            await tracker.track()
        }
    }

    private func transform(model: ModelEntity, using anchor: HandAnchor) {
        if let metacarpal = anchor.handSkeleton?.joint(.middleFingerMetacarpal) {
            let metacarpalTransform = metacarpal.anchorFromJointTransform
            let translation = metacarpalTransform.columns.3
            let xFactor: Float = anchor.chirality == .left ? 0.05 : -0.05
            let yFactor: Float = anchor.chirality == .left ? 0.1 : -0.1
    
            model.transform.translation = [translation.x + xFactor, translation.y + yFactor, translation.z]
    
            let matrix = matrix_multiply(anchor.originFromAnchorTransform, model.transform.matrix)
            let trasform = Transform(matrix: matrix)
    
            model.transform = trasform
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(tracker: .init(), gesture: .init([]))
}

//if gesture.wasRecognized {
//    content.add(leftSphere)
//
//    if let leftAnchor = gesture.recognizedAnchors.left,
//       let metacarpal = leftAnchor.handSkeleton?.joint(.middleFingerMetacarpal) {
//        
//        let metacarpalTransform = metacarpal.anchorFromJointTransform
//        let translation = metacarpalTransform.columns.3
//        
//        leftSphere.transform.translation = [translation.x + 0.05, translation.y + 0.1, translation.z]
//        
//        let matrix = matrix_multiply(leftAnchor.originFromAnchorTransform, leftSphere.transform.matrix)
//        let trasform = Transform(matrix: matrix)
//        
//        leftSphere.transform = trasform
//        
//        withAnimation {
//            if leftSphere.scale.x < 10.0 {
//                leftSphere.scale *= 1.1
//            }
//        }
//    }
//} else {
//    content.remove(leftSphere)
//}
