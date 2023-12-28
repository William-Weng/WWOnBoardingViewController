# WWOnBoardingViewController

[![Swift-5.6](https://img.shields.io/badge/Swift-5.6-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-14.0](https://img.shields.io/badge/iOS-14.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWOnBoardingViewController) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)

Use UIPageViewController to simply implement the function of the guide page.

使用UIPageViewController來簡單實現引導頁面的功能。

## [Achievements display - 成果展示](https://www.hkweb.com.hk/blog/ui設計基礎知識：引導頁對ui設計到底有什麼作用/)
![WWOnBoardingViewController](./Example1.gif) ![WWOnBoardingViewController](./Example2.gif) ![WWOnBoardingViewController](./Example3.gif)

## [Installation with Swift Package Manager - 安裝方式](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)

```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWOnBoardingViewController.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage - 使用方式

Set UIPageViewController to WWOnBoardingViewController.

將UIPageViewController設定成WWOnBoardingViewController。

![WWOnBoardingViewController](./Example.png)

## Example - 程式範例
```swift
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
```

