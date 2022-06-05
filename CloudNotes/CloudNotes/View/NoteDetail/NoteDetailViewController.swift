import UIKit

class NoteDetailViewController: UIViewController {
    // MARK: - Property
    weak var delegate: NoteDetailViewControllerDelegate?
    private var textView: UITextView = {
        let textview = UITextView(frame: .zero)
        textview.font = .preferredFont(forTextStyle: .caption1)
        textview.translatesAutoresizingMaskIntoConstraints = false
        return textview
    }()
    // MARK: - ViewLifeCycle
    override func loadView() {
        self.configureViewComponent()
        self.textView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTextViewLayout()
        self.setUpNavigationItems()
        self.textView.selectedRange = NSRange("\n") ?? NSRange()
    }
    // MARK: - Method
    
    private func configureViewComponent() {
        self.view = .init()
        self.view.backgroundColor = .white
        self.view.addSubview(textView)
    }
    func setUpText(with data: MemoType) {
        guard let title = data.title, let body = data.body
        else {
            return
        }
        self.textView.text = "\(title)\n\(body)"
    }
    
    private func setUpNavigationItems() {
        let circleImage = UIImage(systemName: "ellipsis.circle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: circleImage,
            style: .plain,
            target: self,
            action: #selector(tappedShareButton(sender: ))
        )
    }
    
    @objc private func tappedShareButton(sender: AnyObject) {
        self.delegate?.noteDetailViewController(didTapRightBarButton: self, sender: sender)
    }
    
    private func setUpTextViewLayout() {
        NSLayoutConstraint.activate([
            self.textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
// MARK: - UITextView Delegate
extension NoteDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let body = textView.text ?? "" 
        self.delegate?.noteDetailViewController(self, didChangeBody: body)
    }
}
