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

    private lazy var pageViewControllerArray: [UIViewController] = {
        return [
            pageViewController(with: "Page1"),
            pageViewController(with: "Page2"),
            pageViewController(with: "Page3"),
        ]
    }()
    
    private var onBoardingViewController: WWOnBoardingViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { initSetting(for: segue, sender: sender) }
    
    @IBAction func previousPage(_ sender: UIButton) { onBoardingViewController?.previousPage(completion: nil) }
    @IBAction func nextPage(_ sender: UIButton) { onBoardingViewController?.nextPage(completion: nil) }
    @IBAction func rootPageAction(_ sender: UIButton) { onBoardingViewController?.rootPage(completion: nil) }
    @IBAction func lastPageAction(_ sender: UIButton) { onBoardingViewController?.lostPage(completion: nil) }
}

// MARK: - WWOnBoardingViewControllerDelegate
extension ViewController: WWOnBoardingViewControllerDelegate {
   
    func viewControllers(onBoardingViewController: WWOnBoardingViewController) -> [UIViewController] {
        return pageViewControllerArray
    }
    
    func changeViewController(_ onBoardingViewController: WWOnBoardingViewController, didFinishAnimating finished: Bool, currentIndex: Int, nextIndex: Int, error: WWOnBoardingViewController.OnBoardingError?) {
        
        if let error = error { wwPrint("error => \(error)"); return }
        wwPrint("currentIndex => \(currentIndex), nextIndex => \(nextIndex)")
    }
}

// MARK: - 小工具
private extension ViewController {
    
    func initSetting(for segue: UIStoryboardSegue, sender: Any?) {
        onBoardingViewController = segue.destination as? WWOnBoardingViewController
        onBoardingViewController?.setting(onBoardingDelegate: self, isInfinityLoop: true, currentIndex: 1)
    }
    
    func pageViewController(with indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: indentifier)
    }
}
