import UIKit
import WebKit

final class WebViewViewController: UIViewController{
    
    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
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
                 self.updateProgress()
             })
        webView.navigationDelegate = self
        loadAuthView()
        setupView()
        setupWebView()
        setupBackButton()
        setProgress()
        setupConstraints()
        updateProgress()
    }
    
    // MARK: - Progress Update
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    // MARK: - Authentication
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка: Не удалось создать URLComponents из WebViewConstants.unsplashAuthorizeURLString")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("Ошибка: Не удалось создать URL из URLComponents")
            return
        }
        let request = URLRequest(url: url)
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        webView.load(request)
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
    }
    
    // MARK: - WebView Setup
    
    private func setupWebView() {
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
