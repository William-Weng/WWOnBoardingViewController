//
//  WWOnBoardingViewController.swift
//  WWOnBoardingViewController
//
//  Created by William.Weng on 2023/12/27.
//

import UIKit

// MARK: WWOnBoardingViewController
open class WWOnBoardingViewController: UIPageViewController {
    
    public typealias InfinityLoopInformation = (hasPrevious: Bool, hasNext: Bool)   // 無限Loop時有沒有上一頁？下一頁？
    
    public enum OnBoardingError: Error {
        case currentIndexOutOfRange                                                 // 頁數的Index超出範圍
        case arrayEmpty                                                             // 沒有任意ViewController
        case firstPage                                                              // 已經到了第一頁
        case lastPage                                                               // 已經到了最後一頁
        case pageIndex                                                              // 頁數錯誤
        case samePage                                                               // 是同一頁
    }
    
    public enum PageRotateDirection {
        case none                                                                   // 沒有滑
        case left                                                                   // 往左滑 ㊀
        case right                                                                  // 往右滑 ㊉
    }
    
    private weak var onBoardingDelegate: WWOnBoardingViewControllerDelegate?        // OnBoardingViewControllerDelegate
    
    private var currentIndex = 0                                                    // 現在所在的頁數
    private var nextIndex = 0                                                       // 下一頁的頁數
    private var pageRotateDirection: PageRotateDirection = .none                    // 滑動方向
    
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
        willTransitionToAction(pageViewController, pendingViewControllers: pendingViewControllers, lastPageIndex: pageViewControllerArray._index())
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
    ///   - currentIndex: 開始頁面
    func setting(onBoardingDelegate: WWOnBoardingViewControllerDelegate? = nil, currentIndex: Int = 0) {
        self.onBoardingDelegate = onBoardingDelegate
        self.currentIndex = currentIndex
    }
    
    /// [手動移到下一頁 => 超過就回到第一頁](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/scroll-view-決定捲動範圍的-content-layout-guide-6f606740918a)
    /// - Parameters:
    ///   - animated: [Bool](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/在-storyboard-設定-content-size-實現水平捲動的-scroll-view-2710fa247293)
    ///   - completion: ((Int) -> Void)?
    func nextPage(animated: Bool = true, completion: ((Int) -> Void)?) {
        
        var nextIndex = currentIndex + 1
        
        if (nextIndex >= pageViewControllerArray.count) {
            
            let hasNext = onBoardingDelegate?.infinityLoop(onBoardingViewController: self).hasNext ?? false
            
            if (!hasNext) {
                onBoardingDelegate?.didChangeViewController(self, finishAnimating: true, transitionCompleted: false, currentIndex: currentIndex, nextIndex: currentIndex, pageRotateDirection: .right, error: .lastPage)
                completion?(currentIndex); return
            }

            nextIndex = 0
        }
        
        onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: .right, error: nil)
        
        moveNextPage(to: nextIndex, for: .forward, animated: animated) { isFinished in
            
            if (isFinished) {
                self.nextIndex = nextIndex
                self.onBoardingDelegate?.didChangeViewController(self, finishAnimating: isFinished, transitionCompleted: true, currentIndex: nextIndex, nextIndex: nextIndex, pageRotateDirection: .none, error: nil)
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
            
            let hasPrevious = onBoardingDelegate?.infinityLoop(onBoardingViewController: self).hasPrevious ?? false
            
            if (!hasPrevious) {
                onBoardingDelegate?.didChangeViewController(self, finishAnimating: true, transitionCompleted: false, currentIndex: currentIndex, nextIndex: currentIndex, pageRotateDirection: .left, error: .firstPage)
                completion?(currentIndex); return
            }
            
            previousIndex = pageViewControllerArray.count - 1
        }

        onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: previousIndex, pageRotateDirection: .left, error: nil)
        
        moveNextPage(to: previousIndex, for: .reverse, animated: animated) { isFinished in
            
            if (isFinished) {
                self.currentIndex = previousIndex
                self.onBoardingDelegate?.didChangeViewController(self, finishAnimating: isFinished, transitionCompleted: true, currentIndex: previousIndex, nextIndex: previousIndex, pageRotateDirection: .none, error: nil)
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
            onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: .none, error: .arrayEmpty)
            completion?(currentIndex); return
        }
        
        if (currentIndex == rootIndex) { self.onBoardingDelegate?.didChangeViewController(self, finishAnimating: false, transitionCompleted: false, currentIndex: rootIndex, nextIndex: rootIndex, pageRotateDirection: .none, error: .firstPage); return }
        
        onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: rootIndex, pageRotateDirection: .left, error: nil)
        
        moveNextPage(to: rootIndex, for: .reverse, animated: animated) { isFinished in
            
            if (isFinished) {
                self.onBoardingDelegate?.didChangeViewController(self, finishAnimating: isFinished, transitionCompleted: true, currentIndex: rootIndex, nextIndex: rootIndex, pageRotateDirection: .none, error: nil)
                completion?(rootIndex)
            }
        }
    }
    
    /// [手動移到最後一頁](https://medium.com/彼得潘的-swift-ios-app-開發教室/作業-2-4-uipagecontrol-b66998bd0327)
    /// - Parameters:
    ///   - animated: Bool
    ///   - completion: ((Int) -> Void)?
    func lastPage(animated: Bool = true, completion: ((Int) -> Void)?) {
        
        let lastIndex = pageViewControllerArray.count - 1
        
        if (pageViewControllerArray.isEmpty) {
            onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: .none, error: .arrayEmpty)
            completion?(currentIndex); return
        }
                
        if (currentIndex == lastIndex) { self.onBoardingDelegate?.didChangeViewController(self, finishAnimating: false, transitionCompleted: false, currentIndex: lastIndex, nextIndex: lastIndex, pageRotateDirection: .none, error: .lastPage); return }
        
        onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: lastIndex, pageRotateDirection: .right, error: nil)
        
        moveNextPage(to: lastIndex, for: .forward, animated: animated) { isFinished in
            
            if (isFinished) {
                self.onBoardingDelegate?.didChangeViewController(self, finishAnimating: isFinished, transitionCompleted: true, currentIndex: lastIndex, nextIndex: lastIndex, pageRotateDirection: .none, error: nil)
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
            
            var pageRotateDirection: PageRotateDirection = .none
            
            switch direction {
            case .forward: pageRotateDirection = .right
            case .reverse: pageRotateDirection = .left
            @unknown default: break
            }
            
            onBoardingDelegate?.didChangeViewController(self, finishAnimating: false, transitionCompleted: false, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: pageRotateDirection, error: .pageIndex)
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
            onBoardingDelegate?.didChangeViewController(self, finishAnimating: false, transitionCompleted: false, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: .none, error: .currentIndexOutOfRange)
            return
        }
        
        dataSource = self
        delegate = self
        
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: { completion?($0) })
    }
    
    /// 將要換頁的動作
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - pendingViewControllers: [UIViewController]
    func willTransitionToAction(_ pageViewController: UIPageViewController, pendingViewControllers: [UIViewController], lastPageIndex: Int) {
        
        guard let nextController = pendingViewControllers.first,
              let nextIndex = pageViewControllerArray.firstIndex(of: nextController),
              let infinityLoop = onBoardingDelegate?.infinityLoop(onBoardingViewController: self)
        else {
            return
        }
        
        switch pageRotateDirection {
        case .right:
            currentIndex = nextIndex - 1
            if (infinityLoop.hasNext) { if (currentIndex < 0) { currentIndex = lastPageIndex }}
            
        case .left:
            currentIndex = nextIndex + 1
            if (infinityLoop.hasPrevious) { if (nextIndex == lastPageIndex) { currentIndex = 0 }}
            
        case .none:
            break
        }
                
        self.pageRotateDirection = pageRotateDirectionMaker(currentIndex: currentIndex, nextIndex: nextIndex, lastPageIndex: lastPageIndex)
        self.nextIndex = nextIndex
        
        onBoardingDelegate?.willChangeViewController(self, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: pageRotateDirection, error: nil)
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
            self.nextIndex = currentIndex
        }
        
        pageRotateDirection = .none
        onBoardingDelegate?.didChangeViewController(self, finishAnimating: finished, transitionCompleted: completed, currentIndex: currentIndex, nextIndex: nextIndex, pageRotateDirection: pageRotateDirection, error: nil)
    }
    
    /// 取得當前頁面的下一頁 ==> 下一頁如果超過總頁面的話就回到第一頁
    func nextViewController(for currentViewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pageViewControllerArray.firstIndex(of: currentViewController),
              let infinityLoop = onBoardingDelegate?.infinityLoop(onBoardingViewController: self)
        else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        
        if (!infinityLoop.hasNext) {
            self.currentIndex = pageViewControllerArray._index()
            onBoardingDelegate?.willChangeViewController(self, currentIndex: self.currentIndex, nextIndex: self.currentIndex, pageRotateDirection: .right, error: .lastPage)
            return nil
        }
        
        if (nextIndex >= pageViewControllerArray.count) { return pageViewControllerArray.first }
        
        return pageViewControllerArray[safe: nextIndex]
    }
    
    /// 取得當前頁面的上一頁 ==> 上一頁如果是負值的話，就去到最後一頁
    /// - Parameter currentViewController: UIViewController
    /// - Returns: UIViewController?
    func previousViewController(for currentViewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pageViewControllerArray.firstIndex(of: currentViewController),
              let infinityLoop = onBoardingDelegate?.infinityLoop(onBoardingViewController: self)
        else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        if (!infinityLoop.hasPrevious) {
            self.currentIndex = 0
            onBoardingDelegate?.willChangeViewController(self, currentIndex: self.currentIndex, nextIndex: self.currentIndex, pageRotateDirection: .left, error: .firstPage)
            return nil
        }
        
        if (previousIndex < 0) { return pageViewControllerArray.last }
        
        return pageViewControllerArray[safe: previousIndex]
    }
    
    /// 取得頁面的滑動方向 (左/右/沒有)
    /// - Parameters:
    ///   - currentIndex: Int
    ///   - nextIndex: Int
    ///   - array: [UIViewController]
    /// - Returns: PageRotateDirection
    func pageRotateDirectionMaker(currentIndex: Int, nextIndex: Int, lastPageIndex: Int) -> PageRotateDirection {
        
        let diffIndex = currentIndex - nextIndex
        var pageRotateDirection: PageRotateDirection = .none
        
        if (diffIndex < 0) { pageRotateDirection = .right }
        if (diffIndex > 0) { pageRotateDirection = .left }
        if (diffIndex == lastPageIndex) { pageRotateDirection = .right }
        if (diffIndex == -lastPageIndex) { pageRotateDirection = .left }

        return pageRotateDirection
    }
}
