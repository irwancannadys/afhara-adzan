import Foundation
import AVFoundation
import Observation

@Observable
final class AudioService: NSObject {

    static let shared = AudioService()

    var isPlaying: Bool = false
    var onAdzanFinished: (() -> Void)?

    private var player: AVAudioPlayer?

    private override init() { super.init() }

    // MARK: - Public

    func playAdzan(soundName: String = "adzan_makkah") {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("[AudioService] File tidak ditemukan: \(soundName).mp3")
            return
        }
        do {
            player?.stop()
            player           = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.volume   = 1.0
            player?.play()
            isPlaying        = true
            print("[AudioService] Playing \(soundName)")
        } catch {
            print("[AudioService] Error: \(error)")
        }
    }

    func stopAdzan() {
        let wasPlaying = isPlaying
        player?.stop()
        player    = nil
        isPlaying = false
        // Manual stop tetap trigger onAdzanFinished agar doa + iqamah tetap jalan
        if wasPlaying {
            onAdzanFinished?()
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Delegate bisa dipanggil dari background thread — dispatch ke main
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.onAdzanFinished?()
        }
    }
}
