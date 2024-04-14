import os
import Foundation
import Observation

@Observable
class CaptureFolderManager {
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "CaptureFolderManager"
    )
    
    private let logger = CaptureFolderManager.logger
    
    /// The top-level capture directory that contains Images and Snapshots subdirectories
    ///
    /// This sample automatically creates this directory at `init()` with timestamp
    let rootScanFolder: URL
    
    /// Subdirectory of `rootScanFolder` for images
    let imagesFolder: URL
    
    /// Subdirectory of `rootScanFolder` for snapshots
    let snapshotsFolder: URL
    
    /// Subdirectory of `rootScanFolder` for models
    let modelsFolder: URL
    
    var shots: [ShotFileInfo] = []
    
    init?() {
        guard let newFolder = CaptureFolderManager.createNewScanDirectory() else {
            logger.error("Unable to create a new scan directory.")
            return nil
        }
        rootScanFolder = newFolder
        
        // Creates the subdirectories
        imagesFolder = newFolder.appending(path: "Images/")
        guard CaptureFolderManager.createDirectoryRecursively(imagesFolder) else {
            return nil
        }
        
        snapshotsFolder = newFolder.appending(path: "Snapshots/")
        guard CaptureFolderManager.createDirectoryRecursively(snapshotsFolder) else {
            return nil
        }
        
        modelsFolder = newFolder.appending(path: "Models/")
        guard CaptureFolderManager.createDirectoryRecursively(modelsFolder) else {
            return nil
        }
    }
    
    func loadShots() async throws {
        logger.debug("Loading snapshots (async)...")
        
        var newShots: [ShotFileInfo] = []
        
        let imgUrls = try FileManager.default.contentsOfDirectory(
            at: imagesFolder,
            includingPropertiesForKeys: [],
            options: .skipsHiddenFiles
        ).filter {
            $0.isFileURL &&
            $0.lastPathComponent.hasSuffix(CaptureFolderManager.heicImageExtension)
        }
        
        for imgUrl in imgUrls {
            guard let shotFileInfo = ShotFileInfo(url: imgUrl) else {
                logger.error("Can't get shotId from url: \"\(imgUrl)\"")
                continue
            }
            
            newShots.append(shotFileInfo)
        }
        
        newShots.sort(by: { $0.id < $1.id })
        shots = newShots
    }
    
    /// Retrieves the image id from of an existing file at a URL.
    ///
    /// - Parameter url: URL of the photo for which this method returns the image id.
    /// - Returns: The image ID if `url` is valid; otherwise `nil`
    static func parseShotId(url: URL) -> UInt32? {
        let photoBasename = url.deletingPathExtension().lastPathComponent
        logger.debug("photoBasename = \(photoBasename)")
        
        guard let endOfPrefix = photoBasename.lastIndex(of: "_") else {
            logger.warning("Can't get endOfPrefix!")
            return nil
        }
        
        let imgPrefix = photoBasename[...endOfPrefix]
        guard imgPrefix == imageStringPrefix else {
            logger.warning("Prefix does not match!")
            return nil
        }
        
        let idString = photoBasename[photoBasename.index(after: endOfPrefix)...]
        guard let id = UInt32(idString) else {
            logger.warning("Can't convert idString=\"\(idString)\" to UInt32!")
            return nil
        }
        
        return id
    }
    
    /// - Returns: The basename for file with the given `id`
    static func imageIdString(for id: UInt32) -> String {
        return String(format: "%@%04d", imageStringPrefix, id)
    }
    
    /// Returns the file URL for the HEIC image that matches the specified
    /// image id in a specified output folder.
    ///
    /// - Parameters:
    ///   - outputDir: The directory where the capture session saves images.
    ///   - id: Identifier of an image.
    /// - Returns: Returns the file URL for the HEIC image.
    static func heicImageUrl(in outputDir: URL, id: UInt32) -> URL {
        return outputDir
            .appending(path: imageIdString(for: id))
            .appendingPathExtension(heicImageExtension)
    }
    
    /// Creates a new Scans directory based on the current timestamp in the top level Documents folder.
    /// - Returns: The new Scans folder's file URL, or  `nil` on error.
    static func createNewScanDirectory() -> URL? {
        guard let capturesFolder = rootScansFolder() else {
            logger.error("Can't get user document directory!")
            return nil
        }
        
        let fileManager = FileManager.default
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: Date())
        let newCaptureDir = capturesFolder.appending(path: timestamp, directoryHint: .isDirectory)
        
        logger.log("Creating capture path: \"\(String(describing: newCaptureDir))\"")
        let capturePath = newCaptureDir.path()
        do {
            try fileManager.createDirectory(atPath: capturePath, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create capture path: \"\(capturePath)\" error=\(String(describing: error))")
            return nil
        }
        
        var isDir: ObjCBool = false
        let exists = fileManager.fileExists(atPath: capturePath, isDirectory: &isDir)
        guard exists && isDir.boolValue else {
            return nil
        }
        
        return newCaptureDir
    }
    
    // - MARK: Private interface belwo.
    
    /// Creates all path components for the output directory.
    /// - Parameter outputDir: A URL for the new output directory.
    /// - Returns: A Boolean value that indicates whether the method succeeds.
    /// otherwise `false` if it encounters an error, suc as if the file already exists or the method could not create the file.
    private static func createDirectoryRecursively(_ outputDir: URL) -> Bool {
        guard outputDir.isFileURL else {
            return false
        }
        
        let expandedPath = outputDir.path()
        var isDirectory: ObjCBool = false
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: expandedPath, isDirectory: &isDirectory) else {
            logger.error("File already exists at \"\(expandedPath, privacy: .private)\"")
            return false
        }
        
        logger.log("Creating directory recursively: \"\(expandedPath, privacy: .private)\"")
        do {
            try fileManager.createDirectory(atPath: expandedPath, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create directory: \"\(expandedPath, privacy: .private)\" error=\(String(describing: error), privacy: .private)")
            return false
        }
        
        var isDir: ObjCBool = false
        let exists = fileManager.fileExists(atPath: expandedPath, isDirectory: &isDir)
        guard exists && isDir.boolValue else {
            logger.error("Directory at \"\(expandedPath, privacy: .private)\" does not exist after creation!")
            return false
        }
        
        logger.log("... success creating directory.")
        return true
    }
    
    // Constants this sample appends in front of the capture id to get a file basename.
    private static let imageStringPrefix = "IMG_"
    private static let heicImageExtension = "HEIC"
    
    /// Returns the app documents folder for all our captures.
    private static func rootScansFolder() -> URL? {
        guard let documentsFolder = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else {
            return nil
        }
    
        return documentsFolder.appending(path: "Scans/", directoryHint: .isDirectory)
    }
}
