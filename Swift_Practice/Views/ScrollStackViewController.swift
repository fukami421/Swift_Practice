import UIKit

class ScrollStackViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareForStackView()
    }
    
    private func prepareForStackView() {
        let viewSize = stackView.bounds.height

        for _ in 1..<5 {
            let stackedView = UIView()
            stackedView.backgroundColor = .black
            stackedView.widthAnchor.constraint(equalToConstant: viewSize).isActive = true
            stackedView.heightAnchor.constraint(equalToConstant: viewSize).isActive = true
            stackView.addArrangedSubview(stackedView)
        }
    }
}

extension UIViewController {

    func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        overrideUserInterfaceStyle = .dark
    }
}
