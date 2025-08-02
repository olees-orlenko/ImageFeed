import UIKit
import WebKit


final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {

    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    // MARK: - Private UI Properties
    
    private var webView = WKWebView()
    private var backButton = UIBarButtonItem()
    private var progressView = UIProgressView()
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        setupView()
        setupWebView()
        setupBackButton()
        setProgress()
        setupConstraints()
    }
    
    // MARK: - Progress Update
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }

    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
    }
    
    // MARK: - WebView Setup
    
    private func setupWebView() {
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.contentMode = .scaleToFill
        view.backgroundColor = UIColor(resource: .ypWhite)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }
    
    // MARK: - ProgressView Setup
    
    private func setProgress() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(resource: .ypBlack)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
    }
    
    // MARK: - BackButton Setup
    
    private func setupBackButton() {
        backButton = UIBarButtonItem(image: UIImage(named: "nav_back_button"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBackButton))
        backButton.tintColor = UIColor(named: "YP Black")
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - Layout Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapBackButton(){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Public Methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
