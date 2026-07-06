import Combine
import Foundation

public enum NotchCalibrationRegion: Equatable, Sendable {
    case physicalDeadzone
    case inactiveSurface
    case hoverSurface
}

public enum NotchCalibrationAxis: Equatable, Sendable {
    case width
    case height
}

public struct NotchCalibrationHighlight: Equatable, Sendable {
    public let region: NotchCalibrationRegion
    public let axis: NotchCalibrationAxis

    public init(region: NotchCalibrationRegion, axis: NotchCalibrationAxis) {
        self.region = region
        self.axis = axis
    }
}

@MainActor
public final class NotchCalibrationHighlightStore: ObservableObject {
    public static let shared = NotchCalibrationHighlightStore()

    @Published public private(set) var activeHighlight: NotchCalibrationHighlight?

    private var clearTask: Task<Void, Never>?

    private init() {}

    public func activate(region: NotchCalibrationRegion, axis: NotchCalibrationAxis) {
        let highlight = NotchCalibrationHighlight(region: region, axis: axis)
        activeHighlight = highlight
        clearTask?.cancel()
        clearTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard self?.activeHighlight == highlight else { return }
                self?.activeHighlight = nil
            }
        }
    }

    public func clear() {
        clearTask?.cancel()
        activeHighlight = nil
    }
}
