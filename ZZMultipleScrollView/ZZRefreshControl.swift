//
//  ZZRefreshControl.swift
//  ZZPagingView
//
//  Created by zerry on 2021/4/27.
//

import UIKit

class ZZRefreshControl: UIControl {
    ///定义状态枚举
    enum ControlType {
        case normal
        case pull
        case refreshing
    }
    
    var normalText = "上拉加载更多"
    var pullText = "松开加载更多"
    var refreshingText = "加载更多..."
    
    var controlType: ControlType = .normal {
        didSet {
            //根据枚举获得对应的值
            switch controlType {
            case .normal:
                if oldValue == .refreshing {
                    self.indicatorView.stopAnimating()
                    self.arrowImageView.isHidden = false
                }
                messageLabel.text = normalText
                UIView.animate(withDuration: 0.25, animations: {
                    self.arrowImageView.transform = CGAffineTransform.identity
                })
                
            case .pull:
                messageLabel.text = pullText
                UIView.animate(withDuration: 0.25, animations: {
                    self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-3 * Double.pi))
                })
                
            case .refreshing:
                messageLabel.text = refreshingText
                self.indicatorView.startAnimating()
                self.arrowImageView.isHidden = true
            }
        }
    }
    
    //停止动画方法
    func endRefreshing() {
        controlType = .normal
    }
    
    //构造方法
    init(
        normalText: String,
        pullText: String,
        refreshingText: String
    ) {
        super.init(frame: .zero)
        self.normalText = normalText
        self.pullText = pullText
        self.refreshingText = refreshingText
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        //添加控件
        addSubview(messageLabel)
        addSubview(arrowImageView)
        addSubview(indicatorView)
        
        //约束控件
        messageLabel.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.top.equalToSuperview()
        }
        arrowImageView.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.trailing.equalTo(messageLabel.snp.leading).offset(-8)
        }
        indicatorView.snp.makeConstraints { (m) in
            m.edges.equalTo(arrowImageView)
        }
    }
    
    //懒加载控件
    fileprivate lazy var messageLabel:UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.darkGray
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 15)
        return lab
    }()
    
    fileprivate lazy var arrowImageView: UIImageView = UIImageView(image: UIImage.init(named: "tableview_pull_refresh"))
    fileprivate lazy var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
}


