//
//  RemoteImageComponent.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI
import URLImage

struct RemoteImageView: View {
    var url: String?
    var body: some View {
        let image = URLImage(URL(string: url ?? "https://via.placeholder.com/640x640")!,
                             animated: true,

                             placeholder: Image(systemName: "music.note")
                                 .renderingMode(.original),
                             content: {
                                 $0.image
                                     .renderingMode(.original)
                                     .resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .clipped()
                             })
        return image
    }
}

struct RemoteImageComponent_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImageView()
    }
}
