//
//  AddEventViewController.swift
//  spotimusic
//
//  Created by BQ_Tech on 16/08/18.
//

import UIKit
import MobileCoreServices
import Alamofire
import CoreData
import Kingfisher
import SWRevealViewController
import Reachability
import SVProgressHUD
import SCLAlertView
class AddEventViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var pictureButton: GIAButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var eventAddressTextField: AOTextField!
    @IBOutlet weak var eventNameTextField: AOTextField!
    @IBOutlet weak var startDateTextField: AOTextField!
    
    @IBOutlet weak var endDateTextField: AOTextField!
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var webSiteLinkTextField: AOTextField!
    @IBOutlet weak var webSiteLinkLabel: UILabel!
    @IBOutlet weak var choosePlanTextField: UITextField!
     var eventImage: String!
    var reachabilitysz: Reachability!
    var update_EventId : String?
    var update_EventName : String?
    var update_EventAddress : String?
    var update_EventFromDate : String?
    var update_EventToDate : String?
    var update_EventImage : String?
    var update_EventWebsiteLink : String?
    var isUpdate = false
    var planArray = [[String:AnyObject]]()
    let pickerView = UIPickerView()
    var eventPlanId = ""
       let toolbar = UIToolbar()
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            reachabilitysz = try Reachability()
        }catch{
            
        }
        //reachabilitysz = Reachability()
        if (reachabilitysz?.isReachable)!{
            
            //self.checkUserLogin()
            
        } else {
        }
        //start date picker
        if isUpdate {
            eventNameTextField.text = update_EventName
            eventAddressTextField.text = update_EventAddress
            startDateTextField.text = update_EventFromDate
            endDateTextField.text = update_EventToDate
            webSiteLinkTextField.text = update_EventWebsiteLink
            eventImageView.isHidden = false
            eventImage = update_EventImage
             let imgeFile = String(format: "%@%@%@",BASE_AMAZON_ENDPOINT,EVENTS,update_EventImage!)
            let url = URL(string: imgeFile)
            eventImageView.kf.setImage(with: url)
            createButton.setTitle("Update", for: .normal)
           // webSiteLinkTextField.isHidden = false
           // webSiteLinkLabel.isHidden = false
            choosePlanTextField.isHidden = true
            title = "Update Event"
        } else {
            title = "Add Event"
            createButton.setTitle("Create", for: .normal)
           // webSiteLinkTextField.isHidden = true
           // webSiteLinkLabel.isHidden = true
        }
        pictureButton.leftImg(image: UIImage(named: "camera")!, renderMode: .alwaysOriginal)
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.white
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(AddEventViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = "Select a start date"
        label.textAlignment = NSTextAlignment.center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        startDateTextField.inputAccessoryView = toolBar
        //end date picker
        let tool_Bar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        tool_Bar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        tool_Bar.barStyle = UIBarStyle.blackTranslucent
        tool_Bar.tintColor = UIColor.white
        tool_Bar.backgroundColor = UIColor.white
        
        let ok_BarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(AddEventViewController.donePressed))
        
        let flex_Space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label1.font = UIFont(name: "Helvetica", size: 12)
        label1.backgroundColor = UIColor.clear
        label1.textColor = UIColor.white
        label1.text = "Select a start date"
        label1.textAlignment = NSTextAlignment.center
        
        let text_Btn = UIBarButtonItem(customView: label1)
        tool_Bar.setItems([flex_Space,text_Btn,flex_Space,ok_BarBtn], animated: true)
        endDateTextField.inputAccessoryView = toolBar
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        getAllplan()
        let trackInlist = UserDefaults.standard.bool(forKey: "isTrackInList")
        if trackInlist == true {
            if ((AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) == .playing){
                UserDefaults.standard.set(false, forKey: "isTrackInList")
                UserDefaults.standard.synchronize()
            }
        }else {
            if ((AudioPlayer.sharedAudioPlayer.playlist?.count() != nil) && (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) != .paused) {
                MiniPlayerView.sharedInstance.displayView(presentingViewController: self)
            }else {
                MiniPlayerView.sharedInstance.cancelButtonClicked()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerViewClicked), name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "miniAudioPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func playerViewClicked() {
        let controller = RadioStreamViewController.sharedInstance
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @objc func donePressed(_ sender: UIBarButtonItem) {
        startDateTextField.resignFirstResponder()
        endDateTextField.resignFirstResponder()
    }

    
@IBAction func txtstartDateClicked(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.minimumDate = Date()
        datePickerView.backgroundColor = UIColor.white
    datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
    datePickerView.addTarget(self, action: #selector(AddEventViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func txtEndDateClicked(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.minimumDate = Date()
        datePickerView.backgroundColor = UIColor.white
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddEventViewController.datePicker_ValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePicker_ValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.dateFormat = "yyyy-MM-dd"
        endDateTextField.text = dateFormatter.string(from: sender.date)
    }
    func chooseAlbum(){
        let alert = UIAlertController(title: "select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes    =   [kUTTypeImage as String]
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photoLibrary = UIAlertAction(title: "PhotoLibrary", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.mediaTypes    =   [kUTTypeImage as String]
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibrary)
        alert.addAction(cancleAction)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){

        if let pickedImage = info[.editedImage] as? UIImage {
            
            self.eventImageView.image = pickedImage
        }
        dismiss(animated: true, completion: {
            self.changez()
            
        })
    }
    
    func changez(){
        let url = URL(string:String(format: "%@%@", BASE_URL_BACKEND,ENDPOINT_UPLOAD_EVENT_IMAGE))
        //  print("Updateurl",url)
        let goupload = ImageWebUpload()
        let cropping = ImageResizer()
        goupload.imageUploadRequest(image: self.eventImageView.image!, uploadUrl: url! as NSURL, param: ["X-API-KEY":API_GENERAL_KEY]) { (success) in
            if(success){
                let thisImage = goupload.urlimage
                self.eventImage = thisImage
                
            }
        }
    }
    func addEvent(_ imageUrl : String ,eventName : String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
    
        if let  userId = GLOBAL_USER_ID {
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ADD_EVENT)
            print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"user_id":userId.stringValue,"name":eventName,"address": eventAddressTextField.text!,"from_date": startDateTextField.text!,"to_date":endDateTextField.text!,"image": imageUrl,"website_link": webSiteLinkTextField.text!,"event_plan_id": eventPlanId])
                       .responseJSON { response in
                           SVProgressHUD.dismiss()
                           switch response.result {
                           case .success:
                               print("response",response)
                               guard let item = response.result.value as! NSDictionary? else {return}
                               if let message = item.value(forKey: "message") as? String {
                                   let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                                   }
                                   let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                                   SCLAlertView().showTitle("Add Event", subTitle: message, timeout: time, completeText: "Done", style: .success)
                                   self.navigationController?.popViewController(animated: true)
                               }
                           case .failure(let error):
                               print(error)
                               let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                               DispatchQueue.main.async {
                                   self.present(alert, animated: true, completion: nil)
                               }
                           }
                           
                   }
        }
       
    }
    
    
    func updateEvent(_ editImageUrl : String ,editEventName : String){
        SVProgressHUD.show()
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        
        if let  userId = GLOBAL_USER_ID {
            let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_UPDATE_EVENT)
            print(urlResponce)
            Alamofire.request( urlResponce,method: .post ,parameters: ["X-API-KEY": API_GENERAL_KEY,"event_id":update_EventId!,"user_id":userId.stringValue,"name":editEventName,"address": eventAddressTextField.text!,"from_date": startDateTextField.text!,"to_date":endDateTextField.text!,"image": editImageUrl,"website_link":webSiteLinkTextField.text!])
                .responseJSON { response in
                    SVProgressHUD.dismiss()
                    switch response.result {
                    case .success:
                        print("response",response)
                        guard let item = response.result.value as! NSDictionary? else {return}
                        if let message = item.value(forKey: "message") as? String {
                            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                            }
                            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
                            SCLAlertView().showTitle("Update Event", subTitle: message, timeout: time, completeText: "Done", style: .success)
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                
            }
        }
        
    }
    
    
    @IBAction func selectPicButtonAction(_ sender: Any) {
        self.chooseAlbum()
    }
    
    @IBAction func createButtonAction(_ sender: Any) {
        
        let trimeName = eventNameTextField.text
        let event_Name = trimeName?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let trimeAdddress = self.eventAddressTextField.text
        let event_Address = trimeAdddress?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if (eventNameTextField.text == "" || event_Name == ""){
            self.alert("Empty Name", subTitle: "Please Enter Event Name")
        }else if (eventAddressTextField.text == "" || event_Address == "" ) {
            self.alert("Empty Address", subTitle: "Please Enter Event Address")
        } else if (startDateTextField.text == ""){
            self.alert("Empty Date", subTitle: "Please Enter Start Date")
        } else if (endDateTextField.text == "" ){
            self.alert("Empty Date", subTitle: "Please Enter end Date")
        } else if (choosePlanTextField.text == "" ){
            self.alert("Empty Date", subTitle: "Please choose your plan")
        } else if self.eventImage == nil {
            let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
            }
            let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 4.0, timeoutAction: timeoutAction)
            SCLAlertView().showTitle("", subTitle: "Please select image", timeout: time, completeText: "Done", style: .success)
        }else if isUpdate {
                if let name = eventNameTextField.text, name != "" {
                    self.updateEvent(self.eventImage, editEventName: self.eventNameTextField.text!)
                }else {
                }
            } else {
                if let name = eventNameTextField.text, name != "" {
                    if self.eventImage != nil {
                    self.addEvent(self.eventImage, eventName: self.eventNameTextField.text!)
                    }
                }else {
                }
            }
        
    }
    
    
    func alert(_ title : String, subTitle: String) {
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
        }
        let time = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 2.0, timeoutAction: timeoutAction)
        
        SCLAlertView().showTitle(title , subTitle: subTitle, timeout: time, completeText: "Done", style:  .success)
    }
    
    
    func alertUser(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AddEventViewController :  UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return planArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         let name = planArray[row]["name"] as! String
         let cur = planArray[row]["currency"] as! String
         let amt = planArray[row]["amount"] as! String
        let title = name + " - " + cur + " " + amt
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         let name = planArray[row]["name"] as! String
                let cur = planArray[row]["currency"] as! String
                let amt = planArray[row]["amount"] as! String
               let title = name + " - " + cur + " " + amt
             choosePlanTextField.text = title
        self.eventPlanId = planArray[row]["id"] as! String
        print("eventPlanId",eventPlanId)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == choosePlanTextField {
            choosePlanTextField.inputView = pickerView
            choosePlanTextField.inputAccessoryView = toolbar
            createPickerView()
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func createPickerView() {
        pickerView.delegate = self
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(action));
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    func getAllplan(){
        SVProgressHUD.show()
        planArray.removeAll()
        let urlResponce = String(format: "%@%@",BASE_URL_BACKEND,ENDPOINT_ALL_EVENT_PLAN)
        //print(urlResponce)
        Alamofire.request( urlResponce,method: .get ,parameters: ["X-API-KEY": API_GENERAL_KEY])
            .responseJSON { response in
               SVProgressHUD.dismiss()
                switch response.result {
                case .success :
                     print("Dashboard_response",response)
                    guard let itms = response.result.value else {return}
                    let itemss = itms as! NSDictionary
                    self.planArray = itemss.value(forKey: "respon")  as! [[String : AnyObject]]                    
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Oops!", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        }
    }
}
extension UIButton {
    func leftImg(image: UIImage, renderMode: UIImage.RenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: image.size.width / 2)
        self.contentHorizontalAlignment = .left
        self.imageView?.contentMode = .scaleAspectFit
    }
}
