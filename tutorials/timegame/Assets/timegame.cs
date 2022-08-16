using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class timegame : MonoBehaviour
{
    private static float startTime;
    private static float guessTime;
    private static int targetTime;
    private static bool gameStart;

    // Start is called before the first frame update
    void Start()
    {
        StartGame();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) {
            if (gameStart) {
                guessTime = Time.time - startTime;
                ReportResults(guessTime, startTime, targetTime);
                print("Play again?");
                gameStart = false;
                StartGame();
            } else {
                startTime = Time.time;
                gameStart = true;
                print("GO!");
            }
        }
    }

    void StartGame() 
    {
        targetTime = Random.Range(3, 10);
        print("Press the spacebar when you think the allocated time has elapsed!");
        print("Target time: " + targetTime + " seconds. Press Space to begin.");
    }

    void ReportResults(float guessTime, float startTime, int targetTime) 
    {
        string performanceComment;
        float diff = guessTime - targetTime;
        if (Mathf.Abs(diff) < 0.5) {
            performanceComment = "Nailed it!";
        } else if (Mathf.Abs(diff) < 1.5) {
            performanceComment = "Nice job!";
        } else if (Mathf.Abs(diff) < 3) {
            performanceComment = "Sorta...";
        } else {
            performanceComment = "Atrocious.";
        }
        print("You guessed " + guessTime + " seconds. " + performanceComment);
    }
}
