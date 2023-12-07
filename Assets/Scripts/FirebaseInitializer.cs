using Firebase;
using UnityEngine;

public class FirebaseInitializer : MonoBehaviour
{
    private void Start()
    {
        FirebaseApp.CheckAndFixDependenciesAsync().ContinueWith(task =>
        {
            var dependencyStatus = task.Result;
            if (dependencyStatus == Firebase.DependencyStatus.Available)
            {
                // Firebase is available, you can initialize and use Firebase services here.
                FirebaseApp app = FirebaseApp.DefaultInstance;
                // Set a flag or perform any actions that indicate Firebase is ready to use.
            }
            else
            {
                UnityEngine.Debug.LogError(System.String.Format(
                    "Could not resolve all Firebase dependencies: {0}", dependencyStatus));
                // Firebase Unity SDK is not safe to use here.
            }
        });
    }
}
