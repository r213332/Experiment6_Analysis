clear;
directory = "./processedData/";
% ディレクトリ内のすべてのサブディレクトリを取得
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外

% RTクラスの配列を宣言
subjects = RT.empty(0, 0);
all = RT.empty(1, 0);

% 年齢
age = [];

% 各サブディレクトリに対してRTクラスのインスタンスを作成
for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    % ファイルの存在をチェック
    if exist(fullfile(directory, subdirName, "controlRT.csv"), 'file') ~= 2
        continue;
    end
    disp(subdirName);
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlRT.csv"));
    near = readtable(fullfile(directory, subdirName, "nearRT.csv"));
    far = readtable(fullfile(directory, subdirName, "farRT.csv"));
    % meta.jsonファイルを読み込む
    metaFilePath = fullfile(directory, subdirName, "meta.json");
    metaContent = fileread(metaFilePath);
    meta = jsondecode(metaContent);
    disp(meta.name);
    age = [age, str2double(meta.age)];
    
    % RTクラスのインスタンスを作成
    % subjects(i) = RT(subdirName,control, near, far);
    subject = RT(meta.view,control, near, far);
    subjects = [subjects, subject];

    if isempty(all)
        all = RT('All',control, near, far);
    else
        all = all.addData(control, near, far);
    end

end
% ソートしてallを結合
subjects = sortData(subjects);
% subjects = [subjects, all];

age_avg = mean(age);
age_std = std(age);
disp("年齢");
disp("平均");
disp(age_avg);
disp("標準偏差");
disp(age_std);

% 各データを検定結果付きで表示
showData(subjects, 'PDT_RT_Graph.png');

% 一つのデータを検定結果付きで表示
showOneData(all, 'PDT_RT_All_Graph.png');

% for i = 1:length(subjects)
%     subject = subjects(i);
% end

% allのデータを表示
% all = subjects(length(subjects));
% P = all.kruskalwallis();
% [C_N_P,C_F_P,N_F_P] = all.ranksum();
% disp("allのクラスカルワリス検定");
% disp(P);
% disp("対照条件と近接条件のウィルコクソン順位和検定");
% disp(C_N_P);
% disp("対照条件と遠方条件のウィルコクソン順位和検定");
% disp(C_F_P);
% disp("近接条件と遠方条件のウィルコクソン順位和検定");
% disp(N_F_P);

% MissRateの検定&描画
MissingRate = zeros(length(subjects), 3);
for i = 1:length(subjects)
    subject = subjects(i);

    [controlMissRate, nearMissRate, farMissRate] = subject.getMissingRate();
    MissingRate(i,1) = controlMissRate;
    MissingRate(i,2) = nearMissRate;
    MissingRate(i,3) = farMissRate;
end
[s1_c_h,C_P] = swtest(MissingRate(:,1));
[s1_n_h,N_P] = swtest(MissingRate(:,2));
[s1_f_h,F_P] = swtest(MissingRate(:,3));
disp("MissRateのシャピロウィルク検定");
disp(C_P);
disp(N_P);
disp(F_P);
% % クラスカルワリス検定
% figure;
% [subject_p,subject_tbl,subject_stats] = kruskalwallis(MissingRate, [], 'off');
% disp("MissRateのクラスカルワリス検定");
% disp(subject_p);
% % result = multcompare(subject_stats);
% medianMissRate = median(MissingRate);
% bar(medianMissRate);

% ANOVA
figure;
p = anova1(MissingRate);
meanMissRate = mean(MissingRate);
stdMissRate = std(MissingRate);
bar(meanMissRate);
hold on;
errorbar(meanMissRate, stdMissRate, 'k', 'linestyle', 'none','LineWidth',2);
disp("MissRateのANOVA");
disp(p);

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
fontsize(gcf,36,'points')
ylim([0, 0.35]);
ylabel("見逃し率の平均");
xticklabels(["対照条件", "近接条件", "遠方条件"]);
title('PDTの見逃し率の平均');

saveas(gcf, fullfile('./graphs', 'PDT_RT_Miss_Graph.png'));

function sortedData = sortData(data)
    % subjects配列からnameプロパティの値を抽出
    names = arrayfun(@(x) x.name, data, 'UniformOutput', false);

    % namesをアルファベット順にソートし、ソートされたインデックスを取得
    [~, sortedIndices] = sort(names);

    % ソートされたインデックスを使用してsubjects配列を並び替え
    sortedData = data(sortedIndices);
end

