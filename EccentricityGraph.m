directory = "./processedData/";

% 個人のデータ
% subject = "subject7/";
% dataPath = strcat(directory, subject);
% controlTable = readtable(strcat(dataPath,"controlRT.csv"));
% nearTable = readtable(strcat(dataPath,"nearRT.csv"));
% farTable = readtable(strcat(dataPath,"farRT.csv"));

% Allデータ
% ディレクトリ内のすべてのサブディレクトリを取得
subdirs = dir(directory);
subdirs = subdirs([subdirs.isdir]);  % ディレクトリのみを取得
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));  % '.'と'..'を除外
controlTable = table();
nearTable = table();
farTable = table();
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

    % 各データを結合
    controlTable = [controlTable; control];
    nearTable = [nearTable; near];
    farTable = [farTable; far];
end



verifiedControlTable = rmmissing(controlTable);
missingControlRTRows = controlTable(ismissing(controlTable.RT), :);
verifiedNearTable = rmmissing(nearTable);
missingNearRTRows = nearTable(ismissing(nearTable.RT), :);
verifiedFarTable = rmmissing(farTable);
missingFarRTRows = farTable(ismissing(farTable.RT), :);


% PDTRTと速度の関係
% figure
% nexttile
% plot(verifiedControlTable.MeanVelocity,verifiedControlTable.RT,'o');
% xlim([10,20]);
% ylim([0.3,1.0]);
% xlabel('速度[m/s]');
% ylabel('応答時間[s]');
% title('対照');
% lsline;
% mdl = fitlm(verifiedControlTable,'RT~MeanVelocity');  % Create a linear regression model
% a_control = mdl.Coefficients.Estimate(1);  % Get the intercept
% R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
% text(18, 0.94, ['a = ', num2str(a_control)]);
% text(18, 0.9, ['R^2 = ', num2str(R2_control)]);

% nexttile
% plot(verifiedNearTable.MeanVelocity,verifiedNearTable.RT,'o');
% xlim([10,20]);
% ylim([0.3,1.0]);
% xlabel('速度[m/s]');
% ylabel('応答時間[s]');
% title('近傍');
% lsline;
% mdl = fitlm(verifiedNearTable,'RT~MeanVelocity');  % Create a linear regression model
% a_near = mdl.Coefficients.Estimate(1);  % Get the intercept
% R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
% text(18, 0.94, ['a = ', num2str(a_near)]);
% text(18, 0.9, ['R^2 = ', num2str(R2_near)]);

% nexttile
% plot(verifiedFarTable.MeanVelocity,verifiedFarTable.RT,'o');
% xlim([10,20]);
% ylim([0.3,1.0]);
% xlabel('速度[m/s]');
% ylabel('応答時間[s]');
% title('遠方');
% lsline;
% mdl = fitlm(verifiedFarTable,'RT~MeanVelocity');  % Create a linear regression model
% a_far = mdl.Coefficients.Estimate(1);  % Get the intercept
% R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
% text(18, 0.94, ['a = ', num2str(a_far)]);
% text(18, 0.9, ['R^2 = ', num2str(R2_far)]);

% PDTRTと偏心度の関係

labelPos_x = 37.5;
labelPos_y = 1.35;
xLimit = [2.5,56];
yLimit = [0.2,1.5];

figure
nexttile
plot(verifiedControlTable.HDegree,verifiedControlTable.RT,'o');
xlim(xLimit);
ylim(yLimit);
xlabel('偏心度(水平)[°]');
ylabel('反応時間[s]');
title('対照');
lsline;
mdl = fitlm(verifiedControlTable,'RT~HDegree');  % Create a linear regression model
a_control = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_control = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(labelPos_x, labelPos_y + 0.1, ['a = ', num2str(a_control)]);
text(labelPos_x, labelPos_y, ['R^2 = ', num2str(R2_control)]);

nexttile
plot(verifiedNearTable.HDegree,verifiedNearTable.RT,'o');
xlim(xLimit);
ylim(yLimit);
xlabel('偏心度(水平)[°]');
ylabel('反応時間[s]');
title('近傍');
lsline;
mdl = fitlm(verifiedNearTable,'RT~HDegree');  % Create a linear regression model
a_near = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_near = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(labelPos_x, labelPos_y + 0.1, ['a = ', num2str(a_near)]);
text(labelPos_x, labelPos_y, ['R^2 = ', num2str(R2_near)]);

nexttile
plot(verifiedFarTable.HDegree,verifiedFarTable.RT,'o');
xlim(xLimit);
ylim(yLimit);
xlabel('偏心度(水平)[°]');
ylabel('反応時間[s]');
lsline;
title('遠方');
mdl = fitlm(verifiedFarTable,'RT~HDegree');  % Create a linear regression model
a_far = mdl.Coefficients.Estimate(2);  % Get the intercept
R2_far = mdl.Rsquared.Ordinary;  % Get the R-squared value
text(labelPos_x, labelPos_y + 0.1, ['a = ', num2str(a_far)]);
text(labelPos_x, labelPos_y, ['R^2 = ', num2str(R2_far)]);

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 2, 1]);
fontsize(gcf,36,'points')
saveas(gcf, fullfile('./graphs', 'PDTRT_Degree_Graph.png'));

figure;
StimulusHDegree = 5.5:2.5:53.0;
nexttile
% missingControlRTRows.HDegreeの要素をStimulusDegreeに基づいて集計
[~, ~, controlBin] = histcounts(missingControlRTRows.HDegree, [StimulusHDegree, Inf]);
controlCounts = accumarray(controlBin(controlBin > 0), 1, [length(StimulusHDegree), 1]);
% 見逃し数から見逃し率を計算
[~,~,controlIdx] = unique(controlTable.HDegree);
controlMissRate = controlCounts ./ accumarray(controlIdx, 1);
bar(StimulusHDegree, controlMissRate);
xlim([0,60]);
ylim([0,1.1]);
xlabel('偏心度(水平)[°]');
ylabel('見逃し率[%]');
title('対照');

nexttile
[~,~,nearBin] = histcounts(missingNearRTRows.HDegree, [StimulusHDegree, Inf]);
nearCounts = accumarray(nearBin(nearBin > 0), 1, [length(StimulusHDegree), 1]);
% 見逃し数から見逃し率を計算
[~,~,nearIdx] = unique(nearTable.HDegree);
nearMissRate = nearCounts ./ accumarray(nearIdx, 1);
bar(StimulusHDegree, nearMissRate);
xlim([0,60]);
ylim([0,1.1]);
xlabel('偏心度(水平)[°]');
ylabel('見逃し率[%]');
title('近接');

nexttile
[~,~,farBin] = histcounts(missingFarRTRows.HDegree, [StimulusHDegree, Inf]);
farCounts = accumarray(farBin(farBin > 0), 1, [length(StimulusHDegree), 1]);
% 見逃し数から見逃し率を計算
[~,~,farIdx] = unique(farTable.HDegree);
farMissRate = farCounts ./ accumarray(farIdx, 1);
bar(StimulusHDegree, farMissRate);
xlim([0,60]);
ylim([0,1.1]);
xlabel('偏心度(水平)[°]');
ylabel('見逃し率[%]');
title('遠方');

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 2, 1]);
fontsize(gcf,36,'points')
saveas(gcf, fullfile('./graphs', 'PDTMissing_Degree_Graph.png'));



