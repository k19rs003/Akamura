//
//  TestTopViewController.swift
//  mapProject
//
//  Created by Tamai on 2021/10/24.
//

import UIKit

class TestTopViewController : UIViewController, UIScrollViewDelegate{//実験用無視してよし
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    static let LABEL_TAG = 100
    // ページビューの背景色
    private let colorArray: [UIColor] = [.red,.green,.blue,.yellow,.purple]
    // 現在表示されているページ
    private var page: Int = 0
    // ScrollViewをスクロールする前の位置
    private var startPoint: CGPoint!
    // 表示するページビューの配列
    private var pageViewArray: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // scrollViewの表示サイズ
        let size = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        // 5ページ分のcontentSize
        let contentRect = CGRect(x: 0, y: 0, width: size.width * CGFloat(5), height: size.height)
        let contentView = UIView(frame: contentRect)
        
        for i in 0..<5 {
            let pageView = UIView(frame: CGRect(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height))
            pageView.backgroundColor = colorArray[i]
            let label = UILabel()
            label.text = "View_\(i)"
            label.backgroundColor = .white
            label.sizeToFit()
            label.center = pageView.center
            label.frame.origin.x = 10
            // あとで使いたいのでtagを設定
            label.tag = TestTopViewController.LABEL_TAG
            pageView.addSubview(label)
            contentView.addSubview(pageView)
            // あとで再描画をできるように保持
            pageViewArray.append(pageView)
        }
        // scrollViewに５ページ分のViewとサイズを設定する
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        // ５つの真ん中のViewを初期位置に変更
        scrollView.contentOffset = CGPoint(x: ((size.width * 2)), y: 0)
        startPoint = scrollView.contentOffset;
        // 最初に表示するページ
        page = 0
        // 各ページの再描画
        setPageView()
    }
    
    // 各ページの再描画
    func setPageView() {
        for i in 0..<pageViewArray.count {
            // ５つあるビューの真ん中が現在選択されているページになるようにする
            let index = getPageIndex(page: page + (i - 2))
            pageViewArray[i].backgroundColor = colorArray[index]
            // tagからラベルを取得しtextを再設定
            let label: UILabel = pageViewArray[i].viewWithTag(TestTopViewController.LABEL_TAG) as! UILabel
            label.text = "View_\(index)"
            label.sizeToFit()
        }
    }
    
    // ページがpageViewArray.count以上や０以下になった時に適切な値を返す
    func getPageIndex(page: Int) -> Int {
        var index = page
        if index < 0 {
            index = (pageViewArray.count + page)
        } else if index >= pageViewArray.count {
            index = page - pageViewArray.count
        }
        return index
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 左右のスワイプを判断するのでスクロール開始時に設定
        self.startPoint = scrollView.contentOffset;
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if startPoint.x > scrollView.contentOffset.x {//左スワイプ
            pageChange(num: -1)
        } else if startPoint.x < scrollView.contentOffset.x {//右スワイプ
            pageChange(num: 1)
        }
        // scrollViewのスクロール位置を真ん中のビューに戻す
        let point = CGPoint(x: ((scrollView.frame.size.width * 2)), y: 0)
        scrollView.setContentOffset(point, animated: false)
        // pageが切り替わったのでビューを再描画
        setPageView()
    }
    
    // ページがループできるように適切な値をセットする
    private func pageChange(num:Int) {
        if page + num < 0 {
            page = pageViewArray.count - 1
        } else if page + num >= pageViewArray.count {
            page = 0
        } else {
            page = page + num
        }
    }
}
