import SwiftUI

public struct LoadingImageView: View {
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    var size: CGSize = CGSize(width: 300, height: 300)
    var center: CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }
    @State private var timer: Timer?
    @State var isAutoRepeat: Bool = false
    let image: Image

    public var body: some View {
        VStack {
            Spacer()
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .modifier(RippleEffect(at: origin, trigger: counter))
                .frame(width: size.width, height: size.height)
                .onAppear {
                    isAutoRepeat = true
                }
                .onChange(of: isAutoRepeat) {
                    if isAutoRepeat {
                        // タイマーで一定間隔ごとに波を発生させる
                        timer?.invalidate() // 既存のタイマーを無効化
                        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                            origin = center
                            counter += 1
                        }
                    } else {
                        timer?.invalidate() // タイマーを停止
                        timer = nil
                    }
                }
                .onPressingChanged { point in
                    if let point {
                        origin = point
                        counter += 1
                        isAutoRepeat = false
                        // turn auto repeat true after 1 second later
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isAutoRepeat = true
                        }
                    }
                }
            Spacer()
        }
    }
}

struct PushEffect<T: Equatable>: ViewModifier {
    var trigger: T

    func body(content: Content) -> some View {
        content.keyframeAnimator(
            initialValue: 1.0,
            trigger: trigger
        ) { view, value in
            view.visualEffect { view, _ in
                view.scaleEffect(value)
            }
        } keyframes: { _ in
            SpringKeyframe(0.95, duration: 0.4, spring: .snappy)
            SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
        }
    }
}

/// A modifer that performs a ripple effect to its content whenever its
/// trigger value changes.
struct RippleEffect<T: Equatable>: ViewModifier {
    var origin: CGPoint

    var trigger: T

    init(at origin: CGPoint, trigger: T) {
        self.origin = origin
        self.trigger = trigger
    }

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration

        content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration
            ))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }

    var duration: TimeInterval { 3 }
}

/// A modifier that applies a ripple effect to its content.
struct RippleModifier: ViewModifier {
    var origin: CGPoint

    var elapsedTime: TimeInterval

    var duration: TimeInterval

    var amplitude: Double = 6
    var frequency: Double = 15
    var decay: Double = 2
    var speed: Double = 200
    
    private var shaderFunction: ShaderFunction {
        ShaderFunction(library: .bundle(.module),
                       name: "Ripple")
    }

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.bundle(.module).Ripple(
            .float2(origin),
            .float(elapsedTime),

            // Parameters
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )

        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: true//0 < elapsedTime && elapsedTime < duration
            )
        }
    }

    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }
}

extension View {
    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
        modifier(SpatialPressingGestureModifier(action: action))
    }
}

struct SpatialPressingGestureModifier: ViewModifier {
    var onPressingChanged: (CGPoint?) -> Void

    @State var currentLocation: CGPoint?

    init(action: @escaping (CGPoint?) -> Void) {
        self.onPressingChanged = action
    }

    func body(content: Content) -> some View {
        let gesture = SpatialPressingGesture(location: $currentLocation)

        if #available(iOS 18.0, *) {
            content
                .gesture(gesture)
                .onChange(of: currentLocation, initial: false) { _, location in
                    onPressingChanged(location)
                }
        } else {
            content
                .onChange(of: currentLocation, initial: false) { _, location in
                    onPressingChanged(location)
                }
        }
    }
}

struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }

    @Binding var location: CGPoint?

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.delegate = context.coordinator

        return recognizer
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: UIGestureRecognizerType, context: Context) {
            switch recognizer.state {
                case .began:
                    location = context.converter.localLocation
                case .ended, .cancelled, .failed:
                    location = nil
                default:
                    break
            }
    }
}



#Preview {
    LoadingImageView(image: Image("default", bundle: .module))
}

