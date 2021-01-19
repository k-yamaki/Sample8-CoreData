//
//  FatData.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/19.
//


import SwiftUI
import CoreData

// FatDataのコアデータ操作処理
extension FatData {
    // CoreDataに追加
    func addCoreData(){
        let newItem = FatEntity(context: viewContext)
        newItem.no = no
        newItem.image = image.pngData()
        try? viewContext.save()    // ディスクに保存
    }
    // CoreDataから削除
    func deleteCoreData(no: Int64){
        // CoreDataからIDでデータを抽出
        let fetchRequest = NSFetchRequest<FatEntity>(entityName:"FatEntity")
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
    func getCoreData(no : Int64) -> FatData?{
        var fatData : FatData?
        let fetchRequest: NSFetchRequest<FatEntity> = NSFetchRequest(entityName: "FatEntity")
        fetchRequest.predicate = NSPredicate(format: "no = %@", no as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let resultList = try viewContext.fetch(fetchRequest)
            fatData = FatData(entity: resultList[0], viewContext: viewContext)
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        return fatData
    }
}
// データを取得
extension FatDataList {
    // CoreDataからデータを取得
    init(viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FatEntity")
        do {
            let resultList = try viewContext.fetch(fetchRequest)
            self.list = []
            for data in resultList as! [FatEntity] {
                let fatData = FatData(entity:data, viewContext: viewContext)
                list.append(fatData)
            }
        } catch {
            print(error)
        }
    }
}
// 軽いデータ
public struct FatData {
    private var viewContext : NSManagedObjectContext    // CoreData
    private var no : Int64
    private var image : UIImage
    
    // 初期処理：追加
    public init(no:Int64, viewContext : NSManagedObjectContext){
        self.no = no
        self.image = UIImage(named: "sample")!
        self.viewContext = viewContext
        // CoreDataに追加
        addCoreData()
    }
    // 初期処理:CoreDataから設定
    public init(entity: FatEntity, viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
        self.no = entity.no
        self.image = UIImage(data: entity.image!)!
    }
}
// 軽いデータのリスト
public struct FatDataList {
    private var viewContext : NSManagedObjectContext
    var list : [FatData] = []

    // データを指定数だけ追加
    public mutating func add (start:Int64, number:Int64) {
        let end = start + number    // 終了数を設定
        // データ数分の値を設定して、リストに追加
        for no in start ... end {
            let data = FatData(no: no, viewContext: viewContext)
            list.append(data)
        }
    }

}
