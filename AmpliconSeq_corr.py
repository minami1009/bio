# 菌叢解析の生データから増減の相関を判定して散布図を出力する
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import math
from sklearn.metrics import r2_score


def input_data(input_csv_compared, input_csv_comparing, compared_bacteria, dropping_bacteria, minimum_number):
    # もとのcsvからday-3とday-1を除いたデータ（手作業でつくった）
    input_data1 = pd.read_csv(input_csv_compared, index_col=0)
    input_data2 = pd.read_csv(input_csv_comparing, index_col=0)

    # 比較される細菌の列と、対象の他の列に分ける
    compared = input_data1[compared_bacteria]
    comparing = input_data2.drop([dropping_bacteria], axis=1)

    # 発現量の絶対値がminimum_number以下のものはnanに置換（10くらいが無難か？）
    comparing = comparing.where(comparing > minimum_number)

    return compared, comparing


def calculate_corr(compared, comparing):
    # 相関係数を出す
    corr = comparing.corrwith(compared)
    corr_df = pd.DataFrame(corr)
    print(corr_df)

    # 相関係数が0.5以上か-0.5以下のものだけ抽出する
    corr2 = corr_df[abs(round(corr_df[0])) == 1]
    print(corr2)
    corr2_bacteria = corr2.index.values

    # nanが全体の半分以下のものだけ抽出する
    corr3_bacteria = []
    for i in corr2_bacteria:
        if comparing[i].isnull().sum() * 2 < len(comparing[i]):
            corr3_bacteria.append(i)
    print(corr3_bacteria)

    return corr2, corr3_bacteria


def plot(corr2, corr3_bacteria, compared_bacteria):
    # 描画サイズ
    plt.figure(figsize=(5, 5))

    # それぞれの菌について散布図を作成
    n = 1
    if len(corr3_bacteria) < 5:
        a = 1
        b = len(corr3_bacteria)
    else:
        a = math.ceil(len(corr3_bacteria) / 4)
        b = 4

    for i in corr3_bacteria:
        # 散布図の数値を整理(nanの削除)
        df = pd.concat([compared, comparing[i]], axis=1)
        print(df)
        df2 = df.dropna(how='any')

        # 描画テーブルを分割し散布図を作成
        plt.subplot(a, b, n)
        plt.plot(df2['Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacterales;Enterobacteriaceae;Escherichia;__'],
                 df2[i], 'o')

        # 近似直線の作成と描画
        ab1 = np.polyfit(
            df2['Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacterales;Enterobacteriaceae;Escherichia;__'],
            df2[i],
            1)
        y1 = np.poly1d(ab1)(
            df2['Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacterales;Enterobacteriaceae;Escherichia;__'])
        plt.plot(df2['Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacterales;Enterobacteriaceae;Escherichia;__'],
                 y1)

        # タイトルに相関係数
        title = 'cor_rate = %f' % corr2.at[i, 0]
        plt.title(title)

        # x軸、y軸に菌株名
        plt.xlabel(compared_bacteria)
        plt.ylabel(i.split(';')[-1])

        # 決定係数の記入（めっちゃ低いのでとりあえずオフ）
        # r2 = r2_score(df2[i],y1)
        # print(r2)
        # plt.text(0,0,r2)

        n = n + 1

    plt.show()


if __name__ == '__main__':
    # 比較元にしたい菌の列名（input_csv_comparedにその列名がある）
    compared_bacteria_column = 'Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacterales;Enterobacteriaceae;Escherichia;__'

    # 比較元にしたい菌の、比較対象にしたいデータにおける列名（input_csv_comparingにその列名がある。input_csv_comparedとcomparingが同じ場合は上と同じで良い）
    dropping_bacteria_column = 'Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacterales;Enterobacteriaceae;Escherichia'

    # 比較元にしたい発現データが含まれるファイルをcomparedに、比較対象にしたいデータをcomparingにそれぞれinputする。minimum_numberは発現量の下限値。
    compared, comparing = input_data(input_csv_compared='level-8.csv', input_csv_comparing='level-6.csv',
                                     compared_bacteria=compared_bacteria_column,
                                     dropping_bacteria=dropping_bacteria_column, minimum_number=10)

    corr2, corr3_bacteria = calculate_corr(compared, comparing)

    # 比較元にした菌名を横軸に入れる（ここではEscherichia）
    plot(corr2, corr3_bacteria, compared_bacteria="Escherichia")
