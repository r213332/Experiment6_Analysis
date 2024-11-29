import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os


def GazeMovement(subject: str):
    csvFiles = glob.glob("./data/" + subject + "/*.csv")

    AllData = []
    for csvFile in csvFiles:
        df = pd.read_csv(csvFile)
        AllData.append(df)

    control = []
    near = []
    far = []

    for data in AllData:
        controlData = data.query("mode == 0")
        nearData = data.query("mode == 1")
        farData = data.query("mode == 2")

        control += functions.extendedGetRT(controlData)
        near += functions.extendedGetRT(nearData)
        far += functions.extendedGetRT(farData)

    # CSVに出力するためのデータフレームを作成
    # ディレクトリが存在しない場合のみ作成
    if not os.path.exists("./processedData/" + subject):
        os.makedirs("./processedData/" + subject)

    pd.DataFrame(
        {
            "RT": [x["RT"] for x in control],
            "GazeRT": [x["GazeRT"] for x in control],
            "StimulusHorizontalDegree": [
                x["StimulusHorizontalDegree"] for x in control
            ],
            "StimulusVerticalDegree": [x["StimulusVerticalDegree"] for x in control],
            "InitialGazeDistance": [x["InitialGazeDistance"] for x in control],
        }
    ).to_csv("./processedData/" + subject + "/controlGazeRT.csv", index=False)
    pd.DataFrame(
        {
            "RT": [x["RT"] for x in near],
            "GazeRT": [x["GazeRT"] for x in near],
            "StimulusHorizontalDegree": [x["StimulusHorizontalDegree"] for x in near],
            "StimulusVerticalDegree": [x["StimulusVerticalDegree"] for x in near],
            "InitialGazeDistance": [x["InitialGazeDistance"] for x in near],
        }
    ).to_csv("./processedData/" + subject + "/nearGazeRT.csv", index=False)
    pd.DataFrame(
        {
            "RT": [x["RT"] for x in far],
            "GazeRT": [x["GazeRT"] for x in far],
            "StimulusHorizontalDegree": [x["StimulusHorizontalDegree"] for x in far],
            "StimulusVerticalDegree": [x["StimulusVerticalDegree"] for x in far],
            "InitialGazeDistance": [x["InitialGazeDistance"] for x in far],
        }
    ).to_csv("./processedData/" + subject + "/farGazeRT.csv", index=False)

    # 全視線の動きをグラフ化
    # control_GazeMovement_all = [[x['GazeMovement'],x['GazeRT']] for x in control if x['GazeMovement'] is not None]
    # near_GazeMovement_all = [[x['GazeMovement'],x['GazeRT']] for x in near if x['GazeMovement'] is not None]
    # far_GazeMovement_all = [[x['GazeMovement'],x['GazeRT']] for x in far if x['GazeMovement'] is not None]

    # fig, axs = plt.subplots(1,3)
    # fig.suptitle("Gaze Movement")
    # axs[0].set_title("Control")
    # for i, gaze_array in enumerate(control_GazeMovement_all):
    #     axs[0].plot(gaze_array[0], label=f'{gaze_array[1]}')
    # axs[0].set_title("Control")
    # axs[0].legend()

    # axs[1].set_title("Near")
    # for i, gaze_array in enumerate(near_GazeMovement_all):
    #     axs[1].plot(gaze_array[0], label=f'{gaze_array[1]}')
    # axs[1].set_title("Near")
    # axs[1].legend()

    # axs[2].set_title("Far")
    # for i, gaze_array in enumerate(far_GazeMovement_all):
    #     axs[2].plot(gaze_array[0], label=f'{gaze_array[1]}')
    # axs[2].set_title("Far")
    # axs[2].legend()

    # plt.legend()
    # plt.show()


# 1被験者のデータを処理
# subject = "subjectL"
# GazeMovement(subject)

# 全員のデータを処理
search_path = os.path.join(".", "data", "*subject*")
directories = glob.glob(search_path)

# ディレクトリ名のリストを取得
directory_names = [os.path.basename(directory) for directory in directories]

# print(directory_names)
for subject in directory_names:
    GazeMovement(subject)
    print("finish ", subject)
