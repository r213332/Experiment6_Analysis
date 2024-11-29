clear;
directory = "./processedData/";
% ディレクトリ内のすべてのサブディレクトリを取得
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外

% RTクラスの配列を宣言
subjects = Velocity.empty(length(subdirs)+1, 0);
all = Velocity.empty(1, 0);

% 各サブディレクトリに対してRTクラスのインスタンスを作成
for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    % ファイルの存在をチェック
    if exist(fullfile(directory, subdirName, "controlVelocity.csv"), 'file') ~= 2
        continue;
    end
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlVelocity.csv"));
    near = readtable(fullfile(directory, subdirName, "nearVelocity.csv"));
    far = readtable(fullfile(directory, subdirName, "farVelocity.csv"));
    % meta.jsonファイルを読み込む
    metaFilePath = fullfile(directory, subdirName, "meta.json");
    metaContent = fileread(metaFilePath);
    meta = jsondecode(metaContent);
    disp(meta.name);
    
    % RTクラスのインスタンスを作成
    subjects(i) = Velocity(subdirName,control, near, far);
    if(i == 1)
        all = Velocity('All',control, near, far);
    else
        all = all.addData(control, near, far);
    end
end
% subjects配列からnameプロパティの値を抽出
names = arrayfun(@(x) x.name, subjects, 'UniformOutput', false);

% namesをアルファベット順にソートし、ソートされたインデックスを取得
[~, sortedIndices] = sort(names);

% ソートされたインデックスを使用してsubjects配列を並び替え
subjects = subjects(sortedIndices);
% allを結合
subjects(length(subjects)+1) = all;

% 各データを棒グラフで中央値を表示
Median = zeros(length(subjects), 3);
Mean = zeros(length(subjects), 3);
std = zeros(length(subjects), 3);
errorMin = zeros(length(subjects), 3);
errorMax = zeros(length(subjects), 3);

for i = 1:length(subjects)
    subject = subjects(i);
    [controlMedian, nearMedian, farMedian] = subject.getMedians();
    Median(i,1) = controlMedian;
    Median(i,2) = nearMedian;
    Median(i,3) = farMedian;

    [controlMean, nearMean, farMean] = subject.getMeans();
    Mean(i,1) = controlMean;
    Mean(i,2) = nearMean;
    Mean(i,3) = farMean;
    
    [controlStd, nearStd, farStd] = subject.getStds();
    std(i,1) = controlStd;
    std(i,2) = nearStd;
    std(i,3) = farStd;

    [controlQuantiles, nearQuantiles, farQuantiles] = subject.getQuantiles();
    errorMin(i,1) = controlMedian - controlQuantiles(1);
    errorMin(i,2) = nearMedian - nearQuantiles(1);
    errorMin(i,3) = farMedian - farQuantiles(1);
    errorMax(i,1) = controlQuantiles(2) - controlMedian;
    errorMax(i,2) = nearQuantiles(2) - nearMedian;
    errorMax(i,3) = farQuantiles(2) - farMedian;
end

% 棒グラフの描画
figure;
b = bar(Median);
hold on;
% 検定結果のp値の表示
control_y = b(1).YEndPoints;
near_y = b(2).YEndPoints;
far_y = b(3).YEndPoints;
ytips = max([control_y;near_y; far_y]);
% 対照条件と近接条件
xStart = b(1).XEndPoints;
xEnd = b(2).XEndPoints;
yStep = 5;
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    p = subject.kruskalwallis();
    disp(subject.name)
    disp(p);
    if(p < 0.05)
        [C_N_P,C_F_P,N_F_P] = subject.ranksum();
        label = "n.s.";
        if(C_N_P < 0.05)
            label = "*";
        end
        if(C_N_P < 0.01)
            label = "**";
        end
        labels(i) = label;
    else
        xStart(i) = xEnd(i);
        labels(i) = "";
    end
end
line([xStart; xEnd], [ytips+yStep; ytips+yStep], 'Color', 'k');
text((xStart + xEnd)./2, ytips+yStep, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

% 対照条件と遠方条件
xStart = b(1).XEndPoints;
xEnd = b(3).XEndPoints;
yStep = 7;
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    p = subject.kruskalwallis();
    if(p < 0.05)
        [C_N_P,C_F_P,N_F_P] = subject.ranksum();
        label = "n.s.";
        if(C_F_P < 0.05)
            label = "*";
        end
        if(C_F_P < 0.01)
            label = "**";
        end
        labels(i) = label;
    else
        xStart(i) = xEnd(i);
        labels(i) = "";
    end
end
line([xStart; xEnd], [ytips+yStep; ytips+yStep], 'Color', 'k');
text((xStart + xEnd)./2, ytips+yStep, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

% 近接条件と遠方条件
xStart = b(2).XEndPoints;
xEnd = b(3).XEndPoints;
yStep = 6;
labels = strings(length(subjects),1);
for i = 1:length(subjects)
    subject = subjects(i);
    p = subject.kruskalwallis();
    if(p < 0.05)
        [C_N_P,C_F_P,N_F_P] = subject.ranksum();
        label = "n.s.";
        if(N_F_P < 0.05)
            label = "*";
        end
        if(N_F_P < 0.01)
            label = "**";
        end
        labels(i) = label;
    else
        xStart(i) = xEnd(i);
        labels(i) = "";
    end
end
line([xStart; xEnd], [ytips+yStep; ytips+yStep], 'Color', 'k');
text((xStart + xEnd)./2, ytips+yStep, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

% エラーバーの描画
[ngroups,nbars] = size(Median);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x.',Median, errorMin,errorMax, 'k', 'linestyle', 'none');
% errorbar(x.',Median, std, 'k', 'linestyle', 'none');


set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
fontsize(gcf,24,'points')
title("速度の比較（区間平均の中央値）");
ylabel("速度[m/s]");
ylim([0, 30]);
legend("対照条件", "近接条件", "遠方条件",'四分位範囲','',''); 
subjectNames = {};
for i = 1:length(subjects)
    subject = subjects(i);
    subjectNames{i} = subject.name;
end
xticklabels(subjectNames);

% グラフを保存
graphDir = './graphs';
mkdir(graphDir);
saveas(gcf, fullfile(graphDir, 'Velocity_Graph_Median.png'));



