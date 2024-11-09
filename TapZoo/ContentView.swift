//
//  ContentView.swift
//  TapZoo
//
//  Created by Luke Mulholland on 2/11/2024.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var animateIcons = false
    @State private var tappedIcon: String? = nil
    // Change icons from a constant to a @State variable
    @State private var icons = [
        "dog", "cat", "rabbit", "monkey", "lion", "cow", "sheep",
        "mouse", "fox", "kangaroo", "koala", "fish", "bear",
        "zebra", "penguin", "dolphin", "chicken", "horse"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Tap Zoo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Pass the shuffled icons to IconsGridView
                IconsGridView(icons: icons, animateIcons: $animateIcons, tappedIcon: $tappedIcon)
                
                Spacer()
            }
            .onAppear {
                // Shuffle the icons array when the view appears
                icons.shuffle()
                animateIcons = true
            }
        }
    }
}

struct IconsGridView: View {
    let icons: [String]
    @Binding var animateIcons: Bool
    @Binding var tappedIcon: String?
    
    // Define the grid layout with three columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(icons, id: \.self) { icon in
                IconItemView(icon: icon, animateIcons: $animateIcons, tappedIcon: $tappedIcon)
            }
        }
        .padding()
        .onAppear {
            animateIcons = true
        }
    }
}

struct IconItemView: View {
    let icon: String
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
        VStack {
            Spacer() // Pushes the content down
            
            VStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10) // Add padding below the image
                
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
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Speech synthesis function
    private func speakAnimalName() {
        // Configure audio session to ignore silent mode
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }

        // Get the device's preferred language
        let preferredLanguage = Locale.preferredLanguages.first ?? "en-AU" // Default to "en-AU" if no preference
        let utterance = AVSpeechUtterance(string: icon.capitalized)
        utterance.voice = AVSpeechSynthesisVoice(language: preferredLanguage) // Set voice to the device's language
        
        synthesizer.speak(utterance)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
