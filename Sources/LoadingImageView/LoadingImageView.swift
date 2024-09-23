import SwiftUI

public struct LoadingImageView: View {
    let image: Image

    var size: CGSize
    var center: CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }
    var cornerSize: CGFloat {
        min(size.width, size.height) * 0.2
    }

    @State var counter: Int = 0
    @State var origin: CGPoint = .zero

    public init(image: Image, size: CGSize = CGSize(width: 100, height: 100)) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        VStack {
            Spacer()
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: cornerSize))
                .modifier(RippleEffect(at: origin, trigger: counter, size: size))
                .frame(width: size.width, height: size.height)
                .onAppear {
                    origin = center
                    counter += 1
                }
                .onPressingChanged { point in
                    if let point {
                        origin = point
                        counter += 1
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
    
    var size: CGSize

    init(at origin: CGPoint, trigger: T, size: CGSize) {
        self.origin = origin
        self.trigger = trigger
        self.size = size
    }

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration

        content.keyframeAnimator(
            initialValue: 10,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration,
                size: size
            ))
        } keyframes: { _ in
            MoveKeyframe(10)
            LinearKeyframe(duration, duration: duration)
        }
    }

    var duration: TimeInterval { 100 }
}

/// A modifier that applies a ripple effect to its content.
struct RippleModifier: ViewModifier {
    var origin: CGPoint

    var elapsedTime: TimeInterval

    var duration: TimeInterval

    var size: CGSize

    var amplitude: Double {
        0.03 * min(size.width, size.height)
    }
    var frequency: Double {
        15
    }
    var decay: Double = 0.01
    var speed: Double {
        min(size.width, size.height)
    }
    
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
    VStack {
        LoadingImageView(image: Image("default", bundle: .module))
        LoadingImageView(image: Image("default", bundle: .module),
                         size: CGSize(width: 200, height: 200))
        LoadingImageView(image: Image("default", bundle: .module),
                         size: CGSize(width: 300, height: 300))
    }
}

