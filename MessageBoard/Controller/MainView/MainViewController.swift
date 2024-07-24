//
//  MainViewController.swift
//  MessageBoard
//
//  Created by imac-2627 on 2024/7/18.
//

import UIKit
import RealmSwift

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
    
    @IBAction func btnSentAciton(_ sender: Any) {
        let realm = try! Realm()
            if btnSent.currentTitle == "送出" {
                if let user = txfUser.text, let message = txvContent.text {
                    if !user.isEmpty && !message.isEmpty {
                        let currentTime = getSystemTime()
                        let newMessage = MessageBoard(name: user, content: message, currentTime: currentTime)
                        try! realm.write {
                            realm.add(newMessage)
                            if isAscending {
                                messageArray.append(newMessage)
                            } else {
                                messageArray.insert(newMessage, at: 0) //直接把值插入到ㄊrow的第一個位置
                            }
                            tbvTest.reloadData()
                            txfUser.text = ""
                            txvContent.text = ""
                        }
                        print("Added new message with time: \(currentTime)") // 這行是用來確定時間有被設定到
                    } else {
                        showAlert(message: "Please input name and content") //如果沒有輸入訊息，會跳出來叫使用者重新填
                    }
                }
            }
    }
    
    @IBAction func btnSortSection(_ sender: Any) {
        showSortOptions()
    }
    
    
    
    // MARK: - Function
    
    func setUI() {
        tableSet()
    }
    
    func tableSet() {
        tbvTest?.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.identified)
        tbvTest.dataSource = self
        tbvTest.delegate = self
    }
    
    func dataBase() {
        btnSent.setTitle("送出", for: .normal)
        let realm = try! Realm()
        let messageBoards = realm.objects(MessageBoard.self)
        messageArray = Array(messageBoards)
        sortMessages()
        tbvTest.reloadData()
        print("file : \(realm.configuration.fileURL!)")
    }
    
    
    func getSystemTime() -> String {
        let currentDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
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
    
    func sortMessages() {
        messageArray.sort { (messages1, messages2) -> Bool in
            if isAscending {
                return messages1.currentTime < messages2.currentTime
            } else {
                return messages1.currentTime > messages2.currentTime
            }
        }
    }
    
    
    func editMessage(_ message: MessageBoard, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "編輯", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = message.content
        }
        let saveAction = UIAlertAction(title: "保存", style:  .default) { [weak self] _ in
            guard let newContent = alertController.textFields?.first?.text, !newContent.isEmpty else {return}
            let realm = try! Realm()
            try! realm.write {
                message.content = newContent
                message.currentTime = self?.getSystemTime() ?? ""
            }
            self?.tbvTest.reloadRows(at: [indexPath], with: .automatic)
            
            self?.sortMessages()
            self?.tbvTest.reloadData()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteMessage(_ message: MessageBoard, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "刪除", message: "確定刪除嗎", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "確定", style:  .default) { [weak self] _ in
            let realm = try! Realm()
            try! realm.write {
                realm.delete(message)
            }
            self?.messageArray.remove(at: indexPath.row)
            self?.tbvTest.deleteRows(at: [indexPath], with: .fade)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showSortOptions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let ascendingAction = UIAlertAction(title: "時間升序", style: .default) { [weak self] _ in
            self?.isAscending = true
            self?.sortMessages()
            self?.tbvTest.reloadData()
        }
        
        let descendingAction = UIAlertAction(title: "時間降序", style: .default) { [weak self] _ in
            self?.isAscending = false
            self?.sortMessages()
            self?.tbvTest.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(ascendingAction)
        alertController.addAction(descendingAction)
        alertController.addAction(cancelAction)
        
        // 這裡是設定彈出視窗是要從排序按鈕按才會彈出來
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = btnSort
            popoverController.sourceRect = btnSort.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { //trailingSwipeActionsConfigurationForRowAt 這個是右滑的動作
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let message = self.messageArray[indexPath.row]
            self.deleteMessage(message, at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true // 滑動就可執行
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { //leadingSwipeActionsConfigurationForRowAt 這個是左滑的動作
        let editAction = UIContextualAction(style: .normal, title: "編輯") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let message = self.messageArray[indexPath.row]
            self.editMessage(message, at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tbvTest.dequeueReusableCell(withIdentifier: MainTableViewCell.identified, for: indexPath) as? MainTableViewCell else {
            return MainTableViewCell()
        }
        let message = messageArray[indexPath.row]
        cell.lbTest.text = "\(message.name): \(message.content)\n時間: \(message.currentTime)"
        return cell
    }
}
