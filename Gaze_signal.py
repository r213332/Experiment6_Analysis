import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import kstest
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os
import shutil
import json


def GazeDistribution(subject: str):
    csvFiles = glob.glob("./data/" + subject + "/*.csv")

    AllData = []
    for csvFile in csvFiles:
        df = pd.read_csv(csvFile)
        AllData.append(df)

    print(len(AllData))
    control = []
    near = []
    far = []

    for data in AllData:
        controlData = data.query("mode == 0")
        nearData = data.query("mode == 1")
        farData = data.query("mode == 2")

        control += functions.extendedGetGazeDistribution(controlData)
        near += functions.extendedGetGazeDistribution(nearData)
        far += functions.extendedGetGazeDistribution(farData)

    saccadics = []
    plt.figure()
    for i, data in enumerate([control, near, far]):
        # dataがcontrol,near,farのいずれか取得
        label = ["control", "near", "far"][i]

        x = [item["GazeDistribution_x"] for item in data]
        y = [item["GazeDistribution_y"] for item in data]
        diff = [item["Distancefromfixation"] for item in data]
        degree = [item["GazeDegree"] for item in data]

        saccadic = [
            item["GazeDegree"] for item in data if item["GazeDegree"] is not None
        ]

        saccadic = [item for item in saccadic if item > 100]

        saccadicCount = len(saccadic)
        # for item in degree:
        #     flag = True
        #     dx = None
        #     if item is not None and abs(item) > 100 and flag:
        #         saccadicCount += 1
        #         flag = False
        #         dx = 1 if item > 0 else -1
        #     if flag == False and dx is not None and item * dx < 0:
        #         flag = True

        print("saccardic: ", saccadicCount)
        saccadics.append(saccadicCount)
        # # データの平均と標準偏差を計算
        # diff_mean, diff_std = np.mean(diff), np.std(diff)

        # # コルモゴロフ・スミルノフ検定を実行
        # stat_diff, p_value_diff = kstest(diff, 'norm', args=(diff_mean, diff_std))

        # print(
        #     "Kolmogorov-Smirnov test for diff: statistic = {}, p-value = {}".format(
        #         stat_diff, p_value_diff
        #     )
        # )
        # 視線の散布図
        plt.scatter(x, y, label=label, s=20)
        # plt.axis("equal")
        # plt.title(label)
        # plt.xlim(-6, 6)
        # plt.ylim(-6, 6)
        # plt.savefig(f"graphs/gaze_scatter_plot_{subject}_{label}.png")
        # # 差のヒストグラム
        # plt.hist(diff, bins=20)

        # # controlDegreeのグラフ
        # plt.figure()
        # plt.plot(degree)
        # plt.xlabel("Index")
        # plt.ylabel("Gaze Degree")
        # plt.ylim(0, 400)
    # plt.show()

    plt.gca().set_aspect("equal", adjustable="box")
    plt.title("Combined Gaze Scatter Plot")
    plt.xlabel("X-axis")
    plt.ylabel("Y-axis")
    plt.legend()
    plt.xlim(-6, 6)
    plt.ylim(-6, 6)
    plt.savefig(f"graphs/combined_gaze_scatter_plot_{subject}.png")

    # CSVに出力するためのデータフレームを作成
    # ディレクトリが存在しない場合のみ作成
    if not os.path.exists("./processedData/" + subject):
        os.makedirs("./processedData/" + subject)

    shutil.copy(
        "./data/" + subject + "/meta.json", "./processedData/" + subject + "/meta.json"
    )

    pd.DataFrame(
        {
            "GazeDistribution_x": [x["GazeDistribution_x"] for x in control],
            "GazeDistribution_y": [x["GazeDistribution_y"] for x in control],
            "Distancefromfixation": [x["Distancefromfixation"] for x in control],
            "GazeMovement": [x["GazeDegree"] for x in control],
        }
    ).to_csv("./processedData/" + subject + "/controlGazeData.csv", index=False)
    pd.DataFrame(
        {
            "GazeDistribution_x": [x["GazeDistribution_x"] for x in near],
            "GazeDistribution_y": [x["GazeDistribution_y"] for x in near],
            "Distancefromfixation": [x["Distancefromfixation"] for x in near],
            "GazeMovement": [x["GazeDegree"] for x in near],
        }
    ).to_csv("./processedData/" + subject + "/nearGazeData.csv", index=False)
    pd.DataFrame(
        {
            "GazeDistribution_x": [x["GazeDistribution_x"] for x in far],
            "GazeDistribution_y": [x["GazeDistribution_y"] for x in far],
            "Distancefromfixation": [x["Distancefromfixation"] for x in far],
            "GazeMovement": [x["GazeDegree"] for x in far],
        }
    ).to_csv("./processedData/" + subject + "/farGazeData.csv", index=False)

    saccadicsJson = {
        "control": saccadics[0],
        "near": saccadics[1],
        "far": saccadics[2],
    }

    with open("./processedData/" + subject + "/saccadic_100.json", "w") as f:
        json.dump(saccadicsJson, f, indent=2)


def main():
    # 1被験者のデータを処理
    # subject = "testData"
    # GazeDistribution(subject)

    # 全員のデータを処理
    search_path = os.path.join(".", "data", "*subject*")
    directories = glob.glob(search_path)

    # ディレクトリ名のリストを取得
    directory_names = [os.path.basename(directory) for directory in directories]

    # print(directory_names)
    for subject in directory_names:
        GazeDistribution(subject)
        print("finish ", subject)


if __name__ == "__main__":
    main()
