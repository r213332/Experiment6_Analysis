clear

directory = "./processedData/";
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外


controlTable = table();
nearTable = table();
farTable = table();

for i = 1:length(subdirs)
    subdirName = subdirs(i).name;
    if exist(fullfile(directory, subdirName, "controlGazeRT.csv"), 'file') ~= 2
        continue;
    end
    
    % 各CSVファイルを読み込む
    control = readtable(fullfile(directory, subdirName, "controlGazeRT.csv"));
    near = readtable(fullfile(directory, subdirName, "nearGazeRT.csv"));
    far = readtable(fullfile(directory, subdirName, "farGazeRT.csv"));
    
    disp(subdirName);
    % 連結
    controlTable = vertcat(controlTable, control);
    nearTable = vertcat(nearTable, near);
    farTable = vertcat(farTable, far);
end

% サッケードが起きなかったデータを抽出
missingControlRTRows = controlTable(ismissing(controlTable.GazeRT), :);
missingNearRTRows = nearTable(ismissing(nearTable.GazeRT), :);
missingFarRTRows = farTable(ismissing(farTable.GazeRT), :);

% 欠損値を除外
controlTable = rmmissing(controlTable);
nearTable = rmmissing(nearTable);
farTable = rmmissing(farTable);

% グラフ保存用
graphDir = './graphs';
mkdir(graphDir);

% 水平方向の偏心度とサッカード時間の関係をプロット
figure
nexttile
plot(controlTable.GazeRT,controlTable.StimulusHorizontalDegree,'o');
xlim([0,2.0]);
ylim([0,55]);
xlabel('サッカード[s]');
ylabel('水平方向の偏心度[°]');
title('対照条件');
lsline;
mdl = fitlm(controlTable,'StimulusHorizontalDegree~GazeRT');  % Create a linear regression model
a_control = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(1.6, 50, ['a = ', num2str(a_control)]);
text(1.6, 45, ['R^2 = ', num2str(R2_control)]);

nexttile
plot(nearTable.GazeRT,nearTable.StimulusHorizontalDegree,'o');
xlim([0,2.0]);
ylim([0,55]);
xlabel('サッカード[s]');
ylabel('水平方向の偏心度[°]');
title('近接条件');
lsline;
mdl = fitlm(nearTable,'StimulusHorizontalDegree~GazeRT');  % Create a linear regression model
a_near = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(1.6, 50, ['a = ', num2str(a_near)]);
text(1.6, 45, ['R^2 = ', num2str(R2_near)]);

nexttile
plot(farTable.GazeRT,farTable.StimulusHorizontalDegree,'o');
xlim([0,2.0]);
ylim([0,55]);
xlabel('サッカード[s]');
ylabel('水平方向の偏心度[°]');
title('遠方条件');
lsline;
mdl = fitlm(farTable,'StimulusHorizontalDegree~GazeRT');  % Create a linear regression model
a_far = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(1.6, 50, ['a = ', num2str(a_far)]);
text(1.6, 45, ['R^2 = ', num2str(R2_far)]);

fontsize(gcf,12,'points');

% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'StimulusHorizontalDegree~GazeRT_Graph.png'));

% 初期の距離とサッカード時間の関係をプロット
% figure
% nexttile
% plot(controlTable.GazeRT,controlTable.InitialGazeDistance,'o');
% xlim([0,2.0]);
% ylim([0,80]);
% xlabel('サッカード[s]');
% ylabel('刺激提示時の角度[°]');
% title('対照条件');
% lsline;
% mdl = fitlm(controlTable,'InitialGazeDistance~GazeRT');  % Create a linear regression model
% a_control = mdl.Coefficients.Estimate(2);  % Get the intercept
% R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
% text(1.6, 75, ['a = ', num2str(a_control)]);
% text(1.6, 70, ['R^2 = ', num2str(R2_control)]);

% nexttile
% plot(nearTable.GazeRT,nearTable.InitialGazeDistance,'o');
% xlim([0,2.0]);
% ylim([0,80]);
% xlabel('サッカード[s]');
% ylabel('刺激提示時の角度[°]');
% title('近傍条件');
% lsline;
% mdl = fitlm(nearTable,'InitialGazeDistance~GazeRT');  % Create a linear regression model
% a_near = mdl.Coefficients.Estimate(2);  % Get the intercept
% R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
% text(1.6, 75, ['a = ', num2str(a_near)]);
% text(1.6, 70, ['R^2 = ', num2str(R2_near)]);

% nexttile
% plot(farTable.GazeRT,farTable.InitialGazeDistance,'o');
% xlim([0,2.0]);
% ylim([0,80]);
% xlabel('サッカード[s]');
% ylabel('刺激提示時の角度[°]');
% title('遠方条件');
% lsline;
% mdl = fitlm(farTable,'InitialGazeDistance~GazeRT');  % Create a linear regression model
% a_far = mdl.Coefficients.Estimate(2);  % Get the intercept
% R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
% text(1.6, 75, ['a = ', num2str(a_far)]);
% text(1.6, 70, ['R^2 = ', num2str(R2_far)]);

% % グラフ保存
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
% saveas(gcf, fullfile(graphDir, 'InitialGazeDistance~GazeRT_Graph.png'));

% RTとサッカード時間の関係をプロット
figure
nexttile
plot(controlTable.GazeRT,controlTable.RT,'o');
xlim([0,2.0]);
ylim([0,2.0]);
xlabel('サッカード[s]');
ylabel('RT[s]');
title('対照条件');
lsline;
mdl = fitlm(controlTable,'RT~GazeRT');  % Create a linear regression model
a_control = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(1.6, 1.8, ['a = ', num2str(a_control)]);
text(1.6, 1.7, ['R^2 = ', num2str(R2_control)]);

nexttile
plot(nearTable.GazeRT,nearTable.RT,'o');
xlim([0,2.0]);
ylim([0,2.0]);
xlabel('サッカード[s]');
ylabel('RT[s]');
title('近接条件');
lsline;
mdl = fitlm(nearTable,'RT~GazeRT');  % Create a linear regression model
a_near = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(1.6, 1.8, ['a = ', num2str(a_near)]);
text(1.6, 1.7, ['R^2 = ', num2str(R2_near)]);

nexttile
plot(farTable.GazeRT,farTable.RT,'o');
xlim([0,2.0]);
ylim([0,2.0]);
xlabel('サッカード[s]');
ylabel('RT[s]');
title('遠方条件');
lsline;
mdl = fitlm(farTable,'RT~GazeRT');  % Create a linear regression model
a_far = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(1.6, 1.8, ['a = ', num2str(a_far)]);
text(1.6, 1.7, ['R^2 = ', num2str(R2_far)]);

fontsize(gcf,12,'points');

% グラフ保存
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
saveas(gcf, fullfile(graphDir, 'RT~GazeRT_Graph.png'));