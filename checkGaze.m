% CSVファイルを読み込む
data = readtable('./data/testData/test.csv');

filteredData = data(data.GazeRay_IsValid == 1, :);
filteredData = filteredData (filteredData.mode ~= -1, :);

% 必要な列を取り出す
GazeRay_origin_x = filteredData.GazeRay_Origin_x;
GazeRay_origin_y = filteredData.GazeRay_Origin_y;
GazeRay_origin_z = filteredData.GazeRay_Origin_z;

GazeRay_direction_x = filteredData.GazeRay_Direction_x;
GazeRay_direction_y = filteredData.GazeRay_Direction_y;
GazeRay_direction_z = filteredData.GazeRay_Direction_z;

HeadPosition_x = filteredData.camera_x + 0.42;
HeadPosition_y = filteredData.camera_y + 0.15;
HeadPosition_z = filteredData.camera_z + 0.368;

CameraRig_x = filteredData.camera_x;
CameraRig_y = filteredData.camera_y;
CameraRig_z = filteredData.camera_z;

% Head_direction_x = GazeRay_origin_x - HeadPosition_x;
% Head_direction_y = GazeRay_origin_y - HeadPosition_y;
% Head_direction_z = GazeRay_origin_z - HeadPosition_z;

Head_direction_x = GazeRay_origin_x - 0.4147721;
Head_direction_y = GazeRay_origin_y - 1.165647;
Head_direction_z = GazeRay_origin_z - 0.03467695 + 0.06;

Head_rotation_x = filteredData.head_rx;
Head_rotation_y = filteredData.head_ry;
Head_rotation_z = filteredData.head_rz;
Head_rotation_w = filteredData.head_rw;

Head_rotation = quaternion(Head_rotation_w, Head_rotation_x, Head_rotation_y, Head_rotation_z);
Head_rotation_deg = eulerd(Head_rotation, 'ZYX', 'frame');

% 三次元空間にプロット
figure;
quiver3(-1 * Head_direction_x,Head_direction_y,Head_direction_z,...
 -1 * GazeRay_direction_x, GazeRay_direction_y, GazeRay_direction_z...
 ,100,"b");
%  quiver3(-1 * GazeRay_origin_x, GazeRay_origin_y, GazeRay_origin_z,...
%  -1 * GazeRay_direction_x, GazeRay_direction_y, GazeRay_direction_z...
%  ,100,"b");
%  hold on;
%  plot3(-1 * HeadPosition_x, HeadPosition_y, HeadPosition_z, "ro");

axis equal
xlabel("左右");
ylabel("上下");
zlabel("前後");

figure;
plot(Head_rotation_deg);