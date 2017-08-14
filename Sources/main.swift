print("Hello, world!")

import Cocoa

infix operator  >>>: AdditionPrecedence

func >>><A,B,C>( _  arg1:@escaping (A) -> (B), _ arg2:@escaping (B) -> C) -> (A) -> C {
    return  { a in
        arg2(arg1(a))
    }
}


let folder = ""

let fileManager = FileManager.default

func getFolderContent(_ folder:String) -> [URL]{
    let folderUrl = URL(fileURLWithPath: folder, isDirectory: true)
    return try! fileManager.contentsOfDirectory(at: folderUrl,
                                                includingPropertiesForKeys: nil,
                                                options: .skipsHiddenFiles)
}

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

func getFileName (_ url:URL ) -> String{
    return url.deletingPathExtension()
            .lastPathComponent
}

extension Dictionary{
    func contains(_ value: Key)->Bool{
        return self[value] != nil
    }
}

func createFolder(_ folderName:String){
    var bool = ObjCBool(true)
    if !fileManager.fileExists(atPath: folderName, isDirectory: &bool){
        try! fileManager.createDirectory(at: URL(fileURLWithPath: folderName, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
    }
}

func updatesFilesEntry(_ files:[URL],entries:[String:String]) -> [String:String]{
    
    let fileNames = files.map(getFileName)
    var dictionary:[String:String] = [:]
    fileNames.forEach({ file in
        if entries[file] != nil {
            dictionary[file] = entries[file]
        }
    })
    return dictionary
}

func mapDictIntoString(_ dictionary:[String:String]) -> String{
    return dictionary.reduce("", { acc,next in
        return acc + "\(next.key):\(next.value) \n"
    })
}

func main(){
    let processFile = readFile >>> fileTextToDict
    
    guard let textFile = getFolderContent(folder)
            .filter({ $0.pathExtension == "txt" })
            .first else { return; }
    
    let textData = processFile(textFile);
    
//    Creating a temp-folder
    let folderTempPath = ""
    let folderTemp = URL(fileURLWithPath: folderTempPath, isDirectory: true)
    createFolder(folderTempPath)
    //Filter all the files and copy
    let checkIfFileExist = getFileName >>> textData.contains
    let files = getFolderContent(folder)
                    .filter( checkIfFileExist )
        
    files.forEach({
        try! fileManager.copyItem(at: $0, to: folderTemp.appendingPathComponent($0.lastPathComponent))
    })
    //update labels
    let newEntriesFile = updatesFilesEntry(files, entries: textData)
    try! mapDictIntoString(newEntriesFile).write(to: folderTemp.appendingPathComponent(textFile.lastPathComponent), atomically: true, encoding: .utf8)
    
    print("Number of files copied \(files.count+1)")
    
    
    
}

main()


