clear;
directory = "./processedData/";
% ディレクトリ内のすべてのサブディレクトリを取得
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外

% RTクラスの配列を宣言
subjects = LookingObject.empty(0, 0);
all = LookingObject.empty(1, 0);

% 各サブディレクトリに対してRTクラスのインスタンスを作成
for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    % testDataはパス
    if strcmp(subdirName, "testData")
        continue;
    end
    % ファイルの存在をチェック
    if exist(fullfile(directory, subdirName, "LookingObject.json"), 'file') ~= 2
        continue;
    end
    disp(subdirName);
    % データの取得
    dataFilePath = fullfile(directory, subdirName, "LookingObject.json");
    dataContent = fileread(dataFilePath);
    data = jsondecode(dataContent);
    % meta.jsonファイルを読み込む
    metaFilePath = fullfile(directory, subdirName, "meta.json");
    metaContent = fileread(metaFilePath);
    meta = jsondecode(metaContent);
    disp(meta.name);
    
    % RTクラスのインスタンスを作成
    % subjects(i) = RT(subdirName,control, near, far);
    subject = LookingObject(meta.view,data.control, data.near, data.far);
    subjects = [subjects, subject];

    if isempty(all)
        all = LookingObject('All',data.control, data.near, data.far);
    else
        all = all.addData(data.control, data.near, data.far);
    end

end
% ソートしてallを結合
subjects = sortData(subjects);
subjects = [subjects, all];
disp("all.control")
disp(all.control);
disp("all.near")
disp(all.near);
disp("all.far")
disp(all.far);

% パイチャートの描画
% RenderingPieChart(all);

% 各条件の視線ベクトルをヒストグラムで表示
figure;
subplot(1,3,1)
histogram(all.control.vector, 'Normalization', 'probability');
xlim([70, 110]);
ylim([0, 0.07]);
xlabel("角度[°]");
ylabel("割合");
title("対照条件")
subplot(1,3,2)
histogram(all.near.vector, 'Normalization', 'probability');
xlim([70, 110]);
ylim([0, 0.07]);
xlabel("角度[°]");
ylabel("割合");
title("近接条件")
subplot(1,3,3)
histogram(all.far.vector, 'Normalization', 'probability');
xlim([70, 110]);
ylim([0, 0.07]);
xlabel("角度[°]");
ylabel("割合");
title("遠方条件")

% グラフの装飾
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
fontsize(gcf,24,'points')

% グラフを保存
graphDir = './graphs';
mkdir(graphDir);
saveas(gcf, fullfile(graphDir, 'Car_GazeDegree.png'));

function RenderingPieChart(data)
    columuns = ["Car", "Meter", "RoomMirror", "RightMirror", "LeftMirror", "Other"];
    controlPieData = [data.control.Car, data.control.Meter, data.control.RoomMirror, data.control.RightMirror, data.control.LeftMirror, data.control.Other];
    controlTable = table(columuns, controlPieData);
    nearPieData = [data.near.Car, data.near.Meter, data.near.RoomMirror, data.near.RightMirror, data.near.LeftMirror, data.near.Other];
    nearTable = table(columuns, nearPieData);
    farPieData = [data.far.Car, data.far.Meter, data.far.RoomMirror, data.far.RightMirror, data.far.LeftMirror, data.far.Other];
    farTable = table(columuns, farPieData);

    % パイチャートの描画
    figure;
    % フォントサイズの指定
    % fontSize = 24;

    % controlのパイチャート
    subplot('Position', [0.05, 0.1, 0.25, 0.8]);
    piechart(controlTable, "controlPieData", "columuns");
    title("Control");

    % nearのパイチャート
    subplot('Position', [0.35, 0.1, 0.25, 0.8]);
    piechart(nearTable, "nearPieData", "columuns");
    title("Near");

    % farのパイチャート
    subplot('Position', [0.65, 0.1, 0.25, 0.8]);
    piechart(farTable, "farPieData", "columuns");
    title("Far");

    % グラフの装飾
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
    fontsize(gcf,12,'points')

    % グラフを保存
    graphDir = './graphs';
    mkdir(graphDir);
    saveas(gcf, fullfile(graphDir, 'LookingObject_Graph.png'));
end

% 各データを検定結果付きで表示
% showData(subjects, 'LookingObject_Graph.png');

function sortedData = sortData(data)
    % subjects配列からnameプロパティの値を抽出
    names = arrayfun(@(x) x.name, data, 'UniformOutput', false);

    % namesをアルファベット順にソートし、ソートされたインデックスを取得
    [~, sortedIndices] = sort(names);

    % ソートされたインデックスを使用してsubjects配列を並び替え
    sortedData = data(sortedIndices);
end

% 各データを検定結果付きで表示する関数
function showData(subjects,fileName)
    % 各データを棒グラフで中央値を表示
    LookingObject = zeros(length(subjects), 3);

    for i = 1:length(subjects)
        subject = subjects(i);
        [controlLookingObject, nearLookingObject, farLookingObject] = subject.getLookingObjects();
        LookingObject(i,1) = controlLookingObject;
        LookingObject(i,2) = nearLookingObject;
        LookingObject(i,3) = farLookingObject;
    end

    % 棒グラフの描画
    figure;
    b = bar(LookingObject);

    % グラフの装飾
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
    fontsize(gcf,24,'points')
    title("サッカードの回数");
    ylabel("回数[回]");
    % ylim([0, 1.5]);
    legend("対照条件", "近接条件", "遠方条件"); 
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



