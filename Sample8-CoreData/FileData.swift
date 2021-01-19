//
//  FileData.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/18.
//

import SwiftUI
import CoreData

// FireDataのコアデータ操作処理
extension FileData {
    // CoreDataに追加
    func addCoreData(){
        let newItem = MyEntity(context: viewContext)
        newItem.uuid = storeUuid
        newItem.key = storeKey
        // 構造体をエンコードして保存
        let encoded = try? JSONEncoder().encode(testData)
        newItem.data = encoded
        try? viewContext.save()    // ディスクに保存
    }
    // CoreDataから削除
    func deleteCoreData(){
        // CoreDataからIDでデータを抽出
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"MyEntity")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", storeUuid as CVarArg)
        fetchRequest.fetchLimit = 1
        // 抽出したデータを削除
        do {
            let resultList = try viewContext.fetch(fetchRequest)
            viewContext.delete(resultList[0])
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        try? viewContext.save()    // ディスクに保存
    }
    // CoreDataからデータを取得
    func getCoreData(uuid : UUID) -> FileData?{
        var fileData : FileData?
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MyEntity")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let resultList = try viewContext.fetch(fetchRequest) as! [MyEntity]
            fileData = FileData(entity: resultList[0],viewContext: viewContext)
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        return fileData
    }
}
// キーに該当するデータを全件取得
extension FileDataArray {
    // CoreDataからデータを取得
    init(key: String, viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
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
                let fileData = FileData(entity:data, viewContext: viewContext)
                storeFileDataList.append(fileData)
            }
        } catch {
            print(error)
        }
    }
}
// 共有のCoreDataを扱う型
public struct FileData {
    private var viewContext : NSManagedObjectContext    // CoreData
    private var storeUuid = UUID()
    private var storeKey = ""
    
    var uuid : UUID {
        get { return storeUuid }
    }
    var key : String {
        get { return storeKey }
    }

    // 初期処理：追加
    public init(key: String = "", viewContext : NSManagedObjectContext){
        self.storeKey = key
        self.viewContext = viewContext
        // CoreDataに追加
        addCoreData()
    }
    // 初期処理:CoreDataから取得
    public init(entity: MyEntity, viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
        self.storeUuid = entity.uuid!
        self.storeKey = entity.key!
        // 構造体をデコード
        let testData : [TestData] = try! JSONDecoder().decode([TestData].self, from: entity.data!)
        for data in testData {
            print("testData = \(data.name)")
        }
    }
    // IDよりデータ取得
    public func get()->(uuid:UUID, key:String) {
        return (uuid:storeUuid, key:storeKey)
    }
}
// 共有のデータをリストで管理
public struct FileDataArray {
    private var viewContext : NSManagedObjectContext
    private var storeFileDataList : [FileData] = []

    public init(viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
        storeFileDataList = []
    }
    // データを文字列で取得
    public func getStringData() -> String {
        var stringData = ""
        
        for item in storeFileDataList {
            stringData += (item.key + "\n")
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
        let data = FileData(key:key, viewContext: viewContext)
        storeFileDataList.append (data)
    }

}
