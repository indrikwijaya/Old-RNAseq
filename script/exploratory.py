import pandas as pd
import math
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(color_codes=True)


def hist_stats(logrpkm_df):
    max_val = np.amax(logrpkm_df.values)
    min_val = np.amin(logrpkm_df.values)
    max_bins = list(range(math.floor(min_val), math.ceil(max_val), 1))
    pd_index = []
    for i in max_bins[:-1]:
        pd_index.append(str(i) + ' - ' + str(i + 1))

    times = ['t0', 't1', 't2', 't3', 't4', 't5', 't6']

    hist_stats = pd.DataFrame(index=pd_index, columns=times)
    # hist_stats = hist_stats.fillna(0)
    for time in times:
        hist_count = np.histogram(logrpkm_df[time], bins=max_bins)
        hist_count_time = hist_count[0]
        hist_count_time_width = hist_count[1]
        hist_count_time_dict = {str(hist_count_time_width[i]) + ' - ' + str(hist_count_time_width[i + 1]): \
                                    hist_count_time[i] for i in range(0, len(hist_count_time))}

        hist_count_dict = {}
        for bin_width in pd_index:
            hist_count_dict[bin_width] = 0

        for bin_width in hist_count_time_dict:
            if bin_width in hist_count_dict:
                hist_count_dict[bin_width] = hist_count_time_dict[bin_width]
        hist_stats[time] = hist_stats[time].fillna(hist_count_dict)
    hist_stats = hist_stats.drop(hist_stats.index[0])
    hist_stats = hist_stats.drop(hist_stats.index[-1])
    return hist_stats


def plot_hist_count(logrpkm_df):
    logrpkm_hist = hist_stats(logrpkm_df)
    logrpkm_hist.T.plot(legend=True, figsize=(15,8))
    plt.xlabel('time', fontsize =20)
    plt.ylabel('count', fontsize =20)
    plt.xticks(fontsize =15)
    plt.yticks(fontsize=15)
    plt.title('logRPKM distribution', fontsize = 30)
    plt.legend(loc= 'center left', bbox_to_anchor = (1,0.5), fontsize =17)
    #plt.show()


def plot_dist(logrpkm_df, time, label):
    logrpkm_time = logrpkm_df[time]
    # numBins = int(max(logrpkm_time))-int(min(logrpkm_time))+1
    numBins = list(range(int(min(logrpkm_time)), int(max(logrpkm_time)), 1))
    fig = plt.figure(figsize=(15, 8))
    plt.rcParams["patch.force_edgecolor"] = True

    plt.ylabel('')
    plt.xticks(numBins, fontsize=30)
    plt.yticks(fontsize=30)
    # plt.title('logRPKM Distribution for '+time, fontsize=20)
    sns.distplot(logrpkm_time, bins=numBins, kde=False)#, hist_kws=dict(edgecolor="k", linewidth=2))
    plt.xlabel('')
    plt.savefig('hist_'+label+'_'+time+'.png')
    # plt.show()


def plot_kde(logrpkm_df, times, label):
    fig = plt.figure(figsize=(15, 8))
    plt.rcParams["patch.force_edgecolor"] = True

    plt.xlabel('')
    plt.ylabel('')
    plt.xticks(fontsize=24)
    plt.yticks(fontsize=24)
    # plt.title('KDE Comparison', fontsize=20)

    for time in times:
        sns.kdeplot(logrpkm_df[time], legend=True)
    plt.legend(fontsize=24)

    plt.savefig('kde_'+label+'.png')


    # plt.show()