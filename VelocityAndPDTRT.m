classdef VelocityAndPDTRT
    properties
        velocity
        rt
    end

    methods
        % コンストラクタ
        function obj = VelocityAndPDTRT(velocity, rt)
            % 引数のバリデーション
            if nargin == 2
                obj.velocity = velocity;
                obj.rt = rt;
            else
                error('Arguments for velocity and rt are required');
            end
        end

        % データの追加 データ集計用
        function obj = addData(obj,velocity, rt)
            obj.velocity = [obj.velocity; velocity];
            obj.rt = [obj.rt; rt];
        end

        % 回帰モデルの作成
        function velocityModel = createModel(obj)
            % モデルの作成
            velocityModel = fitlm(obj.velocity, obj.rt);
        end

    end
end