% 一つの結果を検定結果付きで表示する関数
function showOneData(subject,fileName)
    % 各データを棒グラフで中央値を表示
    Median = zeros(3,1);
    errorMin = zeros(3,1);
    errorMax = zeros(3,1);

    MissingRate = zeros(3);


        [controlMedian, nearMedian, farMedian] = subject.getMedians();
        Median(1) = controlMedian;
        Median(2) = nearMedian;
        Median(3) = farMedian;


        [controlQuantiles, nearQuantiles, farQuantiles] = subject.getQuantiles();
        errorMin(1) = controlMedian - controlQuantiles(1);
        errorMin(2) = nearMedian - nearQuantiles(1);
        errorMin(3) = farMedian - farQuantiles(1);
        errorMax(1) = controlQuantiles(2) - controlMedian;
        errorMax(2) = nearQuantiles(2) - nearMedian;
        errorMax(3) = farQuantiles(2) - farMedian;

        [controlMissRate, nearMissRate, farMissRate] = subject.getMissingRate();
        MissingRate(1) = controlMissRate;
        MissingRate(2) = nearMissRate;
        MissingRate(3) = farMissRate;

    % 棒グラフの描画
    figure;
    b = bar(Median);
    hold on;
    % 検定結果のp値の表示
    y = b.YEndPoints;
    x = b.XEndPoints;
    xStart = [x(1), x(1), x(2)];
    xEnd = [x(2), x(3), x(3)];
    ytips = max(y) + 0.05;
    yStep = 0.04;
    C_N_label = '';
    C_F_label = '';
    N_F_label = '';

    p = subject.kruskalwallis();
    disp(subject.name);
    disp(p); 
    if(p < 0.05)
        [C_N_P,C_F_P,N_F_P] = subject.ranksum();
        if(C_N_P < 0.05)
            C_N_label = "*";
        end
        if(C_N_P < 0.01)
            C_N_label = "**";
        end

        if(C_F_P < 0.05)
            C_F_label = "*";
        end
        if(C_F_P < 0.01)
            C_F_label = "**";
        end

        if(N_F_P < 0.05)
            N_F_label = "*";
        end
        if(N_F_P < 0.01)
            N_F_label = "**";
        end

        C_N_label = strcat(strcat(C_N_label,' p='), string(C_N_P));
        C_F_label = strcat(strcat(C_F_label,' p='), string(C_F_P));
        N_F_label = strcat(strcat(N_F_label,' p='), string(N_F_P));

    else
        xStart = xEnd;
    end

    labels = [C_N_label, C_F_label, N_F_label];

    % disp([xStart; xEnd]);
    % disp([ytips+yStep,ytips+3*yStep,ytips+2*yStep;ytips+yStep,ytips+3*yStep,ytips+2*yStep]);

    line([xStart; xEnd], [ytips+yStep,ytips+3*yStep,ytips+2*yStep;ytips+yStep,ytips+3*yStep,ytips+2*yStep], 'Color', 'k','LineWidth',2.0);
    text((xEnd + xStart)./2, [ytips+yStep,ytips+3*yStep,ytips+2*yStep], labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');



    % エラーバーの描画
    [ngroups,nbars] = size(Median);
    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    errorbar(x.',Median, errorMin,errorMax, 'k', 'linestyle', 'none','LineWidth',2.0);

    % グラフの装飾
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
    fontsize(gcf,24,'points')
    title("PDTへの反応時間（中央値）");
    ylabel("反応時間[s]");
    ylim([0, 0.65]);
    legend("反応時間の中央値",'四分位範囲','',''); 
    xticklabels(["対照条件", "近接条件", "遠方条件"]);

    % グラフを保存
    graphDir = './graphs';
    mkdir(graphDir);
    saveas(gcf, fullfile(graphDir, fileName));
end

% 各データを検定結果付きで表示する関数
function showData(subjects,fileName)
    % 各データを棒グラフで中央値を表示
    Median = zeros(length(subjects), 3);
    errorMin = zeros(length(subjects), 3);
    errorMax = zeros(length(subjects), 3);

    MissingRate = zeros(length(subjects), 3);

    for i = 1:length(subjects)
        subject = subjects(i);
        [controlMedian, nearMedian, farMedian] = subject.getMedians();
        Median(i,1) = controlMedian;
        Median(i,2) = nearMedian;
        Median(i,3) = farMedian;


        [controlQuantiles, nearQuantiles, farQuantiles] = subject.getQuantiles();
        errorMin(i,1) = controlMedian - controlQuantiles(1);
        errorMin(i,2) = nearMedian - nearQuantiles(1);
        errorMin(i,3) = farMedian - farQuantiles(1);
        errorMax(i,1) = controlQuantiles(2) - controlMedian;
        errorMax(i,2) = nearQuantiles(2) - nearMedian;
        errorMax(i,3) = farQuantiles(2) - farMedian;

        [controlMissRate, nearMissRate, farMissRate] = subject.getMissingRate();
        MissingRate(i,1) = controlMissRate;
        MissingRate(i,2) = nearMissRate;
        MissingRate(i,3) = farMissRate;
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
    yStep = 0.3;
    labels = strings(length(subjects),1);
    for i = 1:length(subjects)
        subject = subjects(i);
        p = subject.kruskalwallis();
        disp(subject.name);
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
    line([xStart; xEnd], [ytips+yStep; ytips+yStep], 'Color', 'k','LineWidth',2.0);
    text((xStart + xEnd)./2, ytips+yStep, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

    % 対照条件と遠方条件
    xStart = b(1).XEndPoints;
    xEnd = b(3).XEndPoints;
    yStep = 0.4;
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
    line([xStart; xEnd], [ytips+yStep; ytips+yStep], 'Color', 'k','LineWidth',2.0);
    text((xStart + xEnd)./2, ytips+yStep, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');

    % 近接条件と遠方条件
    xStart = b(2).XEndPoints;
    xEnd = b(3).XEndPoints;
    yStep = 0.35;
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
    line([xStart; xEnd], [ytips+yStep; ytips+yStep], 'Color', 'k','LineWidth',2.0);
    text((xStart + xEnd)./2, ytips+yStep, labels, 'HorizontalAlignment','center','VerticalAlignment','bottom');


    % エラーバーの描画
    [ngroups,nbars] = size(Median);
    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    errorbar(x.',Median, errorMin,errorMax, 'k', 'linestyle', 'none','LineWidth',2.0);

    % グラフの装飾
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
    fontsize(gcf,24,'points')
    title("PDTへの反応時間（中央値）");
    ylabel("反応時間[s]");
    ylim([0, 1.5]);
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
    saveas(gcf, fullfile(graphDir, fileName));
end



