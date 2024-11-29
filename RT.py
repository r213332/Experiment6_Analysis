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


def RT(subject: str):
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

        control += functions.getRT(controlData)
        near += functions.getRT(nearData)
        far += functions.getRT(farData)

    print("Control:", len(control))
    print("Near:", len(near))
    print("Far:", len(far))
    print("ControlMiss:", len([x for x in control if x["RT"] is None]))
    print("NearMiss:", len([x for x in near if x["RT"] is None]))
    print("FarMiss:", len([x for x in far if x["RT"] is None]))

    # CSVに出力するためのデータフレームを作成
    # ディレクトリが存在しない場合のみ作成
    if not os.path.exists("./processedData/" + subject):
        os.makedirs("./processedData/" + subject)

    shutil.copy("./data/" + subject + "/meta.json","./processedData/" + subject + "/meta.json")

    pd.DataFrame(
        {
            "RT": [x["RT"] for x in control],
            "MeanVelocity": [x["MeanVelocity"] for x in control],
            "HDegree": [x["HDegree"] for x in control],
            "VDegree": [x["VDegree"] for x in control],
        }
    ).to_csv("./processedData/" + subject + "/controlRT.csv", index=False)
    pd.DataFrame(
        {
            "RT": [x["RT"] for x in near],
            "MeanVelocity": [x["MeanVelocity"] for x in near],
            "HDegree": [x["HDegree"] for x in near],
            "VDegree": [x["VDegree"] for x in near],
        }
    ).to_csv("./processedData/" + subject + "/nearRT.csv", index=False)
    pd.DataFrame(
        {
            "RT": [x["RT"] for x in far],
            "MeanVelocity": [x["MeanVelocity"] for x in far],
            "HDegree": [x["HDegree"] for x in far],
            "VDegree": [x["VDegree"] for x in far],
        }
    ).to_csv("./processedData/" + subject + "/farRT.csv", index=False)

    # # 　全データで検定
    # control_RT_all = [x["RT"] for x in control if x["RT"] is not None]
    # near_RT_all = [x["RT"] for x in near if x["RT"] is not None]
    # far_RT_all = [x["RT"] for x in far if x["RT"] is not None]

    # # 正規性の検定
    # # Shapiro-Wilk検定
    # C_w, C_p = shapiro(control_RT_all)
    # N_w, N_p = shapiro(near_RT_all)
    # F_w, F_p = shapiro(far_RT_all)

    # print("正規性(対照):p=", C_p)
    # print("正規性(近傍):p=", N_p)
    # print("正規性(遠方):p=", F_p)

    # #  Wilcoxonの順位和検定
    # CN_wil_all, CN_p_all = mannwhitneyu(control_RT_all, near_RT_all, method="exact")
    # CF_wil_all, CF_p_all = mannwhitneyu(control_RT_all, far_RT_all, method="exact")
    # NF_wil_all, NF_p_all = mannwhitneyu(near_RT_all, far_RT_all, method="exact")

    # print("対照:近接", CN_p_all)
    # print("対照:遠方", CF_p_all)
    # print("近接:遠方", NF_p_all)

    # # 水平角度が半分以上のみで検定
    # control_RT_half = [
    #     x["RT"] for x in control if x["RT"] is not None and x["HDegree"] > 29
    # ]
    # near_RT_half = [x["RT"] for x in near if x["RT"] is not None and x["HDegree"] > 29]
    # far_RT_half = [x["RT"] for x in far if x["RT"] is not None and x["HDegree"] > 29]

    # # 正規性の検定
    # # Shapiro-Wilk検定
    # C_w, C_p = shapiro(control_RT_half)
    # N_w, N_p = shapiro(near_RT_half)
    # F_w, F_p = shapiro(far_RT_half)

    # print("正規性(対照):p=", C_p)
    # print("正規性(近傍):p=", N_p)
    # print("正規性(遠方):p=", F_p)

    # #  Wilcoxonの順位和検定
    # CN_wil_half, CN_p_half = mannwhitneyu(control_RT_half, near_RT_half, method="exact")
    # CF_wil_half, CF_p_half = mannwhitneyu(control_RT_half, far_RT_half, method="exact")
    # NF_wil_half, NF_p_half = mannwhitneyu(near_RT_half, far_RT_half, method="exact")

    # print("(harf > 29)対照:近接", CN_p_half)
    # print("(harf > 29)対照:遠方", CF_p_half)
    # print("(harf > 29)近接:遠方", NF_p_half)

    # # 水平角度が半分未満のみも用意
    # control_RT_s_half = [
    #     x["RT"] for x in control if x["RT"] is not None and x["HDegree"] <= 29
    # ]
    # near_RT_s_half = [
    #     x["RT"] for x in near if x["RT"] is not None and x["HDegree"] <= 29
    # ]
    # far_RT_s_half = [x["RT"] for x in far if x["RT"] is not None and x["HDegree"] <= 29]

    # # 正規性の検定
    # # Shapiro-Wilk検定
    # C_w, C_p = shapiro(control_RT_s_half)
    # N_w, N_p = shapiro(near_RT_s_half)
    # F_w, F_p = shapiro(far_RT_s_half)

    # print("正規性(対照):p=", C_p)
    # print("正規性(近傍):p=", N_p)
    # print("正規性(遠方):p=", F_p)

    # #  Wilcoxonの順位和検定
    # CN_wil_half, CN_p_half = mannwhitneyu(
    #     control_RT_s_half, near_RT_s_half, method="exact"
    # )
    # CF_wil_half, CF_p_half = mannwhitneyu(
    #     control_RT_s_half, far_RT_s_half, method="exact"
    # )
    # NF_wil_half, NF_p_half = mannwhitneyu(near_RT_s_half, far_RT_s_half, method="exact")

    # print("(harf < 29)対照:近接", CN_p_half)
    # print("(harf < 29)対照:遠方", CF_p_half)
    # print("(harf < 29)近接:遠方", NF_p_half)

    # # グラフ描画
    # fig, axs = plt.subplots(2, 3)
    # labels = ["Control", "Near", "Far"]
    # x = np.arange(len(labels))
    # # 全データ
    # medians = [np.median(control_RT_all), np.median(near_RT_all), np.median(far_RT_all)]
    # iqrs = [
    #     np.subtract(*np.percentile(control_RT_all, [75, 25])),
    #     np.subtract(*np.percentile(near_RT_all, [75, 25])),
    #     np.subtract(*np.percentile(far_RT_all, [75, 25])),
    # ]
    # axs[0][0].bar(x, medians, yerr=iqrs, tick_label=labels, capsize=10)
    # axs[0][0].set_title("AllData")
    # axs[0][0].set_ylim(0, 1.5)

    # # 半データ
    # medians = [
    #     np.median(control_RT_half),
    #     np.median(near_RT_half),
    #     np.median(far_RT_half),
    # ]
    # iqrs = [
    #     np.subtract(*np.percentile(control_RT_half, [75, 25])),
    #     np.subtract(*np.percentile(near_RT_half, [75, 25])),
    #     np.subtract(*np.percentile(far_RT_half, [75, 25])),
    # ]
    # axs[0][1].bar(x, medians, yerr=iqrs, tick_label=labels, capsize=10)
    # axs[0][1].set_title("HorizontalAngle>=30")
    # axs[0][1].set_ylim(0, 1.5)

    # # 半未満データ
    # medians = [
    #     np.median(control_RT_s_half),
    #     np.median(near_RT_s_half),
    #     np.median(far_RT_s_half),
    # ]
    # iqrs = [
    #     np.subtract(*np.percentile(control_RT_s_half, [75, 25])),
    #     np.subtract(*np.percentile(near_RT_s_half, [75, 25])),
    #     np.subtract(*np.percentile(far_RT_s_half, [75, 25])),
    # ]
    # axs[0][2].bar(x, medians, yerr=iqrs, tick_label=labels, capsize=10)
    # axs[0][2].set_title("HorizontalAngle<30")
    # axs[0][2].set_ylim(0, 1.5)

    # # ヒストグラム
    # axs[1][0].hist(control_RT_all, bins=10)
    # axs[1][0].set_title("Control")

    # axs[1][1].hist(near_RT_all, bins=10)
    # axs[1][1].set_title("Near")

    # axs[1][2].hist(far_RT_all, bins=10)
    # axs[1][2].set_title("Far")

    # plt.show()


# 1被験者のデータを処理
# subject = "subjectL"
# RT(subject)

# 全員のデータを処理
search_path = os.path.join(".", "data", "*subject*")
directories = glob.glob(search_path)

# ディレクトリ名のリストを取得
directory_names = [os.path.basename(directory) for directory in directories]

# print(directory_names)
for subject in directory_names:
    RT(subject)
    print("finish ", subject)
