//
//  result.swift
//  MLKit Final Project
//
//  Created by CLWang on 2021/5/16.
//  Copyright © 2021 AppCoda. All rights reserved.
//
import SQLite3
import SwiftUI
import UIKit
import Foundation
var glo_name_ch:String!
var glo_name_en:String!
var glo_property:String!
var glo_acne:Int!
var glo_pimple:Int!
func copyDatabaseIfNeeded() {
       // Move database file from bundle to documents folder
       let fileManager = FileManager.default
       let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
       guard documentsUrl.count != 0 else {
           return // Could not find documents URL
       }
       let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("database.db")
    do {
        try FileManager.default.removeItem(at: finalDatabaseURL)
        print("success to delete database")
    }catch{
        print("Fail to delete database")
    }
           let documentsURL = Bundle.main.resourceURL?.appendingPathComponent("database.db")
           do {
                 try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
                 } catch let error as NSError {
                   print("Couldn't copy file to final location! Error:\(error.description)")
           }
   }
var rows = [row]()
var states = [statements]()
var name_amount:Int!
class resultview: UIViewController{
    @IBOutlet weak var result: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label1: UITextView!
    @IBOutlet weak var label2: UITextView!
    @IBOutlet weak var alert1: UIImageView!
    @IBOutlet weak var alert2: UIImageView!
    var result_text:String!
    var db :SQLiteConnect? = nil
    let sqliteURL: URL = {
            do {
                return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("database.db")
            } catch {
                fatalError("Error getting file URL from document directory.")
            }
        }()
    var found:Bool!
    var choice: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        copyDatabaseIfNeeded()
        print (sqliteURL)
        name_amount = 0
        result.text = result_text
        let bounds = UIScreen.main.bounds
        result.frame = CGRect(x:20,y:bounds.size.height*0.55,width:bounds.size.width*0.9,height:bounds.size.height*0.3)
        let sqlitePath = sqliteURL.path
//        let statement = "select name_en, acne, pimple from " + "foundation_concealer" + " where name_en like \'% Water %\';"
//        sqlite3_finalize(statement)
        db = SQLiteConnect(path: sqlitePath)
        let table: String!
        switch choice {
        case 0:
             table = "physical_sunblock"
        case 1:
             table = "foundation_concealer"
        case 2:
             table = "lotion_toner"
        case 3:
            table = "all_data"
        default:
             table = "all_data"
        }
        let fullName1: String = result_text.replacingOccurrences(of: ",", with: "")
        let fullName2: String = fullName1.replacingOccurrences(of: ".", with: "")
        let fullNameArr = fullName2.components(separatedBy: " ")
        var ansstring = [String]()
        for n in fullNameArr{
            let fullNameArr2 = n.components(separatedBy: "\n")
            for nn in fullNameArr2{
                if (nn == ""){
                    
                }
                else {
                    ansstring.append(nn)
                }
            }
        }
        var index = 0
        for nn in ansstring{
            if let mydb = db{
                let statement = mydb.fetch("\(table!)", cond: "name_en like '\(nn)%'", order: "len desc;")
                if (statement == nil){
                    found=false;
                }
                else {
                    while sqlite3_step(statement) == SQLITE_ROW{
                        let name_en = String(cString: sqlite3_column_text(statement, 0))
                        let name_ch = String(cString: sqlite3_column_text(statement, 1))
                        let property = String(cString: sqlite3_column_text(statement, 2))
                        let acne = sqlite3_column_int(statement, 3)
                        let pimple = sqlite3_column_int(statement, 4)
                        var len = sqlite3_column_int(statement, 5)
                        var flag2 = false
                        if (len>1){
                            let name_long = name_en.components(separatedBy: " ")
                            len -= 1
                            for i in 1...len{
                                if (index+Int(i)>=ansstring.count){
                                    flag2 = true
                                    break
                                }
                                else if (name_long[Int(i)].caseInsensitiveCompare(ansstring[index+Int(i)]) == .orderedSame){}else {
                                    flag2 = true
                                }
                                print("\(name_long[Int(i)]) \(ansstring[index+Int(i)])")
                            }
                            if (flag2 == false){
                                print("\(name_en). \(name_ch) \(property) \(acne) \(pimple)")
                                found_add(name_en: name_en, name_ch: name_ch, property: property, acne: Int(acne), pimple: Int(pimple))
                                break;
                            }
                        }
                        else {
                            print("\(name_en). \(name_ch) \(property) \(acne) \(pimple)")
                            found_add(name_en: name_en, name_ch: name_ch, property: property, acne: Int(acne), pimple: Int(pimple))
                        }
                    }
                }
                sqlite3_finalize(statement)
            }
            index += 1
        }
        var acne = 0
        var pimple = 0
        var acne_count = 0
        var pimple_count = 0
        for rr in rows{
            if (rr.acne>0){
                acne_count+=1
            }
            if (rr.pimple>0){
                pimple_count += 1
            }
            acne += rr.acne
            pimple += rr.pimple
        }
        alert1.frame = CGRect(x: bounds.size.width*1/10, y: bounds.size.height*8/10, width: 40, height: 40)
        alert2.frame = CGRect(x: bounds.size.width*8/10, y: bounds.size.height*8/10, width: 40, height: 40)
        if (acne>0){
            acne/=acne_count
            label1.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            alert1.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        }else{
            label1.textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
            alert1.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0)
        }
        if (pimple>0){
            pimple/=pimple_count
            label2.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            alert2.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        }else{
            label2.textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
            alert2.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0)
        }
        label1.text = "\(acne)"
        label2.text = "\(pimple)"
