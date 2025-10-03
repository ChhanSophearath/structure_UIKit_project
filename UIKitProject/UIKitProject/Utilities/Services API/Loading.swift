//
//  Loading.swift
//  UIKitProject
//
//  Created by Rath! on 12/8/24.
//

import UIKit

//class Loading : UIView {
//    
//    static let shared = Loading()
//    
//    private let loadingView: UIActivityIndicatorView = {
//        let loading = UIActivityIndicatorView()
//        loading.color = .white
//        loading.style = .large 
//        loading.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        return loading
//    }()
//    
//    private let lblLoading: UILabel = {
//        let lbl = UILabel()
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        lbl.text = "Loading..."
//        lbl.textColor = .white
//        return lbl
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        addSubview(lblLoading)
//        NSLayoutConstraint.activate([
//            lblLoading.centerYAnchor.constraint(equalTo: centerYAnchor,constant: 50),
//            lblLoading.centerXAnchor.constraint(equalTo: centerXAnchor),
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func showLoading(alpha: CGFloat = 0.5) {
//        DispatchQueue.main.async { [self] in
//            
//            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                         let window = windowScene.windows.first else { return }
//
//            self.frame = window.bounds
//            window.addSubview(self)
//            loadingView.frame = window.bounds
//            addSubview(loadingView)
//            loadingView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
//            loadingView.startAnimating()
//        }
//    }
//    
//    func hideLoading(seconds: CFTimeInterval = 0.0, completion: (() -> Void)? = nil){
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds ){ [self] in
//            loadingView.stopAnimating()
//            self.removeFromSuperview()
//            completion?()
//        }
//    }
//}



class Loading: UIView {
    
    static let shared = Loading()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let lblLoading: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Loading..."
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return lbl
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Transparent background for the full screen
        self.backgroundColor = UIColor.clear
        
        // Setup loading view
        addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(lblLoading)
        
        // Constraints for loading view
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 120),
            loadingView.heightAnchor.constraint(equalToConstant: 120),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20),
            
            lblLoading.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 15),
            lblLoading.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoading(alpha: CGFloat = 0.5) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            if !window.subviews.contains(self) {
                self.frame = window.bounds
                window.addSubview(self)
            }
            
            self.loadingView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoading(seconds: CFTimeInterval = 0.0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
            completion?()
        }
    }
}
