% PDTRTのクラス
classdef LookingObject
    properties
        name
        control
        near
        far
    end
    
    methods
        % コンストラクタ
        function obj = LookingObject(name,control,near,far)
            % 引数のバリデーション
            if nargin == 4
                obj.name = name;
                obj.control = Objects(control);
                obj.near = Objects(near);
                obj.far = Objects(far);
            else
                error('Arguments for control, near, and far are required');
            end
        end

        function obj = addData(obj,control,near,far)
            obj.control = obj.control.addData(control);
            obj.near = obj.near.addData(near);
            obj.far = obj.far.addData(far);
        end
    end
end
