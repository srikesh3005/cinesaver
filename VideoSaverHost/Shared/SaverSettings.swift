import Foundation

enum SaverSettings {
    static let videoFileName = "selected-video.mov"
    static let selectedVideoExistsKey = "selectedVideoExists"

    static func sharedContainerURL() -> URL? {
        guard let moviesDir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return moviesDir.appendingPathComponent(".CineSaver")
    }

    static func selectedVideoURL() -> URL? {
        sharedContainerURL()?.appendingPathComponent(videoFileName)
    }
}
