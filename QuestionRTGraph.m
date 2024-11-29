directory = "./processedData/";

% Subject 1
subject1 = struct();
subject1.near = readtable(strcat(directory, "subject1/nearRT.csv"));
subject1.far = readtable(strcat(directory, "subject1/farRT.csv"));


% Subject 2
subject2 = struct();
subject2.near = readtable(strcat(directory, "subject2/nearRT.csv"));
subject2.far = readtable(strcat(directory, "subject2/farRT.csv"));

% Subject 3
subject3 = struct();
subject3.near = readtable(strcat(directory, "subject3/nearRT.csv"));
subject3.far = readtable(strcat(directory, "subject3/farRT.csv"));

% Subject 4
subject4 = struct();
subject4.near = readtable(strcat(directory, "subject4/nearRT.csv"));
subject4.far = readtable(strcat(directory, "subject4/farRT.csv"));

% RT取得＆データのバリデーション
% Subject 1
subject1.near = rmmissing(subject1.near{:, 1});
subject1.far = rmmissing(subject1.far{:, 1});

% Subject 2
subject2.near = rmmissing(subject2.near{:, 1});
subject2.far = rmmissing(subject2.far{:, 1});

% Subject 3
subject3.near = rmmissing(subject3.near{:, 1});
subject3.far = rmmissing(subject3.far{:, 1});

% Subject 4
subject4.near = rmmissing(subject4.near{:, 1});
subject4.far = rmmissing(subject4.far{:, 1});

% 全てのデータを連結
all_near = [subject1.near; subject2.near; subject3.near; subject4.near];
all_far = [subject1.far; subject2.far; subject3.far; subject4.far];

% ウィルコクソンの順位和検定
[subject1_p,subject1_h] = ranksum(subject1.near, subject1.far, 'alpha', 0.05);
[subject2_p,subject2_h] = ranksum(subject2.near, subject2.far, 'alpha', 0.05);
[subject3_p,subject3_h] = ranksum(subject3.near, subject3.far, 'alpha', 0.05);
[subject4_p,subject4_h] = ranksum(subject4.near, subject4.far, 'alpha', 0.05);
[all_p,all_h] = ranksum(all_near, all_far, 'alpha', 0.05);


% 各データを棒グラフで中央値を表示
Median = [median(subject1.near), median(subject1.far);
          median(subject2.near), median(subject2.far);
          median(subject3.near), median(subject3.far);
          median(subject4.near), median(subject4.far);
          median(all_near), median(all_far)];

% 棒グラフの描画
figure;
b = bar(Median);
near_x = b(1).XEndPoints;
far_x = b(2).XEndPoints;
xtips = (near_x + far_x) ./ 2;
near_y = b(1).YEndPoints;
far_y = b(2).YEndPoints;
ytips = max([near_y; far_y]) + 0.5;
labels = [strcat("p=",string(subject1_p)), strcat("p=",string(subject2_p)), strcat("p=",string(subject3_p)), strcat("p=",string(subject4_p)), strcat("p=",string(all_p))];
text(xtips, ytips, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');
% グラフの大きさ
% AxesHandle=findobj(gcf,'Type','axes');
% pt1 = get(AxesHandle,{'Position'});
% graphProp = cell2mat(pt1);
% x = 4.9;
% y = graphProp(4)-graphProp(2);
% for i = 1:4
%     annotation('line',[near_x(i)/x,near_x(i)/x],[near_y(i)/y+0.02,ytips(i)/y-0.01])
%     annotation('line',[near_x(i)/x,far_x(i)/x],[ytips(i)/y-0.01,ytips(i)/y-0.01])
%     annotation('line',[far_x(i)/x,far_x(i)/x],[far_y(i)/y+0.02,ytips(i)/y-0.01])
% end

hold on;

% 各データの四分位範囲を計算
% Subject 1
subject1_near_quantiles = quantile(subject1.near, [0.25 0.75]);
subject1_far_quantiles = quantile(subject1.far, [0.25 0.75]);
% 四分位範囲の差を計算
subject1_near_iqr = subject1_near_quantiles(2) - subject1_near_quantiles(1);
subject1_far_iqr = subject1_far_quantiles(2) - subject1_far_quantiles(1);

% Subject 2
subject2_near_quantiles = quantile(subject2.near, [0.25 0.75]);
subject2_far_quantiles = quantile(subject2.far, [0.25 0.75]);
% 四分位範囲の差を計算
subject2_near_iqr = subject2_near_quantiles(2) - subject2_near_quantiles(1);
subject2_far_iqr = subject2_far_quantiles(2) - subject2_far_quantiles(1);

% Subject 3
subject3_near_quantiles = quantile(subject3.near, [0.25 0.75]);
subject3_far_quantiles = quantile(subject3.far, [0.25 0.75]);
% 四分位範囲の差を計算
subject3_near_iqr = subject3_near_quantiles(2) - subject3_near_quantiles(1);
subject3_far_iqr = subject3_far_quantiles(2) - subject3_far_quantiles(1);

% Subject 4
subject4_near_quantiles = quantile(subject4.near, [0.25 0.75]);
subject4_far_quantiles = quantile(subject4.far, [0.25 0.75]);
% 四分位範囲の差を計算
subject4_near_iqr = subject4_near_quantiles(2) - subject4_near_quantiles(1);
subject4_far_iqr = subject4_far_quantiles(2) - subject4_far_quantiles(1);

% All
all_near_quantiles = quantile(all_near, [0.25 0.75]);
all_far_quantiles = quantile(all_far, [0.25 0.75]);
% 四分位範囲の差を計算
all_near_iqr = all_near_quantiles(2) - all_near_quantiles(1);
all_far_iqr = all_far_quantiles(2) - all_far_quantiles(1);

% 各データの四分位範囲をエラーバーで表示
error = [subject1_near_iqr,subject1_far_iqr;
        subject2_near_iqr,subject2_far_iqr;
        subject3_near_iqr,subject3_far_iqr;
        subject4_near_iqr,subject4_far_iqr;
        all_near_iqr,all_far_iqr];

[ngroups,nbars] = size(Median);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x.',Median, error, 'k', 'linestyle', 'none');


fontsize(gcf,24,'points')
title("質問への回答時間（中央値）");
ylabel("反応時間[s]");
legend("近接", "遠方",'四分位範囲','');
ylim([0, 1.5]);
xticklabels({'Subject 1', 'Subject 2', 'Subject 3', 'Subject 4','All'});


