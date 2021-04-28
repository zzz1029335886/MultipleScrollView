//
//  ZZTwoMultipleScrollView.swift
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

import UIKit
import SnapKit

protocol ZZTwoMultipleScrollViewDelegte: class{
    func twoMultipleScrollViewDidScroll(_ scrollView: UIScrollView)
    func twoMultipleScrollViewScrollTop(_ multipleScrollView: ZZTwoMultipleScrollView)
    func twoMultipleScrollViewRefreshHeader(_ multipleScrollView: ZZTwoMultipleScrollView)
    func twoMultipleScrollViewRefreshFooter(_ multipleScrollView: ZZTwoMultipleScrollView)
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, scrollIn footerView: UIView)
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, footerViewScrollToBottom footerView: UIView)
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, headerViewScrollToBottom headerView: UIView)
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, footerViewWillShow footerView: UIView)
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, sectionViewWillShow sectionView: UIView)
}

extension ZZTwoMultipleScrollViewDelegte{
    func twoMultipleScrollViewDidScroll(_ scrollView: UIScrollView){}
    func twoMultipleScrollViewScrollTop(_ multipleScrollView: ZZTwoMultipleScrollView){}
    func twoMultipleScrollViewRefreshHeader(_ multipleScrollView: ZZTwoMultipleScrollView){}
    func twoMultipleScrollViewRefreshFooter(_ multipleScrollView: ZZTwoMultipleScrollView){}
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, scrollIn footerView: UIView){}
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, footerViewScrollToBottom footerView: UIView){}
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, headerViewScrollToBottom headerView: UIView){}
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, footerViewWillShow footerView: UIView){}
    func twoMultipleScrollView(_ multipleScrollView: ZZTwoMultipleScrollView, sectionViewWillShow sectionView: UIView){}
}

class ZZTwoMultipleScrollView: MultipleScrollView {
    var footerNormalText = "上拉加载更多"
    var footerPullText = "松开加载更多"
    var footerRefreshingText = "加载更多..."
    
    var headerNormalText = "下拉可以刷新"
    var headerPullText = "松开立即刷新"
    var headerRefreshingText = "正在刷新..."

    var sectionView: UIView?
    var headerView: UIView!
    var footerView: UIView!
    weak var kDelegate: ZZTwoMultipleScrollViewDelegte?
    var hasRefreshHeader = false{
        didSet{
            if hasRefreshHeader {
                headerRefreshControl.isUserInteractionEnabled = false
                self.addSubview(headerRefreshControl)
                headerRefreshControl.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.height.equalTo(headerPadding)
                    m.width.equalToSuperview()
                    self.headerConstraint = m.top.equalToSuperview().offset(-headerPadding).constraint
                }
            }
        }
    }
    var hasRefresFooter = false{
        didSet{
            if hasRefresFooter {
                headerRefreshControl.isUserInteractionEnabled = false
                self.addSubview(footerRefreshControl)
                
                footerRefreshControl.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.height.equalTo(footerPadding)
                    m.width.equalToSuperview()
                    self.footerConstraint = m.bottom.equalToSuperview().offset(footerPadding).constraint
                }
            }
        }
    }
    
    lazy var headerRefreshControl: ZZRefreshControl = {
        let refreshControl = ZZRefreshControl(normalText: headerNormalText, pullText: headerPullText, refreshingText: headerRefreshingText)
        return refreshControl
    }()
    
    lazy var footerRefreshControl: ZZRefreshControl = {
        let refreshControl = ZZRefreshControl(normalText: footerNormalText, pullText: footerPullText, refreshingText: footerRefreshingText)
        return refreshControl
    }()
    
    
    var footerPadding: CGFloat = 44
    var headerPadding: CGFloat = 44

    var footerConstraint : Constraint?
    var headerConstraint : Constraint?

    
    init(frame: CGRect,
         sectionView: UIView,
         headerView: UIView,
         footerView: UIView) {
        super.init(frame: frame)
        
        self.footerView = footerView
        self.headerView = headerView
        self.sectionView = sectionView
        self.clipsToBounds = true
        self.delegate = self
        self.dataSource = self
    }
    
    func endRefreshHeader() {
        if hasRefreshHeader {
            headerRefreshControl.controlType = .normal
            self.scrollTop()
        }
    }
    
    func endRefreshFooter() {
        if hasRefresFooter {
            footerRefreshControl.controlType = .normal
            self.scrollBottom()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        
    }
}

extension ZZTwoMultipleScrollView: MultipleScrollViewDelegate, MultipleScrollViewDataSource{
    func numberOfScrollSections(in multipleScrollView: MultipleScrollView) -> Int {
        return 2
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, viewForRowAt indexPath: IndexPath) -> UIView {
        if indexPath.section == 0 {
            return self.headerView
        }else{
            return self.footerView
        }
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return self.sectionView
        }
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.kDelegate?.twoMultipleScrollViewDidScroll(scrollView)
        
        if hasRefreshHeader {
            let padding : CGFloat = scrollView.contentOffset.y
            self.headerConstraint?.deactivate()
            
            headerRefreshControl.snp.makeConstraints { (m) in
                self.headerConstraint = m.top.equalToSuperview().offset(-padding - headerPadding).constraint
            }
            
            if headerRefreshControl.controlType != .refreshing {
                if padding < -headerPadding {
                    headerRefreshControl.controlType = .pull
                }else{
                    headerRefreshControl.controlType = .normal
                }
            }
        }
        
        if hasRefresFooter {
            let maxY = scrollView.contentOffset.y + scrollView.frame.height
            let padding = maxY - scrollView.contentSize.height
            
            self.footerConstraint?.deactivate()
            footerRefreshControl.snp.makeConstraints { (m) in
                self.footerConstraint = m.bottom.equalToSuperview().inset(padding-footerPadding).constraint
            }
            
            if footerRefreshControl.controlType != .refreshing{
                
                if padding > footerPadding {
                    footerRefreshControl.controlType = .pull
                }else{
                    footerRefreshControl.controlType = .normal
                }
            }
        }
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, willScrollToBottomIn view: UIView, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.kDelegate?.twoMultipleScrollView(self, footerViewScrollToBottom: view)
        }else if indexPath.section == 0{
            self.kDelegate?.twoMultipleScrollView(self, headerViewScrollToBottom: view)
        }
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, scrollToLastBottom tableView: UITableView) -> CGFloat{
        if hasRefresFooter {
            if footerRefreshControl.controlType == .pull {
                footerRefreshControl.controlType = .refreshing
                self.kDelegate?.twoMultipleScrollViewRefreshFooter(self)
                return footerPadding
            }
        }
        return -1
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, scrollToTop tableView: UITableView) -> CGFloat{
        if hasRefreshHeader {
            if headerRefreshControl.controlType == .pull {
                headerRefreshControl.controlType = .refreshing
                self.kDelegate?.twoMultipleScrollViewRefreshHeader(self)
                return headerPadding
            }
        }
        self.kDelegate?.twoMultipleScrollViewScrollTop(self)
        return -1
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, willDisplay view: UIView, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.kDelegate?.twoMultipleScrollView(self, footerViewWillShow: view)
        }
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.kDelegate?.twoMultipleScrollView(self, sectionViewWillShow: view)
    }
    
    
}

//
//class ZZRefreshControl: UIView {
//    var attributedTitle: NSAttributedString?
//
//}
