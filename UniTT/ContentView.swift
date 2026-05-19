//
//  ContentView.swift
//  UniTT
//
//  Created by 천승환 on 5/15/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AuthFlowView {
            UserHifiAppView()
        }
    }
}

#Preview {
    ContentView()
}
