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
    @IBOutlet weak var modeSegCtrl: UISegmentedControl!
    @IBOutlet weak var effectSegCtrl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setUpSettings()
        
        modeSegCtrl.layer.cornerRadius = 20.0
        let font = UIFont.systemFont(ofSize: 16)
        modeSegCtrl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        effectSegCtrl.layer.cornerRadius = 20.0
        effectSegCtrl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        doneButton.layer.cornerRadius = 15
        doneButton.layer.borderWidth = 2
        doneButton.layer.borderColor = UIColor.black.cgColor
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(LoginViewController.getEffectInUserDefaults())
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    // MARK: - Core Data
    
    static func getImage() -> UIImage {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            
            if fetchedResults?.count == 0 {
                return UIImage(named: "Angela Baby")!
            }
            
            let profile = fetchedResults![0]
            if let imageString = profile.value(forKey: "image"),
               let decodedData = Data(base64Encoded: imageString as! String,
                                      options: .ignoreUnknownCharacters) {
                return UIImage(data: decodedData)!
            }
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return UIImage(named: "Angela Baby")!
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
    
    // MARK: - Image Picker Controller
    
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
    
    // MARK: - Load User Defaults in Setup
    
    func setUpSettings() {
        loadImage()
        loadMode()
        loadEffect()
    }
    
    func loadImage() {
        let savedImage = SettingsViewController.getImage()
        imageView.image = savedImage
    }
    
    func loadMode() {
        switch LoginViewController.getModeInUserDefaults() {
        case "light":
            modeSegCtrl.selectedSegmentIndex = 0
        case "dark":
            modeSegCtrl.selectedSegmentIndex = 1
        default:
            print("This should never happen")
        }
    }
    
    func loadEffect() {
        switch LoginViewController.getEffectInUserDefaults() {
        case "on":
            effectSegCtrl.selectedSegmentIndex = 0
        case "off":
            effectSegCtrl.selectedSegmentIndex = 1
        default:
            print("This should never happen")
        }
    }
    
    static func isSoundEnabled() -> Bool {
        return LoginViewController.getEffectInUserDefaults() == "on"
    }
    
    static func isLightModeEnabled() -> Bool {
        return LoginViewController.getModeInUserDefaults() == "light"
    }
    
    // MARK: - UI
    
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
        
        controller.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
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
        if effectSegCtrl.selectedSegmentIndex == 1 {
            Sound.stopPlay()
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - On Segment Control Change
    
    @IBAction func onModeSegChange(_ sender: Any) {
        switch modeSegCtrl.selectedSegmentIndex {
        case 0:
            LoginViewController.storeModeInUserDefaults(mode: "light")
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        case 1:
            LoginViewController.storeModeInUserDefaults(mode: "dark")
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        default:
            print("This should never happen")
        }
        
//        if SettingsViewController.isLightModeEnabled() {
//            overrideUserInterfaceStyle = .light
//            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
//        } else {
//            overrideUserInterfaceStyle = .dark
//            self.view.backgroundColor = UIColor(hex: "#283747FF")
//        }
    }
    
    @IBAction func onEffectSegChange(_ sender: Any) {
        switch effectSegCtrl.selectedSegmentIndex {
        case 0:
            LoginViewController.storeEffectInUserDefaults(effect: "on")
            Sound.continuePlay()
            if audioPlayerMainSong == nil {
                Sound.playMainSong()
            }
        case 1:
            LoginViewController.storeEffectInUserDefaults(effect: "off")
            Sound.pausePlay()
        default:
            print("This should never happen")
        }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
