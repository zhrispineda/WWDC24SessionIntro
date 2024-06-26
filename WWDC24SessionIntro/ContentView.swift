//
//  ContentView.swift
//  WWDC24SessionIntro
//

import SwiftUI

struct ContentView: View {
    // Text to be animated
    let title = "Enter Session Title Here"
    @State private var subtitle = "First Name Last Name, Current Role"
    
    // Array of characters to animate
    @State private var characterAnimations: [Int: Letter] = [:]
    
    // Variables for animation
    @State private var buttonVisible = true
    @State private var isRunning = false
    @State private var isShrinking = false
    @State private var isLowering = false
    @State private var secondStage = false
    @State private var secondStageLowering = false
    @State private var isFadingOut = false
    @State private var isEnding = false
    
    @State private var text = String()
    
    var body: some View {
        ZStack {
            Rectangle() // Background
                .foregroundStyle(.tint)
                .ignoresSafeArea(.all)
            if isRunning {
                // MARK: Part One
                // Show, animate, and then hide initial WWDC24 logo
                Image("WWDC24")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.black)
                    .frame(height: isShrinking ? 50 : 80)
                    .padding(.top, isLowering ? 50 : 0)
                    .opacity(secondStage ? 0 : 1)
            } else {
                // MARK: - Starting point
                Button {
                    run()
                } label: {
                    Text("Click to Start")
                        .foregroundStyle(.black)
                        .font(.title)
                        .fontWeight(.heavy)
                        .fontWidth(.expanded)
                        .opacity(buttonVisible ? 1 : 0)
                }
                .buttonStyle(.plain)
            }
            
            if secondStage {
                // MARK: Part Two
                // Show and animate second WWDC24 logo
                topLeft()
                    .padding(.top, secondStageLowering ? (isEnding ? 40 : 25) : 10)
                    .opacity(isEnding ? 0 : 1)
            }
            
            // MARK: Part Three
            // Animate characters
            if secondStageLowering {
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack(spacing: 0) {
                            // Iterate each character individually to animate
                            ForEach(characterIndices(text: title), id: \.index) { item in
                                Text(item.character)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 40))
                                    .fontWidth(characterAnimations[item.index]?.width)
                                    .fontWeight(characterAnimations[item.index]?.weight)
                                    .onAppear {
                                        Task {
                                            try await Task.sleep(nanoseconds: 10_000_000 * UInt64(item.index))
                                            withAnimation {
                                                characterAnimations[item.index] = Letter(width: .expanded, weight: .heavy)
                                            }
                                            try await Task.sleep(nanoseconds: 15_000_000 * UInt64(item.index))
                                            withAnimation {
                                                characterAnimations[item.index] = Letter(width: .standard, weight: .bold)
                                            }
                                        }
                                    }
                            }
                            .geometryGroup()
                        }
                        .padding(.bottom, isFadingOut ? -5 : 0)
                        // Typewrite-effect animation
                        Text(text)
                            .foregroundStyle(.black)
                            .padding(.bottom, isEnding ? 100 : 120)
                            .monospaced()
                            .onAppear {
                                typewrite()
                            }
                    }
                    Spacer()
                }
                .padding(.leading, 25)
                .opacity(isFadingOut ? 0 : 1)
            }
        }
    }
    
    // Allocate every character into an array
    func characterIndices(text: String) -> [(character: String, index: Int)] {
        var result: [(character: String, index: Int)] = []
        for (index, character) in text.enumerated() {
            result.append((String(character), index))
        }
        return result
    }
    
    // MARK: - Main function
    // Main function for animating
    func run() {
        // Allocate characters as soon as view loads
        characterAnimations = Dictionary(uniqueKeysWithValues: characterIndices(text: title).map { ($0.index, Letter(width: .compressed, weight: .thin)) })
        
        // Reset text for restarting animation
        text = String()
        
        Task {
            withAnimation {
                buttonVisible = false
            }
            try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second in nanoseconds
            isRunning = true
            
            withAnimation {
                isShrinking = true
            }
            try await Task.sleep(nanoseconds: 500_000_000)
            withAnimation {
                isLowering = true
            }
            try await Task.sleep(nanoseconds: 250_000_000)
            secondStage.toggle()
            withAnimation {
                secondStageLowering = true
            }
            try await Task.sleep(nanoseconds: 4_000_000_000)
            end()
        }
    }
    
    // MARK: - Typewriter function
    // Typewriter effect of appending one letter every .03 seconds
    func typewrite() {
        Task {
            try await Task.sleep(nanoseconds: 150_000_000)
            for letter in subtitle {
                text.append(letter)
                try await Task.sleep(nanoseconds: 30_000_000)
            }
        }
    }
    
    // MARK: - Ending function
    func end() {
        Task {
            withAnimation {
                isFadingOut = true
            }
            try await Task.sleep(nanoseconds: 200_000_000)
            withAnimation {
                isEnding = true
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
            // Reset variables for restarting animation
            characterAnimations = [:]
            isRunning = false
            isShrinking = false
            isLowering = false
            secondStage = false
            secondStageLowering = false
            isFadingOut = false
            isEnding = false
            
            // Show button when complete
            withAnimation {
                buttonVisible = true
            }
        }
    }
}

// MARK: - Letter struct
// Store width and weight for each character
struct Letter {
    var width: Font.Width
    var weight: Font.Weight
}

// MARK: - Top left logo view
struct topLeft: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.tint)
                .ignoresSafeArea(.all)
            HStack {
                VStack {
                    Image("WWDC24")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(height: 30)
                        .padding(.leading, 25)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
