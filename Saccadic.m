% PDTRTのクラス
classdef Saccadic
    properties
        name
        control
        near
        far
    end
    
    methods
        % コンストラクタ
        function obj = Saccadic(name,control, near, far)
            % 引数のバリデーション
            if nargin == 4
                obj.name = name;
                obj.control = control;
                obj.near = near;
                obj.far = far;
            else
                error('Arguments for control, near, and far are required');
            end
        end

        function [controlSaccadic, nearSaccadic, farSaccadic] = getSaccadics(obj)
            controlSaccadic = obj.control;
            nearSaccadic = obj.near;
            farSaccadic = obj.far;
        end
    end
end