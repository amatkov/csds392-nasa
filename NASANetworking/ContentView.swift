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
    var url: String? // I think there is always a URL, but I left it optional just in case
    
    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl, title, url
        case mediaType = "media_type" // Conform to swift standard camelcase
    }
}
extension Picture{
    static let fallbackPic = Picture(date: "6969-06-09", explanation: "An error occured",hdurl: "https://thumbs.dreamstime.com/z/erreur-28681424.jpg", mediaType: "image", title: "Oops", url: "https://thumbs.dreamstime.com/z/erreur-28681424.jpg" )
}



struct NasaImage {
    func getEntries() async -> [Picture]? {
        let today = Date()
        let daysAgo = -5 // Amount of past days to fetch APOD
        let calendar = Calendar.current
        let key = "DEMO_KEY" // Change for different API key
        
        
        if let date = calendar.date(byAdding: .day, value: daysAgo, to: today) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Not sure if needed, saw it on StackOverflow
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let todayString = dateFormatter.string(from: today)
            let startString = dateFormatter.string(from: date)
            
            let urlString = "https://api.nasa.gov/planetary/apod?start_date=" + startString + "&end_date=" + todayString + "&api_key=" + key // By completing in one API call, program is more efficient for demo rate limits
            print(urlString)
            
            let session = URLSession.shared
            
            if let url = URL(string: urlString) {
                
                let request = URLRequest(url: url)
                do {
                    let (data, response) = try await session.data(for: request)
                    //print(data)
                    guard
                        let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode == 200
                    else {
                        return [
                            Picture.fallbackPic
                        ]
                    }
                    
                    let decoder = JSONDecoder()
                    let pictures: [Picture] = try decoder.decode([Picture].self, from: data) // Apparently you can decode an array of JSON to an array of struct. This is a lot easier than what I was trying
                    return pictures.reversed()
                } catch {
                    
                    print(error)
                }
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
                Spacer() // I think this is how you are supposed to align to right
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
            print("hi")
        }
    }
}

#Preview {
    ContentView()
}
