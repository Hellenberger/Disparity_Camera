//
//  ViewController.swift
//  IOS-Swift-CoreMotionGyroscope01
//
//  Created by Pooya on 2018-10-06.
//  Copyright © 2018 Pooya. All rights reserved.
//

import UIKit
import CoreMotion
import SpriteKit
import SceneKit
import ARKit
import MediaPlayer
import AVFoundation
import Photos
import AudioToolbox

class ViewController: UIViewController, ARSCNViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate  {
	

	@IBOutlet weak var sceneView: ARSCNView!
	@IBOutlet weak var sceneView1: ARSCNView!
	@IBOutlet weak var sceneView2: ARSCNView!
	@IBOutlet weak var imageViewLeft: UIImageView!
	@IBOutlet weak var imageViewRight: UIImageView!


	let viewBackgroundColor : UIColor = UIColor.black // UIColor.white
		
	
	var initialVolume: Float = 0.0
	var audioSession: AVAudioSession!
	var volumeUpdated: Bool = false
	
	var motion = CMMotionManager()
	
	var captureSession = AVCaptureSession()
	
	var camera : AVCaptureDevice?
	var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
	var cameraCaptureOutput : AVCapturePhotoOutput?
	
	var image: UIImage?
	
	var zoomInGestureRecognizer = UISwipeGestureRecognizer()
	var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initializeCaptureSession()
//		setupCaptureSession()
//		setupDevice()
//		setupInputOutput()
//		setupPreviewLayer()
		//captureSession.startRunning()
		listenVolumeButton()

		// Zoom In recognizer
		zoomInGestureRecognizer.direction = .right
		zoomInGestureRecognizer.addTarget(self, action: #selector(zoomIn))
		view.addGestureRecognizer(zoomInGestureRecognizer)
		
		// Zoom Out recognizer
		zoomOutGestureRecognizer.direction = .left
		zoomOutGestureRecognizer.addTarget(self, action: #selector(zoomOut))
		view.addGestureRecognizer(zoomOutGestureRecognizer)
		
		
		// Scene setup
		let scene = SCNScene()
		// Set the scene to the view
		sceneView.scene = scene
		
		////////////////////////////
		// App Setup
		UIApplication.shared.isIdleTimerDisabled = true
		sceneView.isHidden = true
		self.view.backgroundColor = viewBackgroundColor
		
		////////////////////////////////////////////////////////////////
		// Set up Left-Eye SceneView
		sceneView1.scene = scene
		sceneView1.showsStatistics = sceneView.showsStatistics
		sceneView1.isPlaying = true
		
		// Set up Right-Eye SceneView
		sceneView2.scene = scene
		sceneView2.showsStatistics = sceneView.showsStatistics
		sceneView2.isPlaying = true
		
		func myGyroscope() {
			print("Start Accelerometer")
			motion.gyroUpdateInterval = 0.01
			motion.startGyroUpdates(to: OperationQueue.current!) {
				(data, error) in
				print(data as Any)
				if let trueData =  data {
					
					let x = trueData.rotationRate.x
					let y = trueData.rotationRate.y
					let z = trueData.rotationRate.z
//					self.xGyro.text = "x: \(Double(x).rounded(toPlaces :3))"
//					self.yGyro.text = "y: \(Double(y).rounded(toPlaces :3))"
//					self.zGyro.text = "z: \(Double(z).rounded(toPlaces :3))"
					print(x, y, z)
					}
				}
				
				return
			
		}
	}
}
	
//extension Double {
//	/// Rounds the double to decimal places value
//	func rounded(toPlaces places:Int) -> Double {
//		let divisor = pow(10.0, Double(places))
//		return (self * divisor).rounded() / divisor
//	}
//}


extension ViewController {
		
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let configuration = ARWorldTrackingConfiguration()
		sceneView.session.run(configuration)
	}
	
	func initializeCaptureSession() {
		captureSession.sessionPreset = AVCaptureSession.Preset.high
		let camera = AVCaptureDevice.default(for: AVMediaType.video)
		
		do {
			let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
			cameraCaptureOutput = AVCapturePhotoOutput()
			
			captureSession.addInput(cameraCaptureInput)
			captureSession.addOutput(cameraCaptureOutput!)
			
		} catch {
			print(error.localizedDescription)
		}
		
		cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		cameraPreviewLayer?.frame = view.bounds
		cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
		
		view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
		
		captureSession.startRunning()
	}
	
//	func setupCaptureSession() {
//		captureSession.sessionPreset = AVCaptureSession.Preset.photo
//	}
//
//	func setupDevice() {
//		let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
//		let devices = deviceDiscoverySession.devices
//
//		for device in devices {
//			if device.position == AVCaptureDevice.Position.back {
//				backCamera = device
//			} else if device.position == AVCaptureDevice.Position.front {
//				frontCamera = device
//			}
//		}
//		currentDevice = backCamera
//	}
//
//	func setupInputOutput() {
//		do {
//			let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
//			captureSession.addInput(captureDeviceInput)
//			photoOutput = AVCapturePhotoOutput()
//			photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
//			captureSession.addOutput(photoOutput!)
//
//		} catch {
//			print(error)
//		}
//	}
//
//	func setupPreviewLayer() {
//		self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//		self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
//		self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
//		self.cameraPreviewLayer?.frame = view.frame
//
//		self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
//		captureSession.startRunning()
//	}
	
