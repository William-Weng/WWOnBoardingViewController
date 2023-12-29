//
//  WWOnBoardingViewController.swift
//  WWOnBoardingViewController
//
//  Created by iOS on 2023/12/27.
//

import UIKit

// MARK: - WWOnBoardingViewControllerDelegate
public protocol WWOnBoardingViewControllerDelegate: AnyObject {
    
    /// [換頁的UIViewControllers](https://disp.cc/b/KnucklesNote/9XMd)
    /// - Parameter onBoardingViewController: [OnBoardingViewController](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/隨著換頁更新的-page-control-小圓點-24f631c1928c)
    /// - Returns: [UIViewController]
    func viewControllers(onBoardingViewController: WWOnBoardingViewController) -> [UIViewController]
    
    /// [換頁功能](https://disp.cc/b/KnucklesNote/9XZn)
    /// - Parameters:
    ///   - onBoardingViewController: [OnBoardingViewController](https://disp.cc/b/KnucklesNote/8553)
    ///   - finished: [動畫完成與否](https://disp.cc/b/KnucklesNote/9VtJ)
    ///   - currentIndex: 目前頁的Index
    ///   - nextIndex: 下一頁的Index
    ///   - error: Error?
    func changeViewController(_ onBoardingViewController: WWOnBoardingViewController, didFinishAnimating finished: Bool, currentIndex: Int, nextIndex: Int, error: WWOnBoardingViewController.OnBoardingError?)
}

// MARK: WWOnBoardingViewController
open class WWOnBoardingViewController: UIPageViewController {
    
    public enum OnBoardingError: Error {
        case currentIndexOutOfRange                                                 // 頁數的Index超出範圍
        case arrayEmpty                                                             // 沒有任意ViewController
        case firstPage                                                              // 已經到了第一頁
        case lastPage                                                               // 已經到了最後一頁
        case pageIndex                                                              // 頁數錯誤
    }
    
    private weak var onBoardingDelegate: WWOnBoardingViewControllerDelegate?        // OnBoardingViewControllerDelegate
    private var isInfinityLoop = false                                              // 是否要無限滾動
    private var currentIndex = 0                                                    // 現在所在的頁數
    
    private var nextIndex = 0                                                       // 下一頁的頁數
    private var pageViewControllerArray: [UIViewController] {
        onBoardingDelegate?.viewControllers(onBoardingViewController: self) ?? []   // 取得引導頁的ViewController們
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        pageViewControllerSetting(completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource
extension WWOnBoardingViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(for: viewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return previousViewController(for: viewController)
    }
}

// MARK: - UIPageViewControllerDelegate
extension WWOnBoardingViewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        willTransitionToAction(pageViewController, pendingViewControllers: pendingViewControllers)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        transitionCompletedAction(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
    }
}

// MARK: - 公開功能
public extension WWOnBoardingViewController {
    
    /// [相關設定](https://www.cnblogs.com/XYQ-208910/p/4850281.html)
    /// - Parameters:
    ///   - onBoardingDelegate: WWOnBoardingViewControllerDelegate?
    ///   - isInfinityLoop: 是否無限迴轉
    ///   - currentIndex: 開始頁面
    func setting(onBoardingDelegate: WWOnBoardingViewControllerDelegate? = nil, isInfinityLoop: Bool = false, currentIndex: Int = 0) {
        
        self.onBoardingDelegate = onBoardingDelegate
        self.isInfinityLoop = isInfinityLoop
        self.currentIndex = currentIndex
    }
    
    /// [手動移到下一頁 => 超過就回到第一頁](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/scroll-view-決定捲動範圍的-content-layout-guide-6f606740918a)
    /// - Parameters:
    ///   - animated: [Bool](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/在-storyboard-設定-content-size-實現水平捲動的-scroll-view-2710fa247293)
    ///   - completion: ((Int) -> Void)?
    func nextPage(animated: Bool = true, completion: ((Int) -> Void)?) {
        
        var nextIndex = currentIndex + 1
        
        if (nextIndex >= pageViewControllerArray.count) {
            
            if (!isInfinityLoop) {
                onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .lastPage)
                completion?(currentIndex); return
            }

            nextIndex = 0
        }
        
