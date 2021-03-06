//
//  SortCardView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 01/08/2020.
//

import SwiftUI

struct SortCardView: View {
    let attribute: Spotify.SortAttribute
    @State var faceUp: Bool = false

    let cornerRadius: CGFloat = 10

    @Binding var sortPlaylist: SortPlaylist
    @Binding var faceUpAttribute: Spotify.SortAttribute?

    var body: some View {
        let flipEffect = FlipEffect(faceUp: self.$faceUp, angle: faceUpAttribute == attribute
            ? 0 : 180, axis: (0, 1))

        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(.init(attribute.colour))
                .modifier(flipEffect)
                .shadow(radius: 5)
            self.frontFace
                .opacity(faceUp ? 1 : 0).animation(nil)
                .rotation3DEffect(
                    .init(degrees: -180),
                    axis: (0, 1, 0)
                )
                .modifier(flipEffect)

            self.backFace.opacity(faceUp ? 0 : 1).animation(nil)
                .modifier(flipEffect)
        }
    }

    var frontFace: some View {
        Button(action: self.frontFaceClick) {
            VStack {
                Label(
                    title: {
                        Text("\(attribute.rawValue.capitalized)")
                            .bold()
                            .font(.title3)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    },
                    icon: {
                        if selected && sortPlaylist.order != .none {
                            Image(systemName: sortPlaylist.order.iconName)
                        } else {
                            EmptyView()
                        }
                    }
                ).padding()
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(SortCardButtonStyle(radius: cornerRadius))
        .disabled(isNotSelected)
    }

    var selected: Bool {
        sortPlaylist.by == attribute
    }

    var isNotSelected: Bool {
        sortPlaylist.by != .none && !selected
    }

    var backFace: some View {
        ZStack {
            VStack(spacing: 0) {
                Button(action: { self.sort(in: .asc) }) {
                    Image(systemName: "arrowtriangle.up.fill").font(.title)
                        .foregroundColor(.white)
                }.buttonStyle(SortCardButtonStyle(radius: cornerRadius))
                Spacer()
                Button(action: { self.sort(in: .dec) }) {
                    Image(systemName: "arrowtriangle.down.fill").font(.title)
                        .foregroundColor(.white)
                }.buttonStyle(SortCardButtonStyle(radius: cornerRadius))
            }
        }
    }

    func sort(in order: Spotify.SortOrder) {
        toggleFace()
        sortPlaylist = .init(by: attribute, order: order)
    }

    func frontFaceClick() {
        if attribute == sortPlaylist.by {
            sortPlaylist.order.toggle()
        } else {
            toggleFace()
        }
    }

    func toggleFace() {
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 15)) {
            if self.attribute == faceUpAttribute {
                self.faceUpAttribute = nil
            } else {
                self.faceUpAttribute = self.attribute
            }
        }
    }
}

struct SortCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            SortCardListView(sortPlaylist: .constant(.empty))
                .frame(height: 120)
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
                .background(Rectangle().foregroundColor(Color.Spotify.darkGrey)).clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
    }
}

struct SortCardButtonStyle: ButtonStyle {
    let radius: CGFloat
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .contentShape(RoundedRectangle(cornerRadius: radius))
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: radius).foregroundColor(Color.white.opacity(0.5))
                    } else {
                        Color.clear
                    }
                }
            )
    }
}

// https://swiftui-lab.com/swiftui-animations-part2/
struct FlipEffect: GeometryEffect {
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    @Binding var faceUp: Bool
    var angle: Double
    let axis: (x: CGFloat, y: CGFloat)

    func effectValue(size: CGSize) -> ProjectionTransform {
        // We schedule the change to be done after the view has finished drawing,
        // otherwise, we would receive a runtime error, indicating we are changing
        // the state while the view is being drawn.
        DispatchQueue.main.async {
            self.faceUp = self.angle >= 90 && self.angle < 270
        }

        let a = CGFloat(Angle(degrees: angle).radians)

        var transform3d = CATransform3DIdentity
        transform3d.m34 = -1 / max(size.width, size.height)

        transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width / 2.0, -size.height / 2.0, 0)

        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width / 2.0, y: size.height / 2.0))

        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}
