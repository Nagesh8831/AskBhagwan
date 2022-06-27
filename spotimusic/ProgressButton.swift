

import UIKit
import QuartzCore

protocol ProgressButtonDelegate {
    func progressButton(_ progressButton: ProgressButton, didUpdateProgress progress: Double)
}

//@IBDesignable class ProgressButton: UIButton {
class ProgressButton: UIButton {

    fileprivate var backgroundLayer: CAShapeLayer!
    fileprivate var progressLayer: CAShapeLayer!
    var delegate: ProgressButtonDelegate?
    var operation: DownloadOperation?
    
//    @IBInspectable var progress: Double = 0.0 {
    var progress: Double = 0.0 {
        didSet {
            updateLayerProperties()
            delegate?.progressButton(self, didUpdateProgress: progress)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let color = tintColor.cgColor
        
        // Circle background layer
        if (backgroundLayer == nil) {
            backgroundLayer = CAShapeLayer()
            backgroundLayer.path = UIBezierPath(ovalIn:bounds).cgPath
            backgroundLayer.fillColor = nil
            backgroundLayer.lineWidth = 1.0
            backgroundLayer.strokeColor = color
            
            layer.addSublayer(backgroundLayer)
        }
        backgroundLayer.frame = layer.bounds
        
        // Progress layer
        let lineWidth: CGFloat = 3.0
        let rect = bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
        if (progressLayer == nil) {
            progressLayer = CAShapeLayer()
            progressLayer.path = UIBezierPath(ovalIn:rect).cgPath
            progressLayer.fillColor = nil
            progressLayer.lineWidth = lineWidth
            progressLayer.strokeColor = color
            progressLayer.transform = CATransform3DRotate(progressLayer.transform, CGFloat(-M_PI/2.0), 0.0, 0.0, 1.0)
            progressLayer.strokeEnd = CGFloat(progress)
            
            layer.addSublayer(progressLayer)
        }
        progressLayer.frame = layer.bounds
    }

    func updateLayerProperties() {
        if (progressLayer != nil) {
            progressLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    func configure() {
        if self.operation != nil {
            self.stopObserving()
        }
    }
    
    func setProgress(downloadProgressOfOperation operation: DownloadOperation) {
        self.operation = operation
        self.operation?.downloadTask.addObserver(self, forKeyPath: "countOfBytesReceived", options: .new, context: nil)
        self.operation?.downloadTask.addObserver(self, forKeyPath: "state", options: .new, context: nil)
    }
    
    func stopObserving() {
        self.operation?.downloadTask.removeObserver(self, forKeyPath: "state")
        self.operation?.downloadTask.removeObserver(self, forKeyPath: "countOfBytesReceived")
        self.operation = nil
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let task = object as! URLSessionTask
        if let keyPath = keyPath {
            switch keyPath {
            case "countOfBytesReceived":
                if (task.countOfBytesExpectedToReceive > 0) {
                    DispatchQueue.main.async(execute: {
                        self.progress = Double(task.countOfBytesReceived) / Double(task.countOfBytesExpectedToReceive)
                    })
                }
            case "state":
                switch task.state {
                case .canceling, .completed:
                    self.stopObserving()
                default: break
                }
            default: break
            }
        }
    }
}
