//
//  SubscriberView.swift
//  Sortify
//
//  Created by Coskun Deniz on 06/03/2021.
//

import SwiftUI
import Combine


struct SubscriberView<Publisher: Combine.Publisher, Content: View, InitialContent: View>: View where Publisher.Failure == Never {
    
    let content: (Publisher.Output) -> Content
    let publisher: Publisher
    let initialContent: InitialContent

    @State var value: Publisher.Output? = nil
    
    init(_ publisher: Publisher, @ViewBuilder content: @escaping (Publisher.Output) -> Content) where InitialContent == EmptyView {
        self.publisher = publisher
        self.content = content
        self.initialContent = EmptyView()
    }
    
    init(_ publisher: Publisher, initialContent: InitialContent, @ViewBuilder content: @escaping (Publisher.Output) -> Content) {
        self.publisher = publisher
        self.content = content
        self.initialContent = initialContent
    }
    
    var body: some View {
        Group {
            if let value = self.value {
                self.content(value)
            } else {
                self.initialContent
            }
        }.onReceive(self.publisher) {
            self.value = $0
        }
    }
}


struct SubscriberView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriberView(Just(0)) { _ in Text("1") }
    }
}
