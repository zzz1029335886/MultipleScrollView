//
//  TwoScrollView.swift
//
//
//  Created by zerry on 2021/4/25.
//

import UIKit
import SnapKit

protocol TwoScrollViewDelegte: class{
    func twoScrollViewDidScroll(_ scrollView: UIScrollView)
    func twoScrollViewScrollTop(_ multipleScrollView: TwoScrollView)
    func twoScrollViewRefreshHeader(_ multipleScrollView: TwoScrollView)
    func twoScrollViewRefreshFooter(_ multipleScrollView: TwoScrollView)
    func twoScrollView(_ multipleScrollView: TwoScrollView, scrollIn footerView: UIView)
    func twoScrollView(_ multipleScrollView: TwoScrollView, footerViewScrollToBottom footerView: UIView)
    func twoScrollView(_ multipleScrollView: TwoScrollView, headerViewScrollToBottom headerView: UIView)
    func twoScrollView(_ multipleScrollView: TwoScrollView, footerViewWillShow footerView: UIView)
    func twoScrollView(_ multipleScrollView: TwoScrollView, footerSectionViewWillShow sectionView: UIView)
}

extension TwoScrollViewDelegte{
    func twoScrollViewDidScroll(_ scrollView: UIScrollView){}
    func twoScrollViewScrollTop(_ multipleScrollView: TwoScrollView){}
    func twoScrollViewRefreshHeader(_ multipleScrollView: TwoScrollView){}
    func twoScrollViewRefreshFooter(_ multipleScrollView: TwoScrollView){}
    func twoScrollView(_ multipleScrollView: TwoScrollView, scrollIn footerView: UIView){}
    func twoScrollView(_ multipleScrollView: TwoScrollView, headerViewScrollToBottom headerView: UIView){}
    
    func twoScrollView(_ multipleScrollView: TwoScrollView, footerViewScrollToBottom footerView: UIView){}
    func twoScrollView(_ multipleScrollView: TwoScrollView, footerViewWillShow footerView: UIView){}
    func twoScrollView(_ multipleScrollView: TwoScrollView, footerSectionViewWillShow sectionView: UIView){}
}

class TwoScrollView: MultipleScrollView {
    var footerNormalText = "上拉加载更多"
    var footerPullText = "松开加载更多"
    var footerRefreshingText = "加载更多..."
    
    var headerNormalText = "下拉可以刷新"
    var headerPullText = "松开立即刷新"
    var headerRefreshingText = "正在刷新..."

    var footerSectionView: UIView?
    var headerSectionView: UIView?
    
    var headerView: UIView!
    var footerView: UIView!
    weak var kDelegate: TwoScrollViewDelegte?
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
        self.footerSectionView = sectionView
        self.clipsToBounds = true
        self.delegate = self
        self.dataSource = self
    }
    
    init(frame: CGRect,
         headerSectionView: UIView?,
         headerView: UIView,
         footerSectionView: UIView?,
         footerView: UIView) {
        super.init(frame: frame)
        
        self.footerView = footerView
        self.headerView = headerView
        self.footerSectionView = footerSectionView
        self.headerSectionView = headerSectionView
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
    
    func reloadHeaderView(height: CGFloat = 0){
        heightEqualContentSize(self.headerView, height: height)
        reload()
    }
    
    func reloadFooterView(height: CGFloat = 0){
        heightEqualContentSize(self.footerView, height: height)
        reload()
    }
    
    override func reload() {
        super.reload()
        
    }
    
    func heightEqualContentSize(_ view: UIView, height height0: CGFloat) {
        
        if let scrollView = view as? UIScrollView {
            scrollView.layoutIfNeeded()
            let newContentSizeHeight = scrollView.contentSize.height
            
            let height = min(self.frame.height, newContentSizeHeight)
            let addHeight = height - scrollView.frame.size.height
            let extraHeight = max(newContentSizeHeight - scrollView.contentOffset.y - scrollView.frame.height - height0, addHeight - height0)

            var tableViewScrllMargin = max(tableView.contentOffset.y - height0, 0)
            if scrollView == footerView {
                tableViewScrllMargin = (footerView.getCell()?.frame.origin.y ?? tableViewScrllMargin) + 1
            }            
            let tableViewScrllDistance = tableViewScrllMargin - tableView.contentOffset.y

            if height != scrollView.frame.size.height {
                scrollView.frame.size.height = height
            }else{
                tableView.setContentOffset(.init(x: 0, y: tableViewScrllMargin), animated: true)
                scrollView.setContentOffset(.init(x: 0, y: scrollView.contentOffset.y - tableViewScrllDistance + extraHeight), animated: true)

            }
        }
    }
    
    func cellFromView(_ view: UIView) -> UITableViewCell? {
        var superview = view.superview
        while !(superview is UITableViewCell) {
            superview = superview?.superview
            if superview == nil {
                return nil
            }
        }
        return superview as? UITableViewCell
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

extension TwoScrollView: MultipleScrollViewDelegate, MultipleScrollViewDataSource{
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
            return self.footerSectionView
        }
        return self.headerSectionView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.kDelegate?.twoScrollViewDidScroll(scrollView)
        
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
            self.kDelegate?.twoScrollView(self, footerViewScrollToBottom: view)
        }else if indexPath.section == 0{
            self.kDelegate?.twoScrollView(self, headerViewScrollToBottom: view)
        }
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, scrollToLastBottom tableView: UITableView) -> CGFloat{
        if hasRefresFooter {
            if footerRefreshControl.controlType == .pull {
                footerRefreshControl.controlType = .refreshing
                self.kDelegate?.twoScrollViewRefreshFooter(self)
                return footerPadding
            }
        }
        return -1
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, scrollToTop tableView: UITableView) -> CGFloat{
        if hasRefreshHeader {
            if headerRefreshControl.controlType == .pull {
                headerRefreshControl.controlType = .refreshing
                self.kDelegate?.twoScrollViewRefreshHeader(self)
                return headerPadding
            }
        }
        self.kDelegate?.twoScrollViewScrollTop(self)
        return -1
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, willDisplay view: UIView, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.kDelegate?.twoScrollView(self, footerViewWillShow: view)
        }
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.kDelegate?.twoScrollView(self, footerSectionViewWillShow: view)
    }
    
    
}

//
//class ZZRefreshControl: UIView {
//    var attributedTitle: NSAttributedString?
//
//}
