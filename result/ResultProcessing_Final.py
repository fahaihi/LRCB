# 用于算法处理数据集, 这里我们增强了表述，对于压缩失败的文件不计入计算
import pandas as pd
import numpy as np
import math
import os
import subprocess
FinalDir = "./Final/"
savedData = []
from sklearn.preprocessing import MinMaxScaler
import seaborn as sns
import matplotlib.pyplot as plt


def Func(algo):
    alg = algo
    dataPath = "/public/home/jd_sunhui/genCompressor/LRCB/result/" + alg + "/" + alg + "_16.csv"
    F_NAME = "/public/home/jd_sunhui/genCompressor/LRCB/script/F_Name_Final.txt"
    fileNameList = []
    Source_List = []
    fileSizeList = []

    with open(F_NAME) as data:
        file = data.readline()

        while file:
            # print(file)
            Source_List.append(file)
            file = data.readline()

    #print(len(Source_List))
    index = 0
    for f in Source_List:
        index = index + 1
        f = f.replace('\n', '')
        filename = os.path.basename(f)
        # print(filename)
        # fileNameList.append(filename)
        fileNameList.append("D" + str(index))
        # print(f)
        command = f"ls -lah --block-size=1 {f}.reads | awk '/^[-d]/ {{print $5}}'"
        output = subprocess.check_output(["bash", "-c", command])
        output = int(output.decode("utf-8"))  # 将字节字符串解码为Unicode字符串 # 文件规模单位为B
        # print(output)
        # print(type(output))
        fileSizeList.append(output)
        #print(filename, ": ", output / 1024 / 1024 / 1024, "GB")

    sumFileSize = sum(fileSizeList)
    weightList = [fileSizeList[i] / sumFileSize for i in range(len(fileSizeList))]
    #print(weightList)

    data = pd.read_csv("./" + alg + "/" + alg + "_16.csv")

    data = data.iloc[0:data.shape[0], 1:7]
    data = data.drop(8)
    #print(data.shape)

    saveCalcuList = []
    cs_list = []
    cr_list = []
    ct_list = []
    cpm_list = []
    dt_list = []
    dpm_list = []
    #savedData.append(["DataSets", "CS", "CR", "CT", "CPM", "DT", "DCM"])
    #savedData.append(["", " (Gigabytes)", "(bits/base)", "(Hours)", " (Gigabytes)", "(Hours)", "(Gigabytes)"])
    for i in range(len(fileNameList)):
        name = fileNameList[i]
        cs = round(float(data.iloc[i, 0] / 1024 / 1024 / 1024), 3)  # in GB
        cs_list.append(cs)
        cr = round(float(data.iloc[i, 1]), 3)
        cr_list.append(cr)
        ct = round(float(data.iloc[i, 2] / 3600), 3)  # h
        ct_list.append(ct)
        cpm = round(float(data.iloc[i, 3] / 1024 / 1024), 3)  # GB
        cpm_list.append(cpm)
        dt = round(float(data.iloc[i, 4] / 3600), 3)  # h
        dt_list.append(dt)
        dpm = round(float(data.iloc[i, 5] / 1024 / 1024), 3)  # GB
        dpm_list.append(dpm)
        #print(name, "-->", cs, "-->", cr, "-->", ct, "-->", cpm, "-->", dt, "-->", dpm)
        #savedData.append([name, cs, cr, ct, cpm, dt, dpm])

    #print("len(ct_list)", len(ct_list))
    AvgCFsize = round(float(sum(cs_list) / len(cs_list)), 3)
    AvgCR = round(float(sum(cr_list) / len(cr_list)), 3)
    TotalCT = round(float(sum(ct_list)), 3)
    TotalDT = round(float(sum(dt_list)), 3)
    MaxCPM = round(float(max(cpm_list)), 3)
    MaxDPM = round(float(max(dpm_list)), 3)
    WAvgCR = 0
    CV = 0
    for i in range(len(cr_list)):
        WAvgCR = WAvgCR + cr_list[i] * weightList[i]
        CV = CV + pow(cr_list[i] - AvgCR, 2)
    CV = round(100 * float(math.sqrt(CV) / len(cr_list)), 3)
    WAvgCR = round(float(WAvgCR), 3)
    #print("1: WAvgCR  : ", WAvgCR)
    #print("2: AvgCR   : ", AvgCR)
    #print("3: TotalCT :", TotalCT)
    #print("4: MaxCPM  :", MaxCPM)
    #print("5: TotalDT :", TotalDT)
    #print("6: MaxDPM  :", MaxDPM)
    #print("7: CV      : ", CV)

    savedData.append([alg, WAvgCR, AvgCR, TotalCT, MaxCPM, TotalDT, MaxDPM, CV])
    print(alg, WAvgCR, AvgCR, TotalCT, MaxCPM, TotalDT, MaxDPM, CV)

    #print(savedData)
    #data = pd.DataFrame(savedData)
    #print(data)
    #data.to_csv(alg + "_Final_16.csv")

for algo in ["geco3", "bsc",
             "lzop", "zstd", "brotli", "genozip", "xz", "snzip",
             "geco", "geco2", "colord", "nanospring", "spring", "fastqcls",
             "naf", "enano", "pbzip2", "lzma2", "7zip", "ppmd",
             "pigz", "lz4", "lizard", "brieflz", "zpaq", "mfcompress"]:
    Func(algo)

print("--------------------------------------------------------------")
data = pd.DataFrame(savedData)
data = data.sort_values([1, 2, 3, 4])
data.columns = ["Algorithm", "WAvgCR", "AvgCR", "TotalCT", "MaxCPM", "TotalDT", "MaxDPM", "CV"]
#matr = pd.Series([" ", "(bits/base)", "(bits/base)", "(Hours)", "(Gigabytes)", "(Hours)", "(Gigabytes)", "%"], index=data.columns)
#data = pd.concat([pd.DataFrame(matr).T, matr]).reset_index(drop=True)
print(data)
data.to_csv("Fina.csv")
exit(0)
print("-------------------------------------------------------------")
print("归一化绘制热图")
data_copy = data
scaler = MinMaxScaler()
df_normalized = pd.DataFrame(scaler.fit_transform(data_copy.iloc[:, 1:]))
print(df_normalized)
#plt.gca().xaxis.tick_top()
#plt.xticks(range(len(data.columns) - 1), data.columns[1:], rotation=0)
#plt.gca().xaxis.tick_top()
plt.yticks(range(len(data)), data.iloc[:, 0], rotation=0)
print(data.iloc[:, 0])
# 创建 DataFrame

# 绘制热力图
plt.figure() # figsize=(10, 8)
sns.heatmap(df_normalized, annot=data.iloc[:, 1:], cmap=sns.diverging_palette(10, 220, sep=80, n=7), fmt='.3f', linewidths=0.5)
#plt.ylabel('Metrics')

#plt.xlabel('Algorithm')
#plt.title('Normalized Heatmap')
plt.savefig("res.png")
plt.show()

