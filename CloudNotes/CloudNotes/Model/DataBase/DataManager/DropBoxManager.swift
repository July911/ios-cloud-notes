import Foundation
import SwiftyDropbox

class DropBoxManager: DataManager {
    
    private var memoList: [Memo]?
    private let client = DropboxClientsManager.authorizedClient
    
    init() {
        self.createFolder()
    }
    
    func create(attributes: [String: Any]) {
        self.upload(target: Memo(title: "제목 없음", body: nil, lastModified: Date(), identifier: UUID()))
    }
    
    func read(index: IndexPath) -> MemoType? {
        downloadToDocuments()
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dropboxURL = directoryURL.appendingPathComponent("dropboxMemos").description
        let filePaths = fileManager.subpaths(atPath: dropboxURL)
        var sampleMemos: [Memo]?
        
        do {
            let memos = try filePaths?.map({ (path) -> Memo in
                let data = fileManager.contents(atPath: path)
                return try JSONDecoder().decode(Memo.self, from: data ?? Data())
            })
            sampleMemos = memos?.sorted(by: {
                guard let lhs = $0.lastModified, let rhs = $1.lastModified else {
                    return false
                }
                return lhs > rhs }
            )
        } catch {
            print("dropbox download fail")
        }
        sampleMemos = memoList
        return sampleMemos?[index.row]
    }
    
    func update(target: MemoType, attributes: [String: Any]) {
        upload(target: target)
    }
    
    func delete(target: MemoType) {
    }
    
    func countAllData() -> Int {
        memoList?.count ?? .zero
    }
    
    private func createFolder() {
        client?.files.createFolderV2(path: "/test/path/in/Dropbox/account").response { response, error in
            if let response = response {
                print(response)
            } else if let error = error {
                print(error)
            }
            
        }
    }
    
    private func upload(target: MemoType) {
        // TODO: createFolder 메서드 한 번만 호출하도록 수정 필요
        let memo = Memo(title: target.title, body: target.body, lastModified: target.lastModified, identifier: target.identifier)
        guard let data = try? JSONEncoder().encode(memo) else {
            return
        }
        
        client?.files.upload(path: "/test/path/in/Dropbox/account/\(String(describing: target.identifier))", input: data).response{ (response, error) in
            if let response = response {
                print("✅\(response)")
            } else if let error = error {
                print(error)
            }
        }.progress({ progressData in
            print(progressData)
        })
    }
    
    private func downloadToDocuments() {
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = directoryURL.appendingPathComponent("dropboxMemos")
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }
        
        client?.files.download(path: "/test/path/in/Dropbox/account/", overwrite: true, destination: destination)
            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
}
