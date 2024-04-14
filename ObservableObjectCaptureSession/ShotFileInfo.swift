import Foundation

struct ShotFileInfo: Identifiable {
    let fileURL: URL
    let id: UInt32
    
    init?(url: URL) {
        fileURL = url
        
        guard let shotID = CaptureFolderManager.parseShotId(url: url) else {
            return nil
        }
        
        id = shotID
    }
}
