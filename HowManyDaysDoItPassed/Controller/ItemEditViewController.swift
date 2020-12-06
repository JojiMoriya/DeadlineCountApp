//
//  ItemEditViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/11.
//

import UIKit
import RealmSwift

class ItemEditViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var editItemTitleTextFiled: UITextField!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var editItemTextView: UITextView!
    @IBOutlet weak var limitDateSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationDateTextFiled: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    private var nowDate:String!
    private var AselectedDate:Date!
    private var BselectedDate:Date!
    private var APicker: UIDatePicker!
    private var ATextField = UITextField()
    private var BPicker: UIDatePicker!
    private var BTextField = UITextField()
    
    var editedItemTitle = ""
    var editedLaunchDate = Date()
    var editedLimitDate = Date()
    var editedItemMemo = ""
    
    var notificationID = ""
    var notificationDate = ""
    
    var pickerView: UIPickerView = UIPickerView()
    let list = ["1", "2", "3", "4", "5", "6", "7"]
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    
    var editItemIndexPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRealm()
        makeNowDate()
        makePickerBaseView(true)
        makePickerBaseView(false)
        setAllContent()
        setlimitDatePicker()
        setEditItemNotification()
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if itemList[editItemIndexPath].notificationDate != "" {
            let selectRow = Int(itemList[editItemIndexPath].notificationDate)! - 1
            pickerView.selectRow(selectRow, inComponent: 0, animated: false)
        } 
    }
    
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    //MARK: - DatePickerの実装
    func makeNowDate(){
        AselectedDate = itemList[editItemIndexPath].launchDate
        if itemList[editItemIndexPath].launchDate != itemList[editItemIndexPath].limitDate {
            BselectedDate = itemList[editItemIndexPath].limitDate
        } else {
            let launchDay = itemList[editItemIndexPath].launchDate
            let nextDay = Calendar.current.date(byAdding: .day, value: +1, to: launchDay)!
            BselectedDate = nextDay
        }
    }
    
    func makePickerBaseView(_ isA:Bool) {
        var myTextField = UITextField()
        myTextField = makeTextField(isA)
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy年M月d日"

        if isA {
            ATextField = myTextField
            firstView.addSubview(ATextField)
        } else {
            BTextField = myTextField
            secondView.addSubview(BTextField)
        }
    }
    
    func makeTextField(_ isA:Bool) -> UITextField {
        let myTextField:UITextField!
        myTextField = UITextField(frame: CGRect(x: 2, y: 2, width:230, height: 56))
        
        myTextField.delegate = self
        myTextField.layer.cornerRadius = 20
        myTextField.layer.borderWidth = 1.5
        myTextField.layer.borderColor = UIColor.white.cgColor
        myTextField.font = UIFont.systemFont(ofSize: CGFloat(20))
        myTextField.textColor = UIColor.black
        myTextField.backgroundColor = UIColor.systemGray6
        myTextField.tintColor = UIColor.clear //キャレット(カーソル)を消す。

        if isA {
            APicker = makePicker(isA)
            myTextField.inputView = APicker
        } else {
            BPicker = makePicker(isA)
            myTextField.inputView = BPicker
        }
        myTextField.textAlignment = .center
        
        return myTextField
    }
    
    func makePicker(_ isA:Bool) -> UIDatePicker {
        let myPicker:UIDatePicker!
        myPicker = UIDatePicker()
        myPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200.0)
        myPicker.tag = isA ? 1 : 2
        myPicker.datePickerMode = .date
        myPicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        myPicker.preferredDatePickerStyle = .wheels
        myPicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
        
        return myPicker
    }
    
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        
        let mySelectedDate = formatter.string(from: sender.date)
        if sender.tag == 1 {
            ATextField.text = mySelectedDate
            AselectedDate = sender.date
        } else {
            BTextField.text = mySelectedDate
            BselectedDate = sender.date
        }
        
        if sender.tag == 1 {
            let minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: AselectedDate)!
            BPicker.minimumDate = minimumDate
            if AselectedDate > BselectedDate {
                BTextField.text = (formatter.string(from: minimumDate))
                BPicker.date = minimumDate
            }
            if notificationSwitch.isOn == true {
                let untilDay = notificationDateTextFiled.text
                let day = Int(untilDay!)! * -1
                let limitday = BselectedDate!
                let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
                if notificationDay <= AselectedDate {
                    alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
                    saveButton.isEnabled = false
                    saveButton.setTitleColor(UIColor.systemGray4, for: .normal)
                } else {
                    if editItemTitleTextFiled.text != "" {
                        saveButton.isEnabled = true
                        saveButton.setTitleColor(UIColor.black, for: .normal)
                    }
                }
            }
        } else {
            if notificationSwitch.isOn == true {
                let untilDay = notificationDateTextFiled.text
                let day = Int(untilDay!)! * -1
                let limitday = BselectedDate!
                let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
                if notificationDay <= AselectedDate {
                    alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
                    saveButton.isEnabled = false
                    saveButton.setTitleColor(UIColor.systemGray4, for: .normal)
                } else {
                    if editItemTitleTextFiled.text != "" {
                        saveButton.isEnabled = true
                        saveButton.setTitleColor(UIColor.black, for: .normal)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        editItemTitleTextFiled.endEditing(true)
        ATextField.endEditing(true)
        BTextField.endEditing(true)
        editItemTextView.endEditing(true)
        notificationDateTextFiled.endEditing(true)
    }
    
    //MARK: - 編集前コンテンツの設定
    
    func setAllContent() {
        editItemTitleTextFiled.text = itemList[editItemIndexPath].itemTitle
        ATextField.text = dateFormat(date: itemList[editItemIndexPath].launchDate)
        AselectedDate = itemList[editItemIndexPath].launchDate
        APicker.date = itemList[editItemIndexPath].launchDate
        BTextField.text = setLimitDate()
        if itemList[editItemIndexPath].launchDate == itemList[editItemIndexPath].limitDate {
            let launchDay = itemList[editItemIndexPath].launchDate
            let nextDay = Calendar.current.date(byAdding: .day, value: +1, to: launchDay)!
            BselectedDate = nextDay
            BPicker.date = nextDay
        } else {
            BselectedDate = itemList[editItemIndexPath].limitDate
            BPicker.date = itemList[editItemIndexPath].limitDate
        }
        
        notificationDateTextFiled.inputView = pickerView
        
        editItemTextView.text = itemList[editItemIndexPath].itemMemo
        editItemTextView.layer.borderColor = UIColor.systemGray4.cgColor
        editItemTextView.layer.borderWidth = 1
        editItemTextView.layer.cornerRadius = 20
        editItemTextView.backgroundColor = UIColor.systemGray6
        saveButton.layer.cornerRadius = 20
        
        if itemList[editItemIndexPath].notificationDate != "" {
            notificationDateTextFiled.text = itemList[editItemIndexPath].notificationDate
            let inComponent = Int(itemList[editItemIndexPath].notificationDate)! - 1
            print(inComponent)
            pickerView.selectRow(inComponent, inComponent: 0, animated: false)
        } else {
            notificationDateTextFiled.text = list[0]
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    func setLimitDate() -> String{
        if itemList[editItemIndexPath].launchDate == itemList[editItemIndexPath].limitDate {
            limitDateSwitch.isOn = false
            let launchDay = itemList[editItemIndexPath].launchDate
            let nextDay = Calendar.current.date(byAdding: .day, value: +1, to: launchDay)!
            return dateFormat(date: nextDay)
        } else {
            limitDateSwitch.isOn = true 
            return dateFormat(date: itemList[editItemIndexPath].limitDate)
        }
    }
    
    func setlimitDatePicker() {
        if itemList[editItemIndexPath].limitDate != itemList[editItemIndexPath].launchDate {
            BPicker.date = itemList[editItemIndexPath].limitDate
        } else {
            BPicker.date = Date()
            BPicker.minimumDate = itemList[editItemIndexPath].launchDate
        }
    }
    
    func setEditItemNotification() {
        if itemList[editItemIndexPath].notificationDate != "" {
            notificationSwitch.isOn = true
            notificationDateTextFiled.text = itemList[editItemIndexPath].notificationDate
            let selectRow = Int(itemList[editItemIndexPath].notificationDate)! - 1
            pickerView.selectRow(selectRow, inComponent: 0, animated: false)
        } else {
            notificationSwitch.isOn = false
            notificationDateTextFiled.text = list[0]
        }
    }
    
    func setNotification() {
        let notificationTitle = editItemTitleTextFiled.text
        let untilDay = notificationDateTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        
        var dateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day], from: notificationDay)
        dateComponents.hour = 12
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "もうすぐ期限日です"
        content.body = "「\(notificationTitle!)」の期限日まであと\(untilDay!)日です"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = NSUUID().uuidString
        notificationID = identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func dateFormat(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    //MARK: - TitleTextFieldのデリゲートメソッド
    @IBAction func checkTitleIsNil(_ sender: UITextField) {
        if sender.text == "" {
            saveButton.isEnabled = false
            saveButton.setTitleColor(UIColor.systemGray4, for: .normal)
        } else {
            saveButton.isEnabled = true
            saveButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    //MARK: - 通知スウィッチのデリゲートメソッド
    @IBAction func checkNotificationIsCollect(_ sender: UISwitch) {
        if notificationSwitch.isOn == true {
            let untilDay = notificationDateTextFiled.text
            let day = Int(untilDay!)! * -1
            let limitday = BPicker.date
            let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
            if notificationDay <= Date() {
                saveButton.isEnabled = false
                saveButton.setTitleColor(UIColor.systemGray4, for: .normal)
            } else {
                if editItemTitleTextFiled.text != "" {
                    saveButton.isEnabled = true
                    saveButton.setTitleColor(UIColor.black, for: .normal)
                }
            }
        } else {
            if editItemTitleTextFiled.text != "" {
                saveButton.isEnabled = true
                saveButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    //MARK: - セーブボタンが押された際のメソッド
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        editedItemTitle = editItemTitleTextFiled.text ?? ""
        editedLaunchDate = AselectedDate
        if limitDateSwitch.isOn == true {
            editedLimitDate = BselectedDate
        } else {
            editedLimitDate = AselectedDate
        }
        editedItemMemo = editItemTextView.text
        
        if itemList[editItemIndexPath].notificationID != "" {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemList[editItemIndexPath].notificationID])
        }
        
        if notificationSwitch.isOn == true && limitDateSwitch.isOn == true {
            notificationDate = notificationDateTextFiled.text ?? ""
            setNotification()
        }
        
        performSegue(withIdentifier: "unwindFromEditVC", sender: nil)
    }
    
    func alert (title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ItemEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.notificationDateTextFiled.text = list[row]
        let untilDay = notificationDateTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        if notificationDay <= Date() {
            alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    
}
