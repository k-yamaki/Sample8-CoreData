//
//  LightData.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/19.
//

import SwiftUI
import CoreData

// LightDataのコアデータ操作処理
extension LightData {
    // CoreDataに追加
    func addCoreData(){
        let newItem = LightEntity(context: viewContext)
        newItem.no = no
        newItem.name = name
        try? viewContext.save()    // ディスクに保存
    }
    // CoreDataから削除
    func deleteCoreData(no: Int64){
        // CoreDataからIDでデータを抽出
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"LightEntity")
        fetchRequest.predicate = NSPredicate(format: "no = %@", no as CVarArg)
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
    func getCoreData(no : Int64) -> LightData?{
        var lightData : LightData?
        let fetchRequest: NSFetchRequest<LightEntity> = NSFetchRequest(entityName: "LightEntity")
        fetchRequest.predicate = NSPredicate(format: "no = %@", no as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let resultList = try viewContext.fetch(fetchRequest)
            lightData = LightData(entity: resultList[0], viewContext: viewContext)
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        return lightData
    }
}
// データを取得
extension LightDataList {
    // CoreDataからデータを取得
    init(viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LightEntity")
        do {
            let resultList = try viewContext.fetch(fetchRequest)
            self.list = []
            for data in resultList as! [LightEntity] {
                let lightData = LightData(entity:data, viewContext: viewContext)
                list.append(lightData)
            }
        } catch {
            print(error)
        }
    }
}
// 軽いデータ
public struct LightData {
    private var viewContext : NSManagedObjectContext    // CoreData
    private var no : Int64
    private var name : String
    
    // 初期処理：追加
    public init(no:Int64, name: String, viewContext : NSManagedObjectContext){
        self.no = no
        self.name = "name" + String(format: "%07d", no)
        self.viewContext = viewContext
        // CoreDataに追加
        addCoreData()
    }
    // 初期処理:CoreDataから設定
    public init(entity: LightEntity, viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
        self.no = entity.no
        self.name = entity.name!
    }
}
// 軽いデータのリスト
public struct LightDataList {
    private var viewContext : NSManagedObjectContext
    var list : [LightData] = []

    // データを指定数だけ追加
    public mutating func add (start:Int64, number:Int64) {
        let end = start + number    // 終了数を設定
        // データ数分の値を設定して、リストに追加
        for no in start ... end {
            let name = "name" + String(format: "%07d", no)
            let data = LightData(no: no, name: name, viewContext: viewContext)
            list.append(data)
        }
    }

}
