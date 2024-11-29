import swtest.*;

clear;

directory = "./processedData/";
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外

% グラフ保存用
graphDir = './graphs';
mkdir(graphDir);


controlTable = table();
nearTable = table();
farTable = table();

for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    % ファイルの存在をチェック
    if exist(fullfile(directory, subdirName, "controlGazeRT.csv"), 'file') ~= 2
        continue;
    end
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlGazeRT.csv"));
    near = readtable(fullfile(directory, subdirName, "nearGazeRT.csv"));
    far = readtable(fullfile(directory, subdirName, "farGazeRT.csv"));
    
    % 連結
    controlTable = vertcat(controlTable, control);
    nearTable = vertcat(nearTable, near);
    farTable = vertcat(farTable, far);
end

% サッケードが起きなかったデータを抽出
missingControlRTRows = controlTable(ismissing(controlTable.GazeRT), :);
missingNearRTRows = nearTable(ismissing(nearTable.GazeRT), :);
missingFarRTRows = farTable(ismissing(farTable.GazeRT), :);

% サッケードが起きたデータを抽出
controlTable = rmmissing(controlTable,"DataVariables","GazeRT");
nearTable = rmmissing(nearTable,"DataVariables","GazeRT");
farTable = rmmissing(farTable,"DataVariables","GazeRT");

% RT用に欠損値を除外
verifiedControlTable = rmmissing(controlTable,"DataVariables","RT");
verifiedNearTable = rmmissing(nearTable,"DataVariables","RT");
verifiedFarTable = rmmissing(farTable,"DataVariables","RT");
verifiedMissingControlRTRows = rmmissing(missingControlRTRows,"DataVariables","RT");
verifiedMissingNearRTRows = rmmissing(missingNearRTRows,"DataVariables","RT");
verifiedMissingFarRTRows = rmmissing(missingFarRTRows,"DataVariables","RT");
medians = [median(verifiedControlTable.RT), median(verifiedMissingControlRTRows.RT); ...
    median(verifiedNearTable.RT), median(verifiedMissingNearRTRows.RT); ...
    median(verifiedFarTable.RT), median(verifiedMissingFarRTRows.RT)];
figure;
b = bar(medians);
hold on;

% 四分位範囲の描画
[ngroups,nbars] = size(medians);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorMin = [median(verifiedControlTable.RT) - quantile(verifiedControlTable.RT, 0.25), ...
    median(verifiedMissingControlRTRows.RT) - quantile(verifiedMissingControlRTRows.RT, 0.25); ...
    median(verifiedNearTable.RT) - quantile(verifiedNearTable.RT, 0.25), ...
    median(verifiedMissingNearRTRows.RT) - quantile(verifiedMissingNearRTRows.RT, 0.25); ...
    median(verifiedFarTable.RT) - quantile(verifiedFarTable.RT, 0.25), ...
    median(verifiedMissingFarRTRows.RT) - quantile(verifiedMissingFarRTRows.RT, 0.25)];
errorMax =[quantile(verifiedControlTable.RT, 0.75) - median(verifiedControlTable.RT), ...
    quantile(verifiedMissingControlRTRows.RT, 0.75) - median(verifiedMissingControlRTRows.RT); ...
    quantile(verifiedNearTable.RT, 0.75) - median(verifiedNearTable.RT), ...
    quantile(verifiedMissingNearRTRows.RT, 0.75) - median(verifiedMissingNearRTRows.RT); ...
    quantile(verifiedFarTable.RT, 0.75) - median(verifiedFarTable.RT), ...
    quantile(verifiedMissingFarRTRows.RT, 0.75) - median(verifiedMissingFarRTRows.RT)];
