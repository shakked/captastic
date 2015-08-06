//
//  PhotoEditorViewController.swift
//  Funny Pic Maker
//
//  Created by Mac User on 7/28/15.
//  Copyright (c) 2015 Shakd Apps. All rights reserved.
//

import UIKit

class PhotoEditorViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    private var image : UIImage
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    
    //MARK: Text Manipulation
    private var lastScale : CGFloat = 1.0
    private var lastRotation : CGFloat = 0.0
    private var firstX : CGFloat!
    private var firstY : CGFloat!
    private var translatedPoint : CGPoint!
    private var oldTransform : CGAffineTransform!
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            firstX = textView.center.x
            firstY = textView.center.y
            translatedPoint = textView.center
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "textViewTapped")
            tapGesture.numberOfTapsRequired = 1
            tapGesture.delegate = self
            textView.addGestureRecognizer(tapGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: "scale:")
            pinchGesture.delegate = self
            textView.addGestureRecognizer(pinchGesture)
            
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: "rotate:")
            rotationGesture.delegate = self
            textView.addGestureRecognizer(rotationGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: "move:")
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            panGesture.delegate = self
            textView.addGestureRecognizer(panGesture)
        }
    }
    
    required init(image: UIImage) {
        self.image = image
        super.init(nibName: "PhotoEditorViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            endEditingMode()
            return false
        }
        return true
    }
    
    
    func textViewTapped() {
        moveToEditingMode()
    }
    
    func moveToEditingMode() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.oldTransform = self.textView.transform

            let transform = CGAffineTransformMakeScale(1.0, 1.0)
            CGAffineTransformRotate(transform, 0.0)
            self.textView.transform = transform
            self.textView.frame.origin = CGPoint(x: 8, y: 8)
        }, completion: { _ in
            if let gestureRecognizers = self.textView.gestureRecognizers as? [UIGestureRecognizer] {
                for gestureRecognizer in gestureRecognizers {
                    gestureRecognizer.enabled = false
                }
            }
            self.textView.editable = true
            self.textView.selectable = true
            self.textView.becomeFirstResponder()
        })
    }
    
    func endEditingMode() {
        self.textView.editable = false
        self.textView.selectable = false
        self.textView.resignFirstResponder()
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            println(self.translatedPoint)
            self.textView.transform = self.oldTransform
            self.textView.center = self.translatedPoint
            }, completion: { _ in
                if let gestureRecognizers = self.textView.gestureRecognizers as? [UIGestureRecognizer] {
                    for gestureRecognizer in gestureRecognizers {
                        gestureRecognizer.enabled = true
                    }
                }
                println("translatedPoint: \(self.translatedPoint)")
                println("textView.center: \(self.textView.center)")
                
        })
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        if self.textView.editable == true {
            endEditingMode()
        }
    }
    
    func scale(sender: AnyObject) {
        let pinchGesture = sender as! UIPinchGestureRecognizer
        if pinchGesture.state == UIGestureRecognizerState.Began {
            lastScale = 1.0
        }
        let scale = 1.0 - (lastScale - pinchGesture.scale)
        let currentTransform = textView.transform
        let newTransform = CGAffineTransformScale(currentTransform, scale, scale)
        
        textView.transform = newTransform
        lastScale = pinchGesture.scale
    }
    
    func rotate(sender: AnyObject) {
        let rotateGesture = sender as! UIRotationGestureRecognizer
        if rotateGesture.state == UIGestureRecognizerState.Began {
            lastRotation = 0.0
            return
        }
        let rotation = 0.0 - (lastRotation - rotateGesture.rotation)
        let currentTransform = textView.transform
        let newTransform = CGAffineTransformRotate(currentTransform, rotation)
        
        textView.transform = newTransform
        lastRotation = rotateGesture.rotation
    }
    
    func move(sender: AnyObject) {
        let panGesture = sender as! UIPanGestureRecognizer
        translatedPoint = panGesture.translationInView(view)
        if panGesture.state == UIGestureRecognizerState.Began {
            firstX = textView.center.x
            firstY = textView.center.y
        }
        
        translatedPoint = CGPoint(x: firstX + translatedPoint.x, y: firstY + translatedPoint.y)
        textView.center = translatedPoint
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func fontsButtonPressed(sender: AnyObject) {
        
    }
    
    
}


