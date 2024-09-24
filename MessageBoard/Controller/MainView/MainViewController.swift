//
//  MainViewController.swift
//  MessageBoard
//
//  Created by imac-2627 on 2024/7/18.
//

import UIKit
import RealmSwift // 導入 Realm 套件

class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lbComments: UILabel!
    @IBOutlet weak var lbUser: UILabel!
    @IBOutlet weak var tbvTest: UITableView!
    @IBOutlet weak var txvContent: UITextView!
    @IBOutlet weak var btnSent: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var txfUser: UITextField!
    
    
    // MARK: - Property
    
    var messageArray: [MessageBoard] = [] //把名字、內容、時間儲存在這個陣列
    var isAscending = false //用來跟蹤排序的順序的，true的話是升序，false是降序
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        dataBase()
    }
    
    
    // MARK: - UI Settings
    
    // MARK: - IBAction
    
    // 送出按鈕
    @IBAction func btnSentAciton(_ sender: Any) {
        
        // 使用Realm套件
        let realm = try! Realm()
        
            // 判斷是否為送出按鈕
            if btnSent.currentTitle == "送出" {
                
                if let user = txfUser.text, let message = txvContent.text {
                    
                    // 確認有輸入使用者名稱和留言內容
                    if !user.isEmpty && !message.isEmpty {
                        
                        // 抓取送出留言的時間
                        let currentTime = getSystemTime()
                        
                        // 將內容存為MessageBoard格式
                        let newMessage = MessageBoard(name: user, content: message, currentTime: currentTime)
                        
                        // 寫入Realm資料庫
                        try! realm.write {
                            realm.add(newMessage)
                            
                            // 如果isAscending是true(升序)，就加到陣列的最後面，就是由舊到新的概念
                            if isAscending {
                                messageArray.append(newMessage)
                                
                            // 如果是false(由新到舊)，就放到陣列的最前面
                            } else {
                                messageArray.insert(newMessage, at: 0) // 直接把值插入到row的第一個位置
                            }
                            
                            // 刷新
                            tbvTest.reloadData()
                            
                            // 送出完成之後，將使用者名稱和內容變為空白
                            txfUser.text = ""
                            txvContent.text = ""
                        }
                        print("Added new message with time: \(currentTime)") // 這行是用來確定時間有被設定到
                    } else {
                        showAlert(message: "請輸入使用者名稱和內容") // 如果沒有輸入訊息，會跳出來叫使用者重新填
                    }
                }
            }
    }
    
    @IBAction func btnSortSection(_ sender: Any) {
        
        // 排序
        showSortOptions()
    }
    
    
    
    // MARK: - Function
    
    // UI設定
    func setUI() {
        tableSet()
        btnSent.setTitle("送出", for: .normal) // 送出按鈕初始化
    }
    
    // tableView設定
    func tableSet() {
        
        // 註冊 cell
        tbvTest?.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.identified)
        
        // 設置代理
        tbvTest.dataSource = self
        tbvTest.delegate = self
    }
    
    func dataBase() {
        let realm = try! Realm()
        let messageBoards = realm.objects(MessageBoard.self)
        messageArray = Array(messageBoards)
        sortMessages()
        tbvTest.reloadData()
        print("file :a \(realm.configuration.fileURL!)")
    }
    
    
    // 抓取系統時間
    func getSystemTime() -> String {
        let currentDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        
        // 設定格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currentDate)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 排序
    func sortMessages() {
        
        // 閉包寫法
        messageArray.sort { (messages1, messages2) -> Bool in
            
            //如果是升序就由小排到大，不是的話就由大排到小
            if isAscending {
                return messages1.currentTime < messages2.currentTime
            } else {
                return messages1.currentTime > messages2.currentTime
            }
        }
    }
    
    
    // editMessage 是用來處理編輯訊息的動作
    func editMessage(_ message: MessageBoard, at indexPath: IndexPath) {
        // 彈出一個警告視窗，讓使用者可以編輯訊息內容
        let alertController = UIAlertController(title: "編輯", message: nil, preferredStyle: .alert)
        
        // 在警告視窗中加入一個文字輸入框，並將訊息的當前內容顯示在輸入框中
        alertController.addTextField { textField in
            textField.text = message.content
        }
        
        // 定義一個保存動作
        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            // 確認新的內容不為空，並從輸入框中取得新的內容
            guard let newContent = alertController.textFields?.first?.text, !newContent.isEmpty else { return }
            
            // 初始化 Realm 資料庫
            let realm = try! Realm()
            
            // 在 Realm 中寫入變更，更新訊息的內容和當前時間
            try! realm.write {
                message.content = newContent
                message.currentTime = self?.getSystemTime() ?? ""
            }
            
            // 更新表格中的當前列，讓新的內容顯示出來
            self?.tbvTest.reloadRows(at: [indexPath], with: .automatic)
            
            // 將訊息重新排序並重新載入表格
            self?.sortMessages()
            self?.tbvTest.reloadData()
        }
        
        // 定義一個取消動作，取消操作不做任何變更
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 將保存和取消的動作加入到警告視窗中
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        // 顯示警告視窗
        present(alertController, animated: true, completion: nil)
    }

    
    // deleteMessage 是用來處理刪除訊息的動作
    func deleteMessage(_ message: MessageBoard, at indexPath: IndexPath) {
        
        // 彈出一個警告視窗，詢問使用者是否確認刪除
        let alertController = UIAlertController(title: "刪除", message: "確定刪除嗎", preferredStyle: .alert)
        
        // 定義一個確定刪除的動作
        let deleteAction = UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            // 初始化 Realm 資料庫
            let realm = try! Realm()
            
            // 在 Realm 中寫入變更，刪除該訊息
            try! realm.write {
                realm.delete(message)
            }
            
            // 從資料源中移除該訊息，並更新表格
            self?.messageArray.remove(at: indexPath.row)
            self?.tbvTest.deleteRows(at: [indexPath], with: .fade)
        }
        
        // 定義一個取消動作，取消操作不做任何變更
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 將確定和取消的動作加入到警告視窗中
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // 顯示警告視窗
        present(alertController, animated: true, completion: nil)
    }

    
    // 排序按鈕的function
    func showSortOptions() {
        
        // 命名一個空的警告彈窗
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 升序選項
        let ascendingAction = UIAlertAction(title: "時間升序", style: .default) { [weak self] _ in
            
            // 改變追蹤排序的變數
            self?.isAscending = true
            
            // 利用前面改變的追蹤的變數做排序
            self?.sortMessages()
            
            // 刷新頁面
            self?.tbvTest.reloadData()
        }
        
        // 降序選項
        let descendingAction = UIAlertAction(title: "時間降序", style: .default) { [weak self] _ in
            
            // 改變追蹤排序的變數
            self?.isAscending = false
            
            // 利用前面改變的追蹤的變數做排序
            self?.sortMessages()
            
            // 刷新頁面
            self?.tbvTest.reloadData()
        }
        
        // 取消選項
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 將上面的選項加入最開始命名的空的警告彈窗
        alertController.addAction(ascendingAction)
        alertController.addAction(descendingAction)
        alertController.addAction(cancelAction)
        
        // 這裡是設定彈出視窗是要從排序按鈕按才會彈出來
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = btnSort
            popoverController.sourceRect = btnSort.bounds
        }
        
        // 呼叫出alerController
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 顯示幾行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 利用新增的留言內容數量去控制他要顯示有幾行
        return messageArray.count
    }
    
    // tableView顯示的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 把要用到的tableViewCell命名為一個cell常數，後面好做使用
        guard let cell = tbvTest.dequeueReusableCell(withIdentifier: MainTableViewCell.identified, for: indexPath) as? MainTableViewCell else {
            return MainTableViewCell()
        }
        
        // 將messageArray儲存的每筆資料變為一個常數並呼叫，讓tableView顯示
        let message = messageArray[indexPath.row]
        cell.lbTest.text = "\(message.name): \(message.content)\n時間: \(message.currentTime)"
        return cell
    }
    
    // trailingSwipeActionsConfigurationForRowAt 是用來處理表格左滑的動作
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 定義一個刪除的動作，當使用者左滑時會顯示 "刪除" 選項
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (_, _, completionHandler) in
            
            // 使用 weak self 防止循環引用
            guard let self = self else { return }
            
            // 根據當前滑動的列，獲取對應的訊息
            let message = self.messageArray[indexPath.row]
            
            // 刪除該訊息並更新表格
            self.deleteMessage(message, at: indexPath)
            
            // 操作完成後，告訴系統這個動作已經處理完畢
            completionHandler(true)
        }
        // 設定刪除動作的背景顏色為紅色
        deleteAction.backgroundColor = .red
        
        // 將刪除動作加入配置中
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        // 設定當使用者完全滑動時，自動執行第一個動作（刪除）
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    
    // leadingSwipeActionsConfigurationForRowAt 是用來處理表格右滑的動作
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 定義一個編輯的動作，當使用者右滑時會顯示 "編輯" 選項
        let editAction = UIContextualAction(style: .normal, title: "編輯") { [weak self] (_, _, completionHandler) in
            // 使用 weak self 防止循環引用
            guard let self = self else { return }
            // 根據當前滑動的列，獲取對應的訊息
            let message = self.messageArray[indexPath.row]
            // 編輯該訊息並更新表格
            self.editMessage(message, at: indexPath)
            // 操作完成後，告訴系統這個動作已經處理完畢
            completionHandler(true)
        }
        // 設定編輯動作的背景顏色為藍色
        editAction.backgroundColor = .blue
        
        // 將編輯動作加入配置中
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        // 設定當使用者完全滑動時，自動執行第一個動作（編輯）
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
