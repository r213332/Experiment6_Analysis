import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob
import os

subject = "subject3"
csvFiles = glob.glob("./data/" + subject + "/*.csv")

AllData = []
for csvFile in csvFiles:
    df = pd.read_csv(csvFile)
    AllData.append(df)
near = []
far = []

for data in AllData:
    nearData = data.query("mode == 1")
    farData = data.query("mode == 2")

    near += functions.getQuestionRT(nearData)
    far += functions.getQuestionRT(farData)

# CSVに出力するためのデータフレームを作成
# ディレクトリが存在しない場合のみ作成
if not os.path.exists("./processedData/" + subject):
    os.makedirs("./processedData/" + subject)
pd.DataFrame(
    {
        "QuestionRT": [x["RT"] for x in near],
    }
).to_csv("./processedData/" + subject + "/nearQuestionRT.csv", index=False)
pd.DataFrame(
    {
        "QuestionRT": [x["RT"] for x in far],
    }
).to_csv("./processedData/" + subject + "/farQuestionRT.csv", index=False)

validateNearRT = [x["RT"] for x in near if x["RT"] is not None]
validateFarRT = [x["RT"] for x in far if x["RT"] is not None]

N_w, N_p = shapiro(validateNearRT)
F_w, F_p = shapiro(validateFarRT)

print("正規性(近傍):p=", N_p)
print("正規性(遠方):p=", F_p)

# plt.hist(validateNearRT, bins=20, alpha=0.5, label='Near')

NF_wil_all, NF_p_all = mannwhitneyu(validateNearRT, validateFarRT, method="exact")

labels = ["Near", "Far"]
x = np.arange(len(labels))
# 全データ
medians = [np.median(validateNearRT), np.median(validateFarRT)]
iqrs = [
    np.subtract(*np.percentile(validateNearRT, [75, 25])),
    np.subtract(*np.percentile(validateFarRT, [75, 25])),
]
plt.bar(x, medians, yerr=iqrs, tick_label=labels, capsize=10)

plt.show()

print("近傍と遠方のRTの差(全体):p=", NF_p_all)
