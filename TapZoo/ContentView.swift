//
//  ContentView.swift
//  TapZoo
//
//  Created by Luke Mulholland on 2/11/2024.
//

import SwiftUI
import AVFoundation

import SwiftUI

struct ContentView: View {
    @Namespace private var animationNamespace
    @State private var animateIcons = false
    @State private var tappedIcon: String? = nil
    let icons = ["dog", "cat", "rabbit", "monkey", "lion", "cow", "sheep", "mouse", "fox", "kangaroo", "koala", "fish", "bear", "zebra", "penguin"]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Tap Zoo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                IconsGridView(icons: icons, animationNamespace: animationNamespace, animateIcons: $animateIcons, tappedIcon: $tappedIcon)
                
                Spacer()
            }
        }
    }
}

struct IconsGridView: View {
    let icons: [String]
    let animationNamespace: Namespace.ID
    @Binding var animateIcons: Bool
    @Binding var tappedIcon: String?
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(icons, id: \.self) { icon in
                IconItemView(icon: icon, animationNamespace: animationNamespace, animateIcons: $animateIcons, tappedIcon: $tappedIcon)
            }
        }
        .onAppear {
            animateIcons = true
        }
    }
}

struct IconItemView: View {
    let icon: String
    let animationNamespace: Namespace.ID
    @Binding var animateIcons: Bool
    @Binding var tappedIcon: String?
    
    var body: some View {
        NavigationLink(destination: DetailView(icon: icon)) {
            VStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                Text(icon.capitalized)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .scaleEffect(animateIcons ? 1 : 0.5)
            .opacity(animateIcons ? 1 : 0)
            .animation(.easeOut(duration: 0.5), value: animateIcons)
            .scaleEffect(tappedIcon == icon ? 0.9 : 1.0)
        }
        .simultaneousGesture(TapGesture().onEnded {
            tappedIcon = icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tappedIcon = nil
            }
        })
    }
}

struct DetailView: View {
    let icon: String
    private let synthesizer = AVSpeechSynthesizer() // Initialize the speech synthesizer

    var body: some View {
        Spacer() // Pushes the content down
        
        VStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10) // Add a bit of padding below the image to separate it from the text
            
            Text(icon.capitalized)  // Displaying the animal's name
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.primary)
            
            // Button to trigger speech synthesis
            Button(action: {
                speakAnimalName()
            }) {
                Text("Hear Name")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20) // Space above the button
        }
        
        .padding(.horizontal)
        Spacer()
        
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Speech synthesis function
    private func speakAnimalName() {
        let utterance = AVSpeechUtterance(string: icon.capitalized)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU") // Set language as English
        synthesizer.speak(utterance)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
