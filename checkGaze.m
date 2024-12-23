% CSVファイルを読み込む
data = readtable('./data/testData/test.csv');

filteredData = data(data.GazeRay_IsValid == 1, :);
filteredData = filteredData (filteredData.mode ~= -1, :);

% 必要な列を取り出す
GazeRay_origin_x = filteredData.GazeRay_Origin_x;
GazeRay_origin_y = filteredData.GazeRay_Origin_y;
GazeRay_origin_z = filteredData.GazeRay_Origin_z;

% 0配列を作成
GazeRay_zero = zeros(size(GazeRay_origin_x));

GazeRay_direction_x = filteredData.GazeRay_Direction_x;
GazeRay_direction_y = filteredData.GazeRay_Direction_y;
GazeRay_direction_z = filteredData.GazeRay_Direction_z;

% 三次元空間にプロット
figure;
quiver3(-1 * GazeRay_origin_x, GazeRay_origin_y, GazeRay_origin_z,...
-1 * GazeRay_direction_x, GazeRay_direction_y, GazeRay_direction_z...
,100,"b");

hold on

% quiver3(GazeRay_zero, GazeRay_zero, GazeRay_zero,...
% -1 * GazeRay_direction_x, GazeRay_direction_y, GazeRay_direction_z...
% ,100,"r");

axis equal
xlabel("左右");
ylabel("上下");
zlabel("前後");