errorbar(x.',medians, errorMin,errorMax, 'k', 'linestyle', 'none');

% 検定結果の表示
step = 0.3;
ytips = max([b(1).YEndPoints;b(2).YEndPoints]) + step;
% RT
[p,h] = ranksum(verifiedControlTable.RT, verifiedMissingControlRTRows.RT);
if h == 1
    disp("対照条件においてRTのサッカードの有無による切り分けでは、2群は有意に異なる");
    label = "*";
    if(p < 0.01)
        label = "**";
    end
    xStart = b(1).XEndPoints(1);
    xEnd = b(2).XEndPoints(1);
    line([xStart, xEnd], [ytips(1); ytips(1)], 'Color', 'k');
    text((xStart + xEnd)./2, ytips(1), label,'HorizontalAlignment','center','VerticalAlignment','bottom');
end
[p,h] = ranksum(verifiedNearTable.RT, verifiedMissingNearRTRows.RT);
if h == 1
    disp("近傍条件においてRTのサッカードの有無による切り分けでは、2群は有意に異なる");
    label = "*";
    if(p < 0.01)
        label = "**";
    end
    xStart = b(1).XEndPoints(2);
    xEnd = b(2).XEndPoints(2);
    line([xStart, xEnd], [ytips(2); ytips(2)], 'Color', 'k');
    text((xStart + xEnd)./2, ytips(2), label,'HorizontalAlignment','center','VerticalAlignment','bottom');
end
[p,h] = ranksum(verifiedFarTable.RT, verifiedMissingFarRTRows.RT);
if h == 1
    disp("遠方条件においてRTのサッカードの有無による切り分けでは、2群は有意に異なる");
    label = "*";
    if(p < 0.01)
        label = "**";
    end
    xStart = b(1).XEndPoints(3);
    xEnd = b(2).XEndPoints(3);
    line([xStart, xEnd], [ytips(3); ytips(3)], 'Color', 'k');
    text((xStart + xEnd)./2, ytips(3), label,'HorizontalAlignment','center','VerticalAlignment','bottom');
end

title('サッカードの有無によるRTの比較');
ylim([0,1.0]);
ylabel('RT[s]');
xticklabels({'対照','近傍','遠方'});
fontsize(gcf,24,'points')
legend('サッカードあり','サッカードなし');

% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'PDTRT_GazeRT_test.png'));

% % 初期差
% [p,h] = ranksum(controlTable.InitialGazeDistance, missingControlRTRows.InitialGazeDistance);
% if h == 1
%     disp("対照条件において初期差のサッカードの有無による切り分けでは、2群は有意に異なる");
% end
% [p,h] = ranksum(nearTable.InitialGazeDistance, missingNearRTRows.InitialGazeDistance);
% if h == 1
%     disp("近傍条件において初期差のサッカードの有無による切り分けでは、2群は有意に異なる");
% end
% [p,h] = ranksum(farTable.InitialGazeDistance, missingFarRTRows.InitialGazeDistance);
% if h == 1
%     disp("遠方条件において初期差のサッカードの有無による切り分けでは、2群は有意に異なる");
% end
% medians = [median(controlTable.InitialGazeDistance), median(missingControlRTRows.InitialGazeDistance); ...
%     median(nearTable.InitialGazeDistance), median(missingNearRTRows.InitialGazeDistance); ...
%     median(farTable.InitialGazeDistance), median(missingFarRTRows.InitialGazeDistance)];
% figure;
% bar(medians);
% xticklabels({'対照','近傍','遠方'});

% 水平方向の偏心度でサッカードなしをプロット
figure
nexttile
histogram(missingControlRTRows.StimulusHorizontalDegree, 'BinWidth', 5);
xlim([0,55]);
xlabel('水平方向の偏心度[°]');
ylabel('回数');
title('対照条件');

nexttile
histogram(missingNearRTRows.StimulusHorizontalDegree, 'BinWidth', 5);
xlim([0,55]);
xlabel('水平方向の偏心度[°]');
ylabel('回数');
title('近傍条件');

nexttile
histogram(missingFarRTRows.StimulusHorizontalDegree, 'BinWidth', 5);
xlim([0,55]);
xlabel('水平方向の偏心度[°]');
ylabel('回数');
title('遠方条件');

% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'StimulusHorizontalDegree~GazeRT_MissingGraph.png'));

% 初期の距離でサッカードなしをプロット
% figure
% nexttile
% histogram(missingControlRTRows.InitialGazeDistance, 'BinWidth', 10);
% xlim([0,80]);
% xlabel('刺激提示時の角度差[°]');
% ylabel('回数');
% title('対照条件');

% nexttile
% histogram(missingNearRTRows.InitialGazeDistance, 'BinWidth', 10);
% xlim([0,80]);
% xlabel('刺激提示時の角度差[°]');
% ylabel('回数');
% title('近傍条件');

% nexttile
% histogram(missingFarRTRows.InitialGazeDistance, 'BinWidth', 10);
% xlim([0,80]);
% xlabel('刺激提示時の角度差[°]');
% ylabel('回数');
% title('遠方条件');

% % グラフ保存
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
% saveas(gcf, fullfile(graphDir, 'InitialGazeDistance~GazeRT_MissingGraph.png'));

% RTでサッカードなしをプロット
figure
nexttile
histogram(missingControlRTRows.RT, 'BinWidth', 0.2);
xlim([0,2.0]);
xlabel('RT[s]');
ylabel('回数');
title('対照条件');

nexttile
histogram(missingNearRTRows.RT, 'BinWidth', 0.2);
xlim([0,2.0]);
xlabel('RT[s]');
ylabel('回数');
title('近傍条件');

nexttile
histogram(missingFarRTRows.RT, 'BinWidth', 0.2);
xlim([0,2.0]);
xlabel('RT[s]');
ylabel('回数');
title('遠方条件');


% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'RT~GazeRT_MissingGraph.png'));