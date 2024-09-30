#include <iostream>
#include <opencv2/opencv.hpp>
#include <chrono>
#include <thread>
using namespace std;
using namespace cv;

string pixel_to_ASCII(int pixel_intensity)
{
    const string chars = "@%#*+=-:. ";
    string s = string(1, chars[pixel_intensity * chars.length() / 256]);
    return s;
}


int main(int argc, char const *argv[])
{
    string video_path = "/Users/kartik/Desktop/ascii_video/video.mp4";

    VideoCapture cap(video_path);
    double fps = cap.get(CAP_PROP_FPS);

    cout << "Frames per second: " << fps << endl;

    int frame_duration = 1000 / fps;

    int width = 150;
    int height = 50;

    int frame_width = cap.get(CAP_PROP_FRAME_WIDTH);
    int frame_height = cap.get(CAP_PROP_FRAME_HEIGHT);

    height = ((width * frame_height) / frame_width) * 0.47;
    // height = frame_height;
    // width = frame_width;
    // width = (height * frame_width) / frame_height;

    // cout << frame_height << " " << frame_width << endl;
    // 1080 1920
    // 1600 1346

    // height = frame_height;
    // width = frame_width;

    Mat frame, gray_frame, resized_frame;

    if (!cap.isOpened())
        throw "Error when reading steam_avi";

    for (;;)
    {
        cap >> frame;
        if (frame.empty())
            break;

        cv::cvtColor(frame, gray_frame, cv::COLOR_BGR2GRAY);
        resize(gray_frame, resized_frame, Size(width, height), 0, 0, INTER_LINEAR);

        string ascii_frame;
        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {
                ascii_frame += pixel_to_ASCII(resized_frame.at<uchar>(i, j));
            }
            ascii_frame += "\n";
        }
        system("clear");
        cout << ascii_frame;

        this_thread::sleep_for(chrono::milliseconds(frame_duration - 13));
    }

    return 0;
}
