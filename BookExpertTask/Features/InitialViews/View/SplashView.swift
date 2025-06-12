//
//  SplashView.swift
//  BookExpertTask
//
//  Created by pnkbksh on 12/06/25.
//

import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "book.fill")
                    .resizable()
                    .frame(width: animate ? 150 : 60, height: animate ? 150 : 60)
                    .opacity(animate ? 1 : 0.5)
                    .scaleEffect(animate ? 1 : 0.8)
                    .animation(.easeInOut(duration: 1.2), value: animate)
                    .foregroundColor(.blue)
                
                Text("Book Expert Task")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .opacity(animate ? 1 : 0.2)
                    .animation(.easeInOut(duration: 1.5), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    SplashView()
}