//        for n in fullNameArr{
//            let fullNameArr2 = n.components(separatedBy: "\n")
//            for nn in fullNameArr2{
//                if let mydb = db{
//                    let statement = mydb.fetch("\(table!)", cond: "name_en like '\(nn)'%", order: "len desc;")
//                    if (statement == nil){
//                        found=false;
//                    }
//                    var count1:Int!
//                    while sqlite3_step(statement) == SQLITE_ROW{
//                        count1+=1
//                    }
//                    if (count1>1){
//
//                    }
//                    else {
//                        while sqlite3_step(statement) == SQLITE_ROW{
//                            let name_en = String(cString: sqlite3_column_text(statement, 0))
//                            let name_ch = String(cString: sqlite3_column_text(statement, 1))
//                            let property = String(cString: sqlite3_column_text(statement, 2))
//                            let acne = sqlite3_column_int(statement, 3)
//                            let pimple = sqlite3_column_int(statement, 4)
//                            print("\(name_en). \(name_ch) \(property) \(acne) \(pimple)")
//                            found_add(name_en: name_en, name_ch: name_ch, property: property, acne: Int(acne), pimple: Int(pimple))
//                        }
//                    }
//                    sqlite3_finalize(statement)
//                }
//            }
//        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView?.addSubview(UIView(frame: .zero))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! detailview
        destinationVC.name_ch = glo_name_ch
        destinationVC.name_en = glo_name_en
        destinationVC.acne = glo_acne
        destinationVC.property = glo_property
        destinationVC.pimple = glo_pimple
    }
    
}
func found_add(name_en:String,name_ch:String,property:String,acne:Int,pimple:Int){
    var flag = false
    for rr in rows{
        if (rr.name_en == name_en){
            flag = true
        }
    }
    if (flag){}else{
        let new_row = row()
        new_row.name_en = name_en
        new_row.name_ch = name_ch
        new_row.property = property
        new_row.acne = acne
        new_row.pimple = pimple
        rows.append(new_row)
        name_amount += 1
    }
}

extension resultview: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int(0)
        for _ in rows{
            count+=1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var ii:Int!
        ii = 0;
        if(rows.isEmpty){
            if indexPath.row==1{
                cell.textLabel?.text = "no ingredient found!"
            }
            return cell
        }
        for single_row in rows{
            if indexPath.row == ii {
                cell.textLabel?.text = single_row.name_en
            }
            ii += 1;
        }
        let footer = UIView(frame: .zero)
        tableView.tableFooterView = footer
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var ii = Int(0)
        tableView.deselectRow(at: indexPath, animated: true)
        for single_row in rows{
            if indexPath.row == ii {
                glo_name_en = single_row.name_en
                glo_name_ch = single_row.name_ch
                glo_property = single_row.property
                glo_acne = single_row.acne
                glo_pimple = single_row.pimple
                performSegue(withIdentifier: "detail", sender: self)
            }
            ii += 1;
        }
    }
}
class row {
    var name_ch:String!
    var name_en:String!
    var property:String!
    var acne:Int!
    var pimple:Int!
}
class statements{
    var statement:OpaquePointer!
    var match:Int!
}
