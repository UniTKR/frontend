//
//  ContentView.swift
//  UniTT
//
//  Created by 천승환 on 5/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var completedOnboarding = false

    var body: some View {
        if completedOnboarding {
            UserWireframeAppView()
        } else {
            OnboardingFlowView {
                completedOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}
