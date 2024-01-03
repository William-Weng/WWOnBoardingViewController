//
//  Protocol.swift
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
    
    /// 將要換頁功能
    /// - Parameters:
    ///   - onBoardingViewController: WWOnBoardingViewController
    ///   - currentIndex: 當前頁面
    ///   - nextIndex: 將要換的下一頁
    ///   - pageRotateDirection: 換頁的方向
    ///   - error: WWOnBoardingViewController.OnBoardingError?
    func willChangeViewController(_ onBoardingViewController: WWOnBoardingViewController, currentIndex: Int, nextIndex: Int, pageRotateDirection: WWOnBoardingViewController.PageRotateDirection, error: WWOnBoardingViewController.OnBoardingError?)
    
    /// [換頁完成功能](https://disp.cc/b/KnucklesNote/9XZn)
    /// - Parameters:
    ///   - onBoardingViewController: [OnBoardingViewController](https://disp.cc/b/KnucklesNote/8553)
    ///   - finished: [動畫完成與否](https://disp.cc/b/KnucklesNote/9VtJ)
    ///   - completed: 有沒有換頁成功？ (同一頁)
    ///   - currentIndex: 目前頁的Index
    ///   - nextIndex: 下一頁的Index
    ///   - pageRotateDirection: 換頁的方向
    ///   - error: WWOnBoardingViewController.OnBoardingError?
    func didChangeViewController(_ onBoardingViewController: WWOnBoardingViewController, finishAnimating finished: Bool, transitionCompleted completed: Bool, currentIndex: Int, nextIndex: Int, pageRotateDirection: WWOnBoardingViewController.PageRotateDirection, error: WWOnBoardingViewController.OnBoardingError?)
}
