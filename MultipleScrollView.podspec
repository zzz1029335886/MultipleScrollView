Pod::Spec.new do |spec|

  spec.name         = "MultipleScrollView"
  spec.version      = "0.0.2"
  spec.summary      = "Multiple scrollView (e.g.,UITableView, UICollectionView,WKWebView) in one page"
  spec.description  = <<-DESC
    Multiple scrollView (e.g.,UITableView, UICollectionView,WKWebView) in one page, Solve the problem of rolling.
                   DESC
  spec.homepage     = "https://github.com/zzz1029335886/MultipleScrollView"
  spec.license      = "MIT"
  spec.author             = { "zerry" => "16664476+zzz1029335886@users.noreply.github.com" }
  spec.platform     = :ios, '9.0'
  spec.source       = { :git => "https://github.com/zzz1029335886/MultipleScrollView.git", :tag => "#{spec.version}" }
  spec.source_files  = "Classes", "ZZMultipleScrollView/MultipleScrollView/**/*.{h,m}"
  spec.requires_arc = true
  
end
