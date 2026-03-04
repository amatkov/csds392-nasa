//
//  APODView.swift
//  NASANetworking
//
//  Created by Gus on 3/4/26.
//

import SwiftUI

/**
 This is a struct that defines the view of a single Astronomy Picture of the Day from NASA. It has built-in handling for non-image types, and uses a switch inside AsyncImage for the best possible UX while the image loads.
 */
struct APODView: View {
    var picture: Picture
    var hasImage:Bool {
        picture.mediaType == "image"
    }
    @State var imgURL:URL?
    
    var body: some View {
        VStack {
            HStack {
                Text(picture.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            if hasImage {
                AsyncImage(url: imgURL) { phase in // Switching for AsyncImages is way more intuitive than using booleans
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let img):
                        img.resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Text("Failed to load image.")
                    @unknown default: // Swift told me to put this here to protect for future async image updates. I did it to get rid of the error
                        Text("Unknown error.")
                    }
                }
            }
            HStack {
                Text(picture.explanation)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .padding()
        .onAppear {
            if let hdurl = picture.hdurl { // Uses hdurl for image quality. Takes a while to load
                self.imgURL = URL(string:hdurl)
            }
        }
    }
}

#Preview("Image") {
    APODView(picture: Picture(
        date: "2026-03-02",
        explanation: "How well do you know the night sky? OK, but how well can you identify famous sky objects in a very deep image? Either way, here is a test: see if you can find some well-known night-sky icons in a deep image filled with filaments of normally faint dust and gas.  This image contains the Pleiades star cluster, Barnard's Loop, Orion Nebula, Aldebaran, Betelgeuse, Witch Head Nebula, Eridanus Loop, and the California Nebula. To find their real locations, here is an annotated image version.  The reason this task might be difficult is similar to the reason it is initially hard to identify familiar constellations in a very dark sky: the tapestry of our night sky has an extremely deep hidden complexity.  The featured composite reveals some of this complexity in a 16 hours of sky exposure in dark skies over Granada, Spain.    Tonight: Total Lunar Eclipse",
        hdurl: "https://apod.nasa.gov/apod/image/2603/DustyOrionPleiades_Fernandez_5000.jpg",
        mediaType: "image",
        title: "The Dusty Surroundings of Orion and the Pleiades",
        url: "https://apod.nasa.gov/apod/image/2603/DustyOrionPleiades_Fernandez_960.jpg"
        
    ))
}

#Preview("Video") {
    APODView(picture: Picture(
        date: "2026-03-03",
        explanation: "If you could fly over the North Pole of Mars, what would you see?  Images from ESA’s Mars Express mission in 2019 were compiled into the featured video which shows just such a trip.  First you see below you a landscape tinted orange by rusted iron in the fine soil, with some land appearing darker due to exposed rock.  Soon the northern polar cap comes into view, mostly white because of its reflective frozen water.  Surrounding the polar cap is the North Polar Basin, a layered depression covered with dust and sand.  The frames in the featured video were captured during northern Martian Spring when the carbon-dioxide ice is evaporating, leaving the underlying water-ice in the cap. Mars Express continues to study the Martian surface and look for clues about the Red Planet's ancient climate and potential for life.",
        hdurl: "",
        mediaType: "video",
        title: "Flying over the North Pole of Mars",
        url: "https://apod.nasa.gov/apod/image/2603/FlyingNorth_MarsExpress.mp4"
        
    ))
}
