import UIKit
import WebKit

// MARK: - Constants

enum WebViewConstants {
    // MARK: - Static Properties
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: - Delegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController{
    
    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var webView = WKWebView()
    private var backButton = UIBarButtonItem()
    private var progressView = UIProgressView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
        setupView()
        setupWebView()
        setupBackButton()
        setProgress()
        setupConstraints()
    }
    
    // MARK: - Authentication
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
    }
    
    // MARK: - WebView Setup
    
    private func setupWebView() {
        webView.contentMode = .scaleToFill
        view.backgroundColor = UIColor(named: "YP White")
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }
    
    // MARK: - ProgressView Setup
    
    private func setProgress() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(named: "YP Black")
        progressView.progress = 0.5
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
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
