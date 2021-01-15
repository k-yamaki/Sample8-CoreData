//
//  CoreData.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/13.
//
/*　CoreDataの使い方
 // データの設定
 @State var fileDataArray = FileDataArray()
 let persistenceController = MyPersistenceController.shared
 @Environment(\.managedObjectContext) private var viewContext
 
 // 共有のCoreDataのデータをロード
 fileDataArray.load(viewContext: viewContext, key: "キー")
 */

import Foundation
import SwiftUI
import CoreData

// 共有用のNSPersistentContainer：AppGroupを指定
public class MyPersistentContainer : NSPersistentContainer {
    override public class func defaultDirectoryURL() -> URL {
        // CoreDataにAppGroupsを指定
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.hiroshimamm.grp_system")!
        return url
    }
}

public struct MyPersistenceController {
    public static let shared = MyPersistenceController()
    public let container: MyPersistentContainer

    init(inMemory: Bool = false) {
        // データを指定
        container = MyPersistentContainer(name: "CoreData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

// 共有のCoreDataを扱う型
public struct FileData {
    private var storeUuid = UUID()
    private var storeKey = ""
    private var storeUpdate : UpdateType = .add
    
    var uuid : UUID {
        get { return storeUuid }
    }
    var key : String {
        get { return storeKey }
    }
    var update : UpdateType {
        get { return storeUpdate}
    }
    // 初期処理
    public init(key: String = ""){
        self.storeKey = key
    }
    public init(entity: MyEntity){
        self.storeUuid = entity.uuid!
        self.storeKey = entity.key!
        self.storeUpdate = .done
        // let testData : TestData = entity.rect
        // 構造体をデコード
        let testData = try? JSONDecoder().decode(TestData.self, from: entity.rect!)
        print("testData = \(testData!.rect)")
    }
    // 更新の完了
    public mutating func updateDone() {
        storeUpdate = .done
    }
    // IDよりデータ取得
    public func get()->(uuid:UUID, key:String) {
        return (uuid:storeUuid, key:storeKey)
    }
}
public struct FileDataArray {
    private var storeFileDataList : [FileData] = []
    
    public init(){
        storeFileDataList = []
    }
    // データを文字列で取得
    public func getStringData() -> String {
        var stringData = ""
        
        for item in storeFileDataList {
            stringData += (/*item.uuid.uuidString + " " + */item.key + "\n")
        }
        return stringData
    }
    // サブスクリプト
    public subscript(index:Int) -> FileData {
        get {
            return storeFileDataList[index]
        }
        set {
            storeFileDataList[index] = newValue
        }
    }
    // データを追加
    public mutating func add (key: String) {
        let data = FileData(key:key)
        storeFileDataList.append (data)
    }
    // キーのデータをロード
    public mutating func load(viewContext : NSManagedObjectContext, key: String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MyEntity")

        let sortDescripter = NSSortDescriptor(key: "uuid", ascending: true)    // IDの昇順で取得
        fetchRequest.sortDescriptors = [sortDescripter]
        if key != "" {
            fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        }
 
        do {
            let resultList = try viewContext.fetch(fetchRequest)
            self.storeFileDataList = []
            for data in resultList as! [MyEntity] {
                let fileData = FileData(entity:data)
                storeFileDataList.append(fileData)
            }
        } catch {
            print(error)
        }
    }
    // データを保存：更新フラグに従ってリストのデータをCoreDataに保存
    public mutating func save(viewContext : NSManagedObjectContext) {
        var count = storeFileDataList.count
        for index in 0 ..< count {
            // YAMAKI この行が必要か
            if index == count { break } // 削除されて、ループが回っているので、抜ける
            let data = storeFileDataList[index]
            switch data.update {
            case .add:      // 追加
                let newItem = MyEntity(context: viewContext)
                newItem.uuid = data.uuid
                newItem.key = data.key
                // 構造体をエンコードして保存
                let encoder = JSONEncoder()
                do {
                    let encoded = try encoder.encode(testData)
                    newItem.rect = encoded
                } catch {
                    print(error.localizedDescription)
                }
            case .update:   // 更新
                // CoreDataからIDでデータを抽出
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MyEntity")
                fetchRequest.predicate = NSPredicate(format: "uuid = %@", data.uuid as CVarArg)
                fetchRequest.fetchLimit = 1
                // 抽出したデータを更新
                do {
                    let resultList = try viewContext.fetch(fetchRequest)
                    let result = resultList[0] as! MyEntity
                    result.key = data.key
                } catch { print(error) }
            case .delete:   // 削除
                // CoreDataからIDでデータを抽出
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"MyEntity")
                fetchRequest.predicate = NSPredicate(format: "uuid = %@", data.uuid as CVarArg)
                fetchRequest.fetchLimit = 1
                // 抽出したデータを削除
                do {
                    let resultList = try viewContext.fetch(fetchRequest)
                    viewContext.delete(resultList[0])
                } catch let error as NSError {
                    print("\(error), \(error.userInfo)")
                }
                storeFileDataList.remove(at: index)
                count -= 1  // リストのデータを削除
                continue
            case .done:     // 済
                break
            }
            storeFileDataList[index].updateDone()
        }
        try? viewContext.save()    // ディスクに保存
    }
}

