

import UIKit
import CoreData
class Utilities: NSObject {

    class func prettifyTime(_ seconds: TimeInterval) -> String {
        let interval = Int(seconds)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
       // let hours = (interval / 3600)
        return String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    class func prettifySize(_ bytesCount: Int) -> String {
        return ByteCountFormatter.string(fromByteCount: CLongLong(bytesCount), countStyle: .file)
    }
    
    class func displayToastMessage(_ message : String) {
        
        DispatchQueue.main.async(execute: {
            let toastView = UILabel()
            toastView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            toastView.textColor = RED_COLOR
            toastView.textAlignment = .center
            toastView.font = UIFont.preferredFont(forTextStyle: .caption1)
            toastView.layer.cornerRadius = 25
            toastView.layer.masksToBounds = true
            toastView.text = message
            toastView.numberOfLines = 0
            toastView.alpha = 0
            //toastView.adjustsFontSizeToFitWidth = UIFont.italicSystemFont(ofSize: 15)
            toastView.translatesAutoresizingMaskIntoConstraints = false
            
            let window = UIApplication.shared.delegate?.window!
            window?.addSubview(toastView)
            
            let horizontalCenterContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
            
            let widthContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 275)
            
            let verticalContraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=200)-[loginView(==50)]-68-|", options: [.alignAllCenterX, .alignAllCenterY], metrics: nil, views: ["loginView": toastView])
            
            NSLayoutConstraint.activate([horizontalCenterContraint, widthContraint])
            NSLayoutConstraint.activate(verticalContraint)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                toastView.alpha = 1
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
                    toastView.alpha = 0
                }, completion: { finished in
                    toastView.removeFromSuperview()
                })
            })
        })
        
    }
    
    class func fetchObjectByEntity(entity: String , predicate: NSPredicate?) -> [NSManagedObject]?{
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if let prd = predicate {
            request.predicate = prd
        }
        request.returnsObjectsAsFaults = false
        var downloadFile : [NSManagedObject]
        do {
            let results = try context.fetch(request)
            downloadFile = results as! [NSManagedObject]
            return downloadFile
            
        } catch {
            print("Fetch Failed")
        }
        return nil
    }
    class func deleteObject(entity: String , predicate: String) -> Bool {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.predicate =  NSPredicate(format: "fileID = %@", predicate)
        request.returnsObjectsAsFaults = false
        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object as! NSManagedObject)
                do {
                    try context.save()
                    return true
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
        }
        return false
    }
    
}
