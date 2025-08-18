using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StageSelect : MonoBehaviour
{
    [SerializeField] private TimerController timerController;

    private void OnTriggerEnter(Collider other)
    {
        if (this.tag == "stg1" && other.CompareTag("Player"))
        {
            SceneManager.LoadScene("Stage1");
            Debug.Log(other);
        }
        else if (this.tag == "stg2" && other.CompareTag("Player"))
        {
            SceneManager.LoadScene("Stage2");
        }
        else if (this.tag == "stg3" && other.CompareTag("Player"))
        {
            SceneManager.LoadScene("Stage3");
        }
        else if (this.tag == "Portal" && other.CompareTag("Player"))
        {
            if (timerController != null)
            {
                timerController.GameOver();
            }
            else
            {
                Debug.LogWarning("TimerController reference is not set.");
            }
        }
    }
}
