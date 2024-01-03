//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2023/9/11.
//  ~/Library/Caches/org.swift.swiftpm/

import UIKit
import WWPrint
import WWOnBoardingViewController

// MARK: - ViewController
final class ViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    
    private lazy var pageViewControllerArray: [UIViewController] = {
        return [
            pageViewController(with: "Page1"),
            pageViewController(with: "Page2"),
            pageViewController(with: "Page3"),
        ]
    }()
    
    private let currentPage = 0
    private let isInfinityLoop = true
    private var onBoardingViewController: WWOnBoardingViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        pageContolSetting()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { initSetting(for: segue, sender: sender) }
    
    @IBAction func previousPage(_ sender: UIButton) { onBoardingViewController?.previousPage(completion: nil) }
    @IBAction func nextPage(_ sender: UIButton) { onBoardingViewController?.nextPage(completion: nil) }
    @IBAction func rootPage(_ sender: UIButton) { onBoardingViewController?.rootPage(completion: nil) }
    @IBAction func lastPage(_ sender: UIButton) { onBoardingViewController?.lastPage(completion: nil) }
    
    @objc func changeCurrentPage(_ sender: UIPageControl) {
        onBoardingViewController?.moveNextPage(to: sender.currentPage, for: .forward, animated: true, completion: nil)
    }
}

// MARK: - WWOnBoardingViewControllerDelegate
extension ViewController: WWOnBoardingViewControllerDelegate {
    
    func viewControllers(onBoardingViewController: WWOnBoardingViewController) -> [UIViewController] {
        return pageViewControllerArray
    }
    
    func willChangeViewController(_ onBoardingViewController: WWOnBoardingViewController, currentIndex: Int, nextIndex: Int, error: WWOnBoardingViewController.OnBoardingError?) {
        
        if let error = error { wwPrint("willChangeError: \(currentIndex) => \(nextIndex) / \(error)"); return }
        wwPrint("willChange: \(currentIndex) => \(nextIndex)")
    }
    
    func didChangeViewController(_ onBoardingViewController: WWOnBoardingViewController, finishAnimating finished: Bool, transitionCompleted: Bool, currentIndex: Int, nextIndex: Int, error: WWOnBoardingViewController.OnBoardingError?) {
        
        if let error = error { wwPrint("didChangeError: \(currentIndex) => \(nextIndex) / \(error)"); return }
        wwPrint("didChange: \(currentIndex) => \(nextIndex)")
        pageControl.currentPage = currentIndex
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 找到WWOnBoardingViewController
    /// - Parameters:
    ///   - segue: UIStoryboardSegue
    ///   - sender: Any?
    func initSetting(for segue: UIStoryboardSegue, sender: Any?) {
        
        onBoardingViewController = segue.destination as? WWOnBoardingViewController
        onBoardingViewController?.setting(onBoardingDelegate: self, isInfinityLoop: isInfinityLoop, currentIndex: currentPage)
    }
    
    /// 尋找Storyboard上的ViewController for StoryboardId
    /// - Parameter indentifier: String
    /// - Returns: UIViewController
    func pageViewController(with indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: indentifier)
    }
    
    /// [PageControl設定](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/ios-14-進化的-page-control-f097af2801a6)
    func pageContolSetting() {

        pageControl.allowsContinuousInteraction = true
        pageControl.numberOfPages = pageViewControllerArray.count
        pageControl.currentPage = currentPage
        pageControl.backgroundStyle = .prominent
        
        // pageControl.preferredIndicatorImage = UIImage(systemName: "sun.max.fill")
        (0..<pageControl.numberOfPages).forEach { pageControl.setIndicatorImage(UIImage(systemName: "\($0).circle"), forPage: $0) }
        pageControl.addTarget(self, action: #selector(changeCurrentPage(_:)), for: .valueChanged)
    }
}
