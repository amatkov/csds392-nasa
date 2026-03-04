//
//  ContentView.swift
//  NASANetworking
//
//  Created by Gus on 3/3/26.
//

import SwiftUI
import Foundation

struct Picture: Codable, Identifiable {
    var id = UUID()
    var date: String
    var explanation: String
    var hdurl: String?
    var mediaType: String
    var title: String
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl, title, url
        case mediaType = "media_type"
    }
}

struct NasaImage {
    func getEntries() async -> [Picture]? {
        let today = Date()
        let daysAgo = -5
        let calendar = Calendar.current
        let key = "DEMO_KEY" // Change for different API key
        
        if let date = calendar.date(byAdding: .day, value: daysAgo, to: today) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let todayString = dateFormatter.string(from: today)
            let startString = dateFormatter.string(from: date)
            
            let urlString = "https://api.nasa.gov/planetary/apod?start_date=" + startString + "&end_date=" + todayString + "&api_key=" + key
            
            let session = URLSession.shared
            
            if let url = URL(string: urlString) {
                
                let request = URLRequest(url: url)
                do {
                    let (data, _) = try await session.data(for: request)
                    let decoder = JSONDecoder()
                    let pictures: [Picture] = try decoder.decode([Picture].self, from: data)
                    return pictures
                } catch {}
            }
        }
        return nil
    }
}

struct ContentView: View {
    let nasa = NasaImage()
    @State var images: [Picture] = []
    
    func loadImages() {
        Task {
            if let response = await nasa.getEntries() {
                self.images = response
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("NASA APOD")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()
            VStack {
                List {
                    ForEach($images) {
                        $currentImage in NavigationLink {
                            APODView(picture: currentImage)
                        } label: {
                            ListElement(picture:currentImage)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            loadImages()
        }
    }
}

#Preview {
    ContentView()
}
