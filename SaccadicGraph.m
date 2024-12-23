clear;
directory = "./processedData/";
% ディレクトリ内のすべてのサブディレクトリを取得
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外

% RTクラスの配列を宣言
subjects = Saccadic.empty(0, 0);

% 各サブディレクトリに対してRTクラスのインスタンスを作成
for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    % testDataはパス
    if strcmp(subdirName, "testData")
        continue;
    end
    % ファイルの存在をチェック
    if exist(fullfile(directory, subdirName, "saccadic_100.json"), 'file') ~= 2
        continue;
    end
    disp(subdirName);
    % データの取得
    dataFilePath = fullfile(directory, subdirName, "saccadic_100.json");
    dataContent = fileread(dataFilePath);
    data = jsondecode(dataContent);
    % meta.jsonファイルを読み込む
    metaFilePath = fullfile(directory, subdirName, "meta.json");
    metaContent = fileread(metaFilePath);
    meta = jsondecode(metaContent);
    disp(meta.name);
    
    % RTクラスのインスタンスを作成
    % subjects(i) = RT(subdirName,control, near, far);
    subject = Saccadic(meta.view,data.control, data.near, data.far);
    subjects = [subjects, subject];

end
% ソートしてallを結合
subjects = sortData(subjects);

% 各データを検定結果付きで表示
showData(subjects, 'Saccadic_Graph.png');

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
    Saccadic = zeros(length(subjects), 3);

    for i = 1:length(subjects)
        subject = subjects(i);
        [controlSaccadic, nearSaccadic, farSaccadic] = subject.getSaccadics();
        Saccadic(i,1) = controlSaccadic;
        Saccadic(i,2) = nearSaccadic;
        Saccadic(i,3) = farSaccadic;
    end

    % 棒グラフの描画
    figure;
    b = bar(Saccadic);

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



