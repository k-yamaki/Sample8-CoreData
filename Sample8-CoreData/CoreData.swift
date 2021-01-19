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

