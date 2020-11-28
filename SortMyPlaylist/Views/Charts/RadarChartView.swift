//
//  RadarChartView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 17/07/2020.
//

import SwiftUI

struct AnimatableVector: VectorArithmetic {
    static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let newValues = lhs.values
            .enumerated()
            .map { index, value in value - (rhs.values[safe: index] ?? .zero) }
        return AnimatableVector(values: newValues)
    }

    static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let newValues = lhs.values
            .enumerated()
            .map { index, value in value + (rhs.values[safe: index] ?? .zero) }
        return AnimatableVector(values: newValues)
    }

    var values: [CGPoint]

    mutating func scale(by rhs: Double) {
        values = values.map { $0.scale(by: CGFloat(rhs)) }
    }

    var magnitudeSquared: Double {
        values.reduce(0) { result, point in result + Double(point.magnitude()) }
    }

    static var zero = AnimatableVector(values: [.zero])
}

struct RadarShape: Shape {
    var points: [CGPoint]

    var animatedPoints: AnimatableVector
    var animatableData: AnimatableVector {
        get {
            animatedPoints
        }
        set {
            animatedPoints = newValue
        }
    }

    init(points: [CGPoint]) {
        self.points = points
        animatedPoints = AnimatableVector(values: points)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        animatedPoints.values.enumerated().forEach { index, point in
            if index == 0 {
                path.move(to: point.scale(by: radius) + CGPoint(x: radius, y: radius))
            } else {
                path.addLine(to: point.scale(by: radius) + CGPoint(x: radius, y: radius))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarChartView: View {
    @State var values: [CGFloat] = [0.9, 0.5, 0.5, 0.9, 0.5, 0.7]
    var body: some View {
        ZStack {
            GeometryReader { geo in

                RadarShape(points: pathPoints(values: Array(repeating: 0.25, count: values.count), geo: geo.size)).stroke(lineWidth: 1).foregroundColor(.gray)
                RadarShape(points: pathPoints(values: Array(repeating: 0.5, count: values.count), geo: geo.size)).stroke(lineWidth: 1).foregroundColor(.gray)
                RadarShape(points: pathPoints(values: Array(repeating: 0.75, count: values.count), geo: geo.size)).stroke(lineWidth: 1).foregroundColor(.gray)
                RadarShape(points: pathPoints(values: Array(repeating: 1, count: values.count), geo: geo.size)).stroke(lineWidth: 1).foregroundColor(.gray)
                Group {
                    RadarShape(points: pathPoints(values: values, geo: geo.size)).stroke(lineWidth: 2).foregroundColor(Color.Spotify.green)
                    RadarShape(points: pathPoints(values: values, geo: geo.size))
                        .fill(Color.Spotify.green).opacity(0.5)
                }
                .animation(.easeOut)
            }
        }.background(Color.Spotify.black).onTapGesture {
            withAnimation {
                self.values.shuffle()
            }
        }
    }

    func pathPoints(values: [CGFloat], geo _: CGSize) -> [CGPoint] {
        var points: [CGPoint] = []
        let tau = 1.5 * CGFloat.pi
        let strideBy = 2 * CGFloat.pi / CGFloat(values.count)
        stride(from: -0.5 * CGFloat.pi, to: tau, by: strideBy).enumerated().forEach { index, angle in
            let point = CGPoint(from: angle).scale(by: values[index])
            points.append(point)
        }
        return points
    }
}

struct RadarChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            RadarChartView().frame(width: 200, height: 200)
        }
    }
}
