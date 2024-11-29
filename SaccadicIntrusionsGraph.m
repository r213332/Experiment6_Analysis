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
    if exist(fullfile(directory, subdirName, "controlSIFrequency.csv"), 'file') ~= 2
        continue;
    end
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlSIFrequency.csv"));
    near = readtable(fullfile(directory, subdirName, "nearSIFrequency.csv"));
    far = readtable(fullfile(directory, subdirName, "farSIFrequency.csv"));
    
    % 連結
    controlTable = vertcat(controlTable, control);
    nearTable = vertcat(nearTable, near);
    farTable = vertcat(farTable, far);
end

% SIが検出できなかったデータを抽出
% missingControlRTRows = controlTable(ismissing(controlTable.SIFrequency,{0.0}), :);
% missingNearRTRows = nearTable(ismissing(nearTable.SIFrequency,{0.0}), :);
% missingFarRTRows = farTable(ismissing(farTable.SIFrequency,{0.0}), :);

% SIの頻度
controlTable = controlTable(controlTable.SIFrequency ~= 0.0, :);
nearTable = nearTable(nearTable.SIFrequency ~= 0.0, :);
farTable = farTable(farTable.SIFrequency ~= 0.0, :);

controlSIFrequency = controlTable.SIFrequency;
nearSIFrequency = nearTable.SIFrequency;
farSIFrequency = farTable.SIFrequency;

% [h,p] = swtest(controlSIFrequency)
% [h,p] = swtest(nearSIFrequency)
% [h,p] = swtest(farSIFrequency)

% figure;
% histogram(controlSIFrequency, 'Normalization', 'probability');
% title('対照条件');

% figure;
% histogram(nearSIFrequency, 'Normalization', 'probability');
% title('近傍条件');

% figure;
% histogram(farSIFrequency, 'Normalization', 'probability');
% title('遠方条件');

medians = [median(controlSIFrequency), median(nearSIFrequency), median(farSIFrequency)];

figure;
b = bar(medians);
hold on;

% 四分位範囲の描画
[ngroups,nbars] = size(medians);
% Get the x coordinate of the bars
errorMin = [median(controlSIFrequency) - quantile(controlSIFrequency, 0.25), ...
    median(nearSIFrequency) - quantile(nearSIFrequency, 0.25), ...
    median(farSIFrequency) - quantile(farSIFrequency, 0.25)];
errorMax = [quantile(controlSIFrequency, 0.75) - median(controlSIFrequency), ...
    quantile(nearSIFrequency, 0.75) - median(nearSIFrequency), ...
    quantile(farSIFrequency, 0.75) - median(farSIFrequency)];
errorbar(b.XEndPoints,medians, errorMin,errorMax, 'k', 'linestyle', 'none');

% 検定結果の表示
% 配列の次元数を揃える
% % 配列の長さを取得
len_control = length(controlSIFrequency);
len_near = length(nearSIFrequency);
len_far = length(farSIFrequency);
% 最大の長さを取得
max_len = max([len_control, len_near, len_far]);
% 配列をNaNでパディング
padded_control = [controlSIFrequency; nan(max_len - len_control, 1)];
padded_near = [nearSIFrequency; nan(max_len - len_near, 1)];
padded_far = [farSIFrequency; nan(max_len - len_far, 1)];
% パディングされた配列を連結
concatenated_array = [padded_control, padded_near, padded_far]
% クラスカルウォリス検定
[kw_p,kw_bl,kw_stats] = kruskalwallis(concatenated_array, [], 'off')

if(kw_p <= 0.05)
    step = 0.3;
    ytips = max(b.YEndPoints) + step;
    % 対照と近接
    [p,h] = ranksum(controlSIFrequency, nearSIFrequency);
    label = "n.s.";
    if(p< 0.05)
        label = "*";
    end
    if(p < 0.01)
        label = "**";
    end
    xStart = b.XEndPoints(1);
    xEnd = b.XEndPoints(2);
    line([xStart, xEnd], [ytips + step; ytips + step], 'Color', 'k');
    text((xStart + xEnd)/2, ytip + step, label,'HorizontalAlignment','center','VerticalAlignment','bottom');

    % 対照と遠方
    step = 0.5;
    [p,h] = ranksum(controlSIFrequency, farSIFrequency);
    label = "n.s.";
    if(p< 0.05)
        label = "*";
    end
    if(p < 0.01)
        label = "**";
    end
    xStart = b.XEndPoints(1);
    xEnd = b.XEndPoints(3);
    line([xStart, xEnd], [ytips + step; ytips + step], 'Color', 'k');
    text((xStart + xEnd)/2, ytip + step, label,'HorizontalAlignment','center','VerticalAlignment','bottom');

    % 近接と遠方
    step = 0.7;
    [p,h] = ranksum(nearSIFrequency, farSIFrequency);
    label = "n.s.";
    if(p< 0.05)
        label = "*";
    end
    if(p < 0.01)
        label = "**";
    end
    xStart = b.XEndPoints(2);
    xEnd = b.XEndPoints(3);
    line([xStart, xEnd], [ytips + step; ytips + step], 'Color', 'k');
    text((xStart + xEnd)/2, ytip + step, label,'HorizontalAlignment','center','VerticalAlignment','bottom');

end

title('サッカード型侵入の頻度');
ylim([0,2.0]);
ylabel('頻度[Hz]');
xticklabels({'対照','近傍','遠方'});
fontsize(gcf,24,'points')


% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'SaccadicIntrusionsGraph.png'));





