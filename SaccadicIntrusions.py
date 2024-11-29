import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os


def SaccadicIntrusions(subject: str):
    csvFiles = glob.glob("./data/" + subject + "/*.csv")

    AllData = []
    for csvFile in csvFiles:
        df = pd.read_csv(csvFile)
        AllData.append(df)

    control = []
    near = []
    far = []

    for data in AllData:
        controlData, nearData, farData = functions.getSI(data)

        control += controlData
        near += nearData
        far += farData

    # CSVに出力するためのデータフレームを作成
    # ディレクトリが存在しない場合のみ作成
    if not os.path.exists("./processedData/" + subject):
        os.makedirs("./processedData/" + subject)

    pd.DataFrame(
        {
            "SIFrequency": [x["SIFrequency"] for x in control],
        }
    ).to_csv("./processedData/" + subject + "/controlSIFrequency.csv", index=False)
    pd.DataFrame(
        {
            "SIFrequency": [x["SIFrequency"] for x in near],
        }
    ).to_csv("./processedData/" + subject + "/nearSIFrequency.csv", index=False)
    pd.DataFrame(
        {
            "SIFrequency": [x["SIFrequency"] for x in far],
        }
    ).to_csv("./processedData/" + subject + "/farSIFrequency.csv", index=False)

    # # 全視線の動きをグラフ化
    control_GazeMovement_all = [[x["angle"], x["SIFrequency"]] for x in control]
    near_GazeMovement_all = [[x["angle"], x["SIFrequency"]] for x in near]
    far_GazeMovement_all = [[x["angle"], x["SIFrequency"]] for x in far]

    # plt.figure()
    # plt.title("control")
    # for i, gaze_array in enumerate(control_GazeMovement_all):
    #     plt.plot(gaze_array[0],label="SIcount: "+str(gaze_array[1]))

    # plt.legend()
    # # plt.show()

    # plt.figure()
    # plt.title("near")
    # for i, gaze_array in enumerate(near_GazeMovement_all):
    #     plt.plot(gaze_array[0],label="SIcount: "+str(gaze_array[1]))

    # plt.legend()
    # # plt.show()

    # plt.figure()
    # plt.title("far")
    # for i, gaze_array in enumerate(far_GazeMovement_all):
    #     plt.plot(gaze_array[0],label="SIcount: "+str(gaze_array[1]))

    # plt.legend()
    # plt.show()


# 1被験者のデータを処理
# subject = "testData"
# SaccadicIntrusions(subject)

# # 全員のデータを処理
search_path = os.path.join(".", "data", "*subject*")
directories = glob.glob(search_path)

# ディレクトリ名のリストを取得
directory_names = [os.path.basename(directory) for directory in directories]

# print(directory_names)
for subject in directory_names:
    SaccadicIntrusions(subject)
    print("finish ", subject)
