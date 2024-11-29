import pandas as pd
import functions
import numpy as np
from scipy.stats import mannwhitneyu
from scipy.stats import shapiro
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import glob

subject = "./data/subject3/"
csvFiles = glob.glob(subject + "*.csv")

datas = []
for csvFile in csvFiles:
    df = pd.read_csv(csvFile)
    print(csvFile, functions.getStimulusShowTimes(df))
    # datas.append(df)
