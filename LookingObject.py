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


def LookingObject(subject: str):
    csvFiles = glob.glob("./data/" + subject + "/*.csv")

    AllData = []
    for csvFile in csvFiles:
        df = pd.read_csv(csvFile)
        AllData.append(df)

    print(len(AllData))
    controlLO = {}
    nearLO = {}
    farLO = {}

    for data in AllData:
        controlData = data.query("mode == 0")
        nearData = data.query("mode == 1")
        farData = data.query("mode == 2")

        control = functions.getLookingObjectCount(controlData)
        near = functions.getLookingObjectCount(nearData)
        far = functions.getLookingObjectCount(farData)

        for key, value in control.items():
            if key in controlLO:
                controlLO[key] += value
            else:
                controlLO[key] = value

        for key, value in near.items():
            if key in nearLO:
                nearLO[key] += value
            else:
                nearLO[key] = value

        for key, value in far.items():
            if key in farLO:
                farLO[key] += value
            else:
                farLO[key] = value

    # CSVに出力するためのデータフレームを作成
    # ディレクトリが存在しない場合のみ作成
    if not os.path.exists("./processedData/" + subject):
        os.makedirs("./processedData/" + subject)

    shutil.copy(
        "./data/" + subject + "/meta.json", "./processedData/" + subject + "/meta.json"
    )

    Json = {
        "control": controlLO,
        "near": nearLO,
        "far": farLO,
    }

    with open("./processedData/" + subject + "/LookingObject.json", "w") as f:
        json.dump(Json, f, indent=2)


def main():
    # 1被験者のデータを処理
    # subject = "testData"
    # LookingObject(subject)

    # 全員のデータを処理
    search_path = os.path.join(".", "data", "*subject*")
    directories = glob.glob(search_path)

    # ディレクトリ名のリストを取得
    directory_names = [os.path.basename(directory) for directory in directories]

    # print(directory_names)
    for subject in directory_names:
        LookingObject(subject)
        print("finish ", subject)


if __name__ == "__main__":
    main()
