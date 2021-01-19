//
//  MySpot.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/13.
//
/*
 CoreDataの項目に構造体の配列データを保存する方法
 JSON形式でエンコード、デコードする
 */
import SwiftUI

enum UpdateType {
    case add, update, delete, done
}

var testData: [TestData] = [TestData(name:"test1", favoriteColor: .white, rect: CGRect(x:10, y:20, width:100, height:50)),
    TestData(name:"test2", favoriteColor: .black, rect: CGRect(x:10, y:20, width:100, height:50)),
    TestData(name:"test3", favoriteColor: .red, rect: CGRect(x:10, y:20, width:100, height:50))]


struct TestData {
    var name: String
    var favoriteColor: UIColor
    var rect: CGRect
}

extension TestData: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case favoriteColor
        case rect
    }
    // デコード
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        let colorData = try container.decode(Data.self, forKey: .favoriteColor)
        favoriteColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor ?? UIColor.black
        let rectData = try container.decode(Data.self, forKey: .rect)
        rect = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rectData) as? CGRect ?? .zero
    }
    // エンコード
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)

        let colorData = try NSKeyedArchiver.archivedData(withRootObject: favoriteColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .favoriteColor)
        
        let rectData = try NSKeyedArchiver.archivedData(withRootObject: rect, requiringSecureCoding: false)
        try container.encode(rectData, forKey: .rect)
    }
    
}
