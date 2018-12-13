//
//  PreviewViewController.swift
//  BIO_Camera
//
//  Created by Howard Macbook pro on 11/19/18.
//  Copyright © 2018 Howard Macbook pro. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

	@IBOutlet weak var photo: UIImageView!
		
	var image: UIImage!
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		photo.image = image
    }
	@IBAction func saveButton(_ sender: UIButton) {
		guard let imageToSave = image else {
			return
		}
		UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
		dismiss(animated: true, completion: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
   

}
