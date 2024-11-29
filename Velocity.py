import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os
import shutil


def Velocity(subject: str):
    # データの読み込み
    csvFiles = glob.glob("./data/" + subject + "/*.csv")

    AllData = []
    for csvFile in csvFiles:
        df = pd.read_csv(csvFile)
        AllData.append(df)

    control = []
    near = []
    far = []

    for data in AllData:
        [controlData, nearData, farData] = functions.getVelocity(data)
        control += controlData
        near += nearData
        far += farData

    # CSVに出力するためのデータフレームを作成
    # ディレクトリが存在しない場合のみ作成
    if not os.path.exists("./processedData/" + subject):
        os.makedirs("./processedData/" + subject)

    shutil.copy(
        "./data/" + subject + "/meta.json", "./processedData/" + subject + "/meta.json"
    )
    pd.DataFrame(
        {
            "Velocity": control,
        }
    ).to_csv("./processedData/" + subject + "/controlVelocity.csv", index=False)
    pd.DataFrame(
        {
            "Velocity": near,
        }
    ).to_csv("./processedData/" + subject + "/nearVelocity.csv", index=False)
    pd.DataFrame(
        {
            "Velocity": far,
        }
    ).to_csv("./processedData/" + subject + "/farVelocity.csv", index=False)

    # 正規性の検定
    # Shapiro-Wilk検定
    C_w, C_p = shapiro(control)
    N_w, N_p = shapiro(near)
    F_w, F_p = shapiro(far)

    print("正規性(対照):p=", C_p)
    print("正規性(近傍):p=", N_p)
    print("正規性(遠方):p=", F_p)

    #  Wilcoxonの順位和検定
    CN_wil_all, CN_p_all = mannwhitneyu(control, near, method="exact")
    CF_wil_all, CF_p_all = mannwhitneyu(control, far, method="exact")
    NF_wil_all, NF_p_all = mannwhitneyu(near, far, method="exact")

    print("対照:近接", CN_p_all)
    print("対照:遠方", CF_p_all)
    print("近接:遠方", NF_p_all)


# 1被験者のデータを処理
# subject = "subjectD"
# Velocity(subject)

# 全員のデータを処理
search_path = os.path.join(".", "data", "*subject*")
directories = glob.glob(search_path)

# ディレクトリ名のリストを取得
directory_names = [os.path.basename(directory) for directory in directories]

# print(directory_names)
for subject in directory_names:
    Velocity(subject)
    print("finish ", subject)
