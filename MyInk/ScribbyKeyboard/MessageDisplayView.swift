import UIKit

protocol MessageDisplayViewDelegate: class {
    func copyToClipboardButtonPressed()
    func continueEditingButtonPressed()
}

class MessageDisplayView: UIView {
    var view: UIView!
    weak var delegate: MessageDisplayViewDelegate?

    var image: UIImage? {
        get {
            return messageImageView.image
        }
        set {
            let size = (newValue?.size ?? CGSize.zero) * (1 / UIScreen.main.scale)
            messageImageView.image = newValue
            messageImageScrollView.contentSize = size
        }
    }

    @IBOutlet weak var useThisButton: UIButton!
    @IBOutlet weak var editThisButton: UIButton!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageImageScrollView: UIScrollView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    private func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)

//        messageImageScrollView.contentSize = messageImageView.bounds.size
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        return view
    }

    @IBAction func copyToClipboardButtonPressed(_ sender: Any) {
        delegate?.copyToClipboardButtonPressed()
    }

    @IBAction func continueEditingButtonPressed(_ sender: Any) {
        delegate?.continueEditingButtonPressed()
    }

}

extension MessageDisplayView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return messageImageView
    }
}