	@objc func zoomIn() {
		if let zoomFactor = camera?.videoZoomFactor {
			if zoomFactor < 5.0 {
				let newZoomFactor = min(zoomFactor + 1.0, 5.0)
				do {
					try camera?.lockForConfiguration()
					camera?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
					camera?.unlockForConfiguration()
				} catch {
					print(error)
				}
			}
		}
	}
	
	@objc func zoomOut() {
		if let zoomFactor = camera?.videoZoomFactor {
			if zoomFactor > 1.0 {
				let newZoomFactor = max(zoomFactor - 1.0, 1.0)
				do {
					try camera?.lockForConfiguration()
					camera?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
					camera?.unlockForConfiguration()
				} catch {
					print(error)
				}
			}
		}
	}

	func displayCapturedPhoto(capturedPhoto : UIImage) {
		
		let PreviewViewController = storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
		PreviewViewController.image = capturedPhoto
		navigationController?.pushViewController(PreviewViewController, animated: true)
		}
	}

extension ViewController: AVCapturePhotoCaptureDelegate {
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "Preview_Segue" {
			let previewViewController = segue.destination as! PreviewViewController
			previewViewController.image = self.image
		}
	}
	
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let error = error { print("Error:", error)
			
		} else {
			if let imageData = photo.fileDataRepresentation() {
				self.image = UIImage(data: imageData)
				print(image!)
				performSegue(withIdentifier: "Preview_Segue", sender: nil)
			}
		}
	}

	func listenVolumeButton() {
		let volumeView = MPVolumeView(frame: .zero)
		for subview in volumeView.subviews {
			if let button = subview as? UIButton {
				button.setImage(nil, for: .normal)
				button.isEnabled = false
				button.sizeToFit()
			}
		}
		
		let audioSession = AVAudioSession.sharedInstance()
		
		do{
			try audioSession.setActive(false, with:.notifyOthersOnDeactivation)
			try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.mixWithOthers])
			try audioSession.setActive(true)
			
			let vol = audioSession.outputVolume
			print(vol.description) //gets initial volume
			initialVolume = Float(vol.description)!
			if initialVolume > 0.9 {
				initialVolume = 0.9
			} else if initialVolume < 0.1 {
				initialVolume = 0.1
			}
			
		} catch {
			print("Error info: \(error)")
		}

		audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
			let settings = AVCapturePhotoSettings()
			if keyPath == "outputVolume"{
				cameraCaptureOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate) // Same function which I use for capturing photo for screen button.
			} else {
				super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			}
		let volume = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).floatValue
			print("volume " + volume.description)
			print(volume)
		
		
			let newVolume: Float = Float(volume)
			if newVolume > initialVolume || newVolume == 1.0 {
				let volumeView = MPVolumeView()
				if let view = volumeView.subviews.first as? UISlider{
					view.value = Float(initialVolume)
					if !volumeUpdated {
						print("volume up")
						volumeUpdated = true
						// Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
						func prepare(for segue: UIStoryboardSegue, sender: Any?) {
							
							if segue.identifier == "Preview_Segue" {
								let previewViewController = segue.destination as! PreviewViewController
								previewViewController.image = self.image
								cameraCaptureOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
							}
							displayCapturedPhoto(capturedPhoto: image!)
						}

						if volumeUpdated == true {
							func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
								if let error = error { print("Error:", error)
									
								} else {
									self.cameraCaptureOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
										displayCapturedPhoto(capturedPhoto: image!)
									if let imageData = photo.fileDataRepresentation() {
										self.image = UIImage(data: imageData)
										print(image!)
										performSegue(withIdentifier: "Preview_Segue", sender: nil)
										
									}
									displayCapturedPhoto(capturedPhoto: image!)
								}
							}
						} else {
							volumeUpdated = false
						}
					}
				}
				
			} else {
				let volumeView = MPVolumeView()
				if let view = volumeView.subviews.first as? UISlider{
					view.value = Float(initialVolume)
					if !volumeUpdated {
						print("volume down")
						volumeUpdated = true
						// Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
						func prepare(for segue: UIStoryboardSegue, sender: Any?) {
						
							if segue.identifier == "Preview_Segue" {
								let previewViewController = segue.destination as! PreviewViewController
								previewViewController.image = self.image
								cameraCaptureOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
							}
							displayCapturedPhoto(capturedPhoto: image!)
						}

						if volumeUpdated == true {
	
								func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
										if let error = error { print("Error:", error)
											
										} else {
										self.cameraCaptureOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
											displayCapturedPhoto(capturedPhoto: image!)
											if let imageData = photo.fileDataRepresentation() {
											self.image = UIImage(data: imageData)
											print(image!)
											performSegue(withIdentifier: "Preview_Segue", sender: nil)
									}
									displayCapturedPhoto(capturedPhoto: image!)
								}
							}
						
						} else  {
							volumeUpdated = false
					}
				}
			}
		}
	
		func viewWillDisappear(_ animated: Bool) {
			super.viewWillDisappear(animated)
			AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
			
		}
	}
}



