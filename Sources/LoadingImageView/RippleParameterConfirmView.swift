//
//  RippleParameterConfirmView.swift
//  LoadingImageView
//
//  Created by bsakai on 2024/09/20.
//

import SwiftUI

struct ConfirmView: View {
    @State var origin: CGPoint = .zero
    @State var time: TimeInterval = 0.3
    @State var amplitude: TimeInterval = 12
    @State var frequency: TimeInterval = 15
    @State var decay: TimeInterval = 8

    var body: some View {

        VStack {
            GroupBox {
                Grid {
                    GridRow {
                        VStack(spacing: 4) {
                            Text("Time")
                            Slider(value: $time, in: 0 ... 2)
                        }
                        VStack(spacing: 4) {
                            Text("Amplitude")
                            Slider(value: $amplitude, in: 0 ... 100)
                        }
                    }
                    GridRow {
                        VStack(spacing: 4) {
                            Text("Frequency")
                            Slider(value: $frequency, in: 0 ... 30)
                        }
                        VStack(spacing: 4) {
                            Text("Decay")
                            Slider(value: $decay, in: 0 ... 20)
                        }
                    }
                }
                .font(.subheadline)
            }

            Spacer()

            Image("default", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .modifier(RippleModifier(origin: origin, elapsedTime: time, duration: 2, amplitude: amplitude, frequency: frequency, decay: decay))
                .onTapGesture {
                    origin = $0
                }

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ConfirmView()
}

