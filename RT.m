% PDTRTのクラス
classdef RT
    properties
        name
        drivingFrequency
        control
        near
        far
        controlMiss
        nearMiss
        farMiss
        dataNum
    end
    
    methods
        % コンストラクタ
        function obj = RT(name,drivingFrequency,control, near, far)
            % 引数のバリデーション
            if nargin == 5
                obj.name = name;
                obj.drivingFrequency = drivingFrequency;
                % 刺激の見逃し率計算
                obj.controlMiss = (height(control) - length(rmmissing(control{:, 1})));
                obj.nearMiss = (height(near) - length(rmmissing(near{:, 1})));
                obj.farMiss = (height(far) - length(rmmissing(far{:, 1})));

                % 未反応をフィルタリング
                obj.control = rmmissing(control{:, 1});
                obj.near = rmmissing(near{:, 1});
                obj.far = rmmissing(far{:, 1});
                obj.dataNum = height(control);
            else
                error('Arguments for control, near, and far are required');
            end
        end

        % データの追加 データ集計用
        function obj = addData(obj,control, near, far)
            cMiss = (height(control) - length(rmmissing(control{:, 1})));
            nMiss = (height(near) - length(rmmissing(near{:, 1})));
            fMiss = (height(far) - length(rmmissing(far{:, 1})));

            c = rmmissing(control{:, 1});
            n = rmmissing(near{:, 1});
            f = rmmissing(far{:, 1});

            obj.controlMiss = obj.controlMiss + cMiss;
            obj.nearMiss = obj.nearMiss + nMiss ;
            obj.farMiss = obj.farMiss + fMiss ;
            obj.control = [obj.control; c];
            obj.near = [obj.near; n];
            obj.far = [obj.far; f];
            obj.dataNum = obj.dataNum + height(control);
        end

        % 各条件の見逃し率取得
        function [controlMiss, nearMiss, farMiss] = getMissingRate(obj)
            controlMiss = obj.controlMiss / obj.dataNum;
            nearMiss = obj.nearMiss / obj.dataNum;
            farMiss = obj.farMiss / obj.dataNum;
        end

        % 中央値取得
        function [controlMedian, nearMedian, farMedian] = getMedians(obj)
            controlMedian = median(obj.control);
            nearMedian = median(obj.near);
            farMedian = median(obj.far);
        end

        % 四分位範囲を上限値と下限値で取得
        function [controlQuantiles, nearQuantiles, farQuantiles] = getQuantiles(obj)
            controlQuantiles = quantile(obj.control, [0.25 0.75]);
            nearQuantiles = quantile(obj.near, [0.25 0.75]);
            farQuantiles = quantile(obj.far, [0.25 0.75]);
        end

        % 四分位範囲取得を値で取得
        function [controlQuantilesError, nearQuantilesError, farQuantilesError] = getQuantilesError(obj)
            controlQuantiles = quantile(obj.control, [0.25 0.75]);
            nearQuantiles = quantile(obj.near, [0.25 0.75]);
            farQuantiles = quantile(obj.far, [0.25 0.75]);

            controlQuantilesError = controlQuantiles(2) - controlQuantiles(1);
            nearQuantilesError = nearQuantiles(2) - nearQuantiles(1);
            farQuantilesError = farQuantiles(2) - farQuantiles(1);
        end

        % クラスカルワリス検定
        function subject_p = kruskalwallis(obj)
            % 配列の次元数を揃える
            % 配列の長さを取得
            len_control = length(obj.control);
            len_near = length(obj.near);
            len_far = length(obj.far);
            % 最大の長さを取得
            max_len = max([len_control, len_near, len_far]);
            % 配列をNaNでパディング
            padded_control = [obj.control; nan(max_len - len_control, 1)];
            padded_near = [obj.near; nan(max_len - len_near, 1)];
            padded_far = [obj.far; nan(max_len - len_far, 1)];
            % パディングされた配列を連結
            concatenated_array = [padded_control, padded_near, padded_far];
            % クラスカルウォリス検定
            [subject_p,subject_tbl,subject_stats] = kruskalwallis(concatenated_array, [], 'off');
        end

        % シャピロウィルク検定
        function [C_P,N_P,F_P] = swtest(obj)
            import swtest.*;
            [s1_c_h,C_P] = swtest(obj.control);
            [s1_n_h,N_P] = swtest(obj.near);
            [s1_f_h,F_P] = swtest(obj.far);
        end

        % 多重比較 ウィルコクソンの順位和検定
        function [C_N_P,C_F_P,N_F_P] = ranksum(obj)
            [C_N_P,C_N_H] = ranksum(obj.control, obj.near, 'alpha', 0.05);
            [C_F_P,C_F_H] = ranksum(obj.control, obj.far, 'alpha', 0.05);
            [N_F_P,N_F_H] = ranksum(obj.near, obj.far, 'alpha', 0.05);
        end
    end
end