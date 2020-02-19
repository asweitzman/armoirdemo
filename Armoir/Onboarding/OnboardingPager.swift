import UIKit

var backgroundColor: UIColor = UIColor()
var grayColor: UIColor = UIColor()
var beige2: UIColor = UIColor()

class OnboardingPager : UIPageViewController {

    func getStepZero() -> StepZero {
        return storyboard!.instantiateViewController(withIdentifier: "StepZero") as! StepZero
    }

    func getStepOne() -> StepOne {
        return storyboard!.instantiateViewController(withIdentifier: "StepOne") as! StepOne
    }

    func getStepTwo() -> StepTwo {
        return storyboard!.instantiateViewController(withIdentifier: "StepTwo") as! StepTwo
    }

    override func viewDidLoad() {
        dataSource = self
        setViewControllers([getStepZero()], direction: .forward, animated: false, completion: nil)
        backgroundColor = hexStringToUIColor(hex: "#FCF6F0")
        beige2 = hexStringToUIColor(hex: "#DED7CF")
        let black = hexStringToUIColor(hex: "#424242")
        grayColor = hexStringToUIColor(hex: "#E4DFD9")
        view.backgroundColor = backgroundColor
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        pageControl.pageIndicatorTintColor = grayColor
        pageControl.currentPageIndicatorTintColor = black
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

extension OnboardingPager : UIPageViewControllerDataSource {

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of:StepTwo.self) {
            return getStepOne()
        } else if viewController.isKind(of:StepOne.self) {
            return getStepZero()
        } else {
            return nil
        }
    }


    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of:StepZero.self) {
            return getStepOne()
        } else if viewController.isKind(of:StepOne.self) {
            return getStepTwo()
        } else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    

}