        moveNextPage(to: nextIndex, for: .forward, animated: animated) { isFinished in
            
            if (isFinished) {
                self.onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: self.currentIndex, nextIndex: nextIndex, error: nil)
                completion?(nextIndex)
            }
        }
    }
    
    /// [手動移到上一頁 => 不足就回到最後一頁](https://medium.com/@sharma17krups/onboarding-view-with-swiftui-b26096049be3)
    /// - Parameters:
    ///   - animated: [Bool](https://dev.to/domanovdev/swiftui-onboarding-view-1165)
    ///   - completion: ((Int) -> Void)?
    func previousPage(animated: Bool = true, completion: ((Int) -> Void)?) {
        
        var previousIndex = currentIndex - 1
        
        if (previousIndex < 0) {
            
            if (!isInfinityLoop) {
                onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .firstPage)
                completion?(currentIndex); return
            }
            
            previousIndex = pageViewControllerArray.count - 1
        }

        moveNextPage(to: previousIndex, for: .reverse, animated: animated) { isFinished in
            
            if (isFinished) {
                self.onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: previousIndex, nextIndex: self.nextIndex, error: nil)
                completion?(previousIndex)
            }
        }
    }
    
    /// [手動移到第一頁](https://youtu.be/Y2xTTcdGMiY)
    /// - Parameters:
    ///   - animated: Bool
    ///   - completion: ((Int) -> Void)?
    func rootPage(animated: Bool = true, completion: ((Int) -> Void)?) {
        
        let rootIndex = 0

        if (pageViewControllerArray.isEmpty) {
            onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .arrayEmpty)
            completion?(currentIndex); return
        }
        
        moveNextPage(to: rootIndex, for: .reverse, animated: animated) { isFinished in
            
            if (isFinished) {
                self.onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: rootIndex, nextIndex: self.nextIndex, error: nil)
                completion?(rootIndex)
            }
        }
    }
    
    /// [手動移到最後一頁](https://medium.com/彼得潘的-swift-ios-app-開發教室/作業-2-4-uipagecontrol-b66998bd0327)
    /// - Parameters:
    ///   - animated: Bool
    ///   - completion: ((Int) -> Void)?
    func lostPage(animated: Bool = true, completion: ((Int) -> Void)?) {
        
        let lastIndex = pageViewControllerArray.count - 1
        
        if (pageViewControllerArray.isEmpty) {
            onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .arrayEmpty)
            completion?(currentIndex); return
        }
        
        moveNextPage(to: lastIndex, for: .forward, animated: animated) { isFinished in
            if (isFinished) {
                self.onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: lastIndex, nextIndex: self.nextIndex, error: nil)
                completion?(lastIndex)
            }
        }
    }
    
    /// [移動到該頁面 => 有動畫按太快會當掉](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/ios-14-進化的-page-control-f097af2801a6)
    /// - Parameters:
    ///   - pageIndex: Int
    ///   - direction: UIPageViewController.NavigationDirection
    ///   - animated: 動畫
    ///   - completion: ((Bool) -> Void)?
    func moveNextPage(to pageIndex: Int, for direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)?) {
        
        guard let nextPage = pageViewControllerArray[safe: pageIndex] else {
            onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .pageIndex)
            return
        }
        
        setViewControllers([nextPage], direction: direction, animated: animated, completion: { [weak self] isFinished in
            if (isFinished) { self?.currentIndex = pageIndex }
            completion?(isFinished)
        })
    }
}

// MARK: - 小工具
private extension WWOnBoardingViewController {
        
    /// PageView的初始化設定 ==> 設定總頁數，切換到第一頁
    /// - Parameter completion: ((Bool) -> Void)?
    func pageViewControllerSetting(completion: ((Bool) -> Void)?) {
        
        guard let firstViewController = pageViewControllerArray[safe: currentIndex] else {
            onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .currentIndexOutOfRange)
            return
        }
        
        dataSource = self
        delegate = self
        
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: { isFinished in
            completion?(isFinished)
        })
    }
    
    /// 將要換頁的動作
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - pendingViewControllers: [UIViewController]
    func willTransitionToAction(_ pageViewController: UIPageViewController, pendingViewControllers: [UIViewController]) {
        
        guard let nextController = pendingViewControllers.first,
              let nextIndex = pageViewControllerArray.firstIndex(of: nextController)
        else {
            return
        }
        
        self.nextIndex = nextIndex
        onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: nil)
    }
    
    /// 換頁完成的動作
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - finished: Bool
    ///   - previousViewControllers: [UIViewController]
    ///   - completed: Bool
    func transitionCompletedAction(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed) {
            
            guard let currentController = pageViewController.viewControllers?.first,
                  let currentIndex = pageViewControllerArray.firstIndex(of: currentController)
            else {
                return
            }
            
            self.currentIndex = currentIndex
        }
        
        onBoardingDelegate?.changeViewController(self, didFinishAnimating: finished, currentIndex: currentIndex, nextIndex: nextIndex, error: nil)
    }
    
    /// 取得當前頁面的下一頁 ==> 下一頁如果超過總頁面的話就回到第一頁
    func nextViewController(for currentViewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pageViewControllerArray.firstIndex(of: currentViewController) else { return nil }
        
        let nextIndex = currentIndex + 1
        
        if (nextIndex >= pageViewControllerArray.count) {
            
            if (!isInfinityLoop) {
                onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .lastPage)
                return nil
            }
            
            return pageViewControllerArray.first
        }
        
        return pageViewControllerArray[nextIndex]
    }
    
    /// 取得當前頁面的上一頁 ==> 上一頁如果是負值的話，就去到最後一頁
    /// - Parameter currentViewController: UIViewController
    /// - Returns: UIViewController?
    func previousViewController(for currentViewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pageViewControllerArray.firstIndex(of: currentViewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        if (previousIndex < 0) {
            
            if (!isInfinityLoop) {
                onBoardingDelegate?.changeViewController(self, didFinishAnimating: false, currentIndex: currentIndex, nextIndex: nextIndex, error: .firstPage)
                return nil
            }
            
            return pageViewControllerArray.last
        }
        
        return pageViewControllerArray[previousIndex]
    }
}
