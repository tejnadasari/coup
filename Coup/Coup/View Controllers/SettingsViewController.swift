//
//  SettingsViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 7/13/21.
//

import UIKit
import AVFoundation
import CoreData

class SettingsViewController: UIViewController,
                              UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        loadImage()
    }
    
    func loadImage() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            
            for profile in fetchedResults! {
                if let imageString = profile.value(forKey: "image"),
                   let decodedData = Data(base64Encoded: imageString as! String,
                                          options: .ignoreUnknownCharacters)
                   {
                    let savedImage = UIImage(data: decodedData)
                    imageView.image = savedImage
                }
            }
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func storeImage(selectedImage: UIImage) {
        clearCoreData()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context)
        profile.setValue(selectedImage.jpegData(compressionQuality: 1)?.base64EncodedString(),
                        forKey: "image")
        
        do {
            try context.save()
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result: AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
                                [UIImagePickerController.InfoKey : Any])
    {
        let chosenImage = info[.originalImage] as! UIImage
        storeImage(selectedImage: chosenImage)
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        let controller = UIAlertController(
            title: "Pick Profile Image",
            message: "Choose where you want to get your profile image from.",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.addAction(UIAlertAction(title: "Library", style: .default) { _ in
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        })
        
        controller.addAction(UIAlertAction(title: "Camera",style: .default) { _ in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                // there is a rear camera
                switch AVCaptureDevice.authorizationStatus(for: .video) {   // for video or photo
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) {
                        accessGranted in    // then continue to below code
                        guard accessGranted == true else { return }
                    }
                case .authorized:
                    break
                default:
                    print("Access denied")
                    return
                }
                
                // We are authorized to use the camera
                self.picker.allowsEditing = false
                self.picker.sourceType = .camera
                self.picker.cameraCaptureMode = .photo   // only using photo capture mode
                
                self.present(self.picker, animated: true, completion: nil)
            } else {
                // if no camera is available, pop up an alert --> simulator
                let alertVC = UIAlertController(
                    title: "No camera",
                    message: "Sorry, this device has no camera",
                    preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil
                )
                
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        })

        present(controller, animated: true, completion: nil)
    }
    
    

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
