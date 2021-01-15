//
//  MySpot.swift
//  Sample8-CoreData
//
//  Created by keiji yamaki on 2021/01/13.
//
// 更新の種類：
import SwiftUI

enum UpdateType {
    case add, update, delete, done
}

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
/*
public class TestData : NSObject, NSCoding {
    var size : String
    var name : String
    
    override init(){
        self.size :CGSize = .zero
        self.name = "name"
    }
    public func encode(with coder: NSCoder) {
        coder.encode(self.size, forKey: "size")
        coder.encode(self.name, forKey: "name")
    }
    
    public required init?(coder: NSCoder) {
        self.size = coder.decodeObject(forKey: "size") as! String
        self.name = coder.decodeObject(forKey: "name")
        favoriteColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor ?? UIColor.black
    }
}
*/
