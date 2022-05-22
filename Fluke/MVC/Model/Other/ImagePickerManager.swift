//
//  ImagePickerManager.swift
//  LifeBook
//
//  Created by JP on 22/04/20.
//  Copyright © 2020 JP. All rights reserved.
//

import Foundation
import UIKit

public enum MediaType : Int {
    case photo
    case video
    case both
}

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Media", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((Data, _ isVideo:Bool) -> ())?;
    
    override init(){
        super.init()
    }
    
    func pickImage(_ viewController: UIViewController, type:MediaType, _ callback: @escaping ((Data, _ isVideo:Bool) -> ())) {
        
        pickImageCallback = callback;
        self.viewController = viewController;
        picker.videoMaximumDuration = TimeInterval(30.0)
        
        
        if(type == .photo) {
            
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default){
                UIAlertAction in
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "Gallery", style: .default){
                UIAlertAction in
                self.openGallery()
            }
            
            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
            
        }
        else if(type == .video) {
            picker.mediaTypes = ["public.movie"]
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default){
                UIAlertAction in
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "Gallery", style: .default){
                UIAlertAction in
                self.openGallery()
            }
            
            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
        }
        else {
            
            let cameraAction = UIAlertAction(title: "Photo From Camera", style: .default){
                UIAlertAction in
                self.picker.allowsEditing = true
                self.picker.mediaTypes = ["public.image"]
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "Photo From Gallery", style: .default){
                UIAlertAction in
                self.picker.allowsEditing = true
                self.picker.mediaTypes = ["public.image"]
                self.openGallery()
            }
            
            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
            
            
            let vcameraAction = UIAlertAction(title: "Video From Camera", style: .default){
                UIAlertAction in
                self.picker.mediaTypes = ["public.movie"]
                self.openCamera()
            }
            let vgalleryAction = UIAlertAction(title: "Video From Gallery", style: .default){
                UIAlertAction in
                self.picker.mediaTypes = ["public.movie"]
                self.openGallery()
            }
            
            alert.addAction(vcameraAction)
            alert.addAction(vgalleryAction)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
            return
        }
        
        // Add the actions
        picker.delegate = self
        
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)        
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            self.viewController?.showAlert(strMsg: "You don't have camera")
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if(picker.mediaTypes == ["public.image"]) {
            
            guard let image = info[.editedImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            
            pickImageCallback?(image.jpegData(compressionQuality: 0.5)!, false)
            picker.dismiss(animated: true, completion: nil)
        }
        else if(picker.mediaTypes == ["public.movie"]) {
            let videoURL = info[.mediaURL]
            
            do {
                let data = try Data(contentsOf: videoURL as! URL)
                pickImageCallback?(data, true)
                picker.dismiss(animated: true, completion: nil)
            } catch {
                print("do it error")
            }
        }
        else {
            
            if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
                
                if mediaType  == "public.image" {
                    guard let image = info[.editedImage] as? UIImage else {
                        fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
                    }
                    
                    pickImageCallback?(image.jpegData(compressionQuality: 0.5)!, false)
                    picker.dismiss(animated: true, completion: nil)
                }
                else if mediaType == "public.movie" {
                    let videoURL = info[.mediaURL]
                    
                    do {
                        let data = try Data(contentsOf: videoURL as! URL)
                        pickImageCallback?(data, true)
                        picker.dismiss(animated: true, completion: nil)
                    } catch {
                        print("do it error")
                    }
                }
            }
            
        }
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
    }
    
}
