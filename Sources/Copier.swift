//
//  Copier.swift
//  ImageLabeler
//
//  Created by Alcala, Jose Luis on 8/12/17.
//

import Foundation
import Cocoa

final class Copier {
    
    let folders = ["",""]
    let fileManager = FileManager.default
    let folder = "/Users/alcaljos/adidas_images/images_mixed"
    
    func readFile(_ url:URL) -> String {
        let fileHandle = try! FileHandle(forReadingFrom: url)
        let dataFromFile = fileHandle.readDataToEndOfFile()
        return String(data: dataFromFile, encoding: .utf8)!
    }
    
    func fileTextToDict(_ text:String) -> [String:String]{
        let lines = text.components(separatedBy: .newlines)
        var dictionary:[String:String] = [:]
        lines.forEach({ line in
            let parts = line.split(separator: ":")
            guard !parts.isEmpty else { return }
            let key = String(parts.first!)
            let content = parts.dropFirst().reduce("", +)
            dictionary[key] = content
        })
        return dictionary
    }
    
    func findFile(_ name:String,urls:[URL]) -> URL?{
        return urls.first(where: {
            $0.deletingPathExtension().lastPathComponent == name
        })
    }
    
    func createFolder(){
        var bool = ObjCBool(true)
        if !fileManager.fileExists(atPath: folder, isDirectory: &bool){
            try! fileManager.createDirectory(at: URL(fileURLWithPath: folder, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func createLabelFile() -> String {
        let textFile = "\(folder)/labels.txt"
        if !fileManager.fileExists(atPath:textFile ){
            fileManager.createFile(atPath: textFile, contents: nil, attributes: nil)
        }
        return textFile
    }
    
    func getFilesData(_ folders:[String]) -> [String:[String:String]]  {
        var filesData:[String:[String:String]] = [:]
        let textFiles = folders
            .map({ URL(fileURLWithPath: $0, isDirectory: true) })
            .flatMap({ try! fileManager.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) })
            .filter({ $0.pathExtension == "txt" })
        textFiles.forEach({ filesData[$0.lastPathComponent] = fileTextToDict(readFile($0)) })
        return filesData
    }
    
    func main(){
        createFolder()
        let labelFile = createLabelFile()
        let fileWriter = FileHandle(forWritingAtPath:labelFile)!
        let files = folders
            .map({ URL(fileURLWithPath: $0, isDirectory: true) })
            .flatMap({ try! fileManager.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) })
        
        let filesData = getFilesData(folders)
        filesData.forEach({ fileText,entries in
            entries.forEach({ fileName,text in
                
                guard let file = findFile(fileName,urls: files) else { return }
                let newPath = URL(fileURLWithPath: "\(folder)/\(file.lastPathComponent)")
                
                try! fileManager.copyItem(at: file, to: newPath)
                fileWriter.seekToEndOfFile()
                fileWriter.write("\(fileName): \(text) \n".data(using: .utf8)!)
            })
        })
        
    }
}


