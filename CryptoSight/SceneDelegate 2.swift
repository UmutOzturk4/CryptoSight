import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Get the storyboard and initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let initialViewController = storyboard.instantiateInitialViewController() else { return }
        
        // Create and setup window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
        self.window = window
        
        // Apply the saved dark mode setting
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being removed
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Apply dark mode setting when becoming active
        if let window = self.window {
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene is being inactive
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when returning from background
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when entering background
    }
} 