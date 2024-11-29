% PDTRTのクラス
classdef Objects
    properties
        Car,
        Meter,
        RoomMirror,
        RightMirror,
        LeftMirror,
        Other,
        vector,
    end
    
    methods
        % コンストラクタ
        function obj = Objects(data)
            % 引数のバリデーション
            if nargin == 1
                obj.Car = data.Car;
                obj.Meter = data.Meter;
                obj.RoomMirror = data.RoomMirror;
                obj.RightMirror = data.RightMirror;
                obj.LeftMirror = data.LeftMirror;
                obj.Other = data.Other;
                obj.vector = data.vector;
            else
                error('Arguments for data are required');
            end
        end

        function obj = addData(obj, data)
            obj.Car = obj.Car + data.Car;
            obj.Meter = obj.Meter + data.Meter;
            obj.RoomMirror = obj.RoomMirror + data.RoomMirror;
            obj.RightMirror = obj.RightMirror + data.RightMirror;
            obj.LeftMirror = obj.LeftMirror + data.LeftMirror;
            obj.Other = obj.Other + data.Other;

            % disp(obj.vector);
            % disp(data.vector);
            obj.vector = [obj.vector; data.vector];
        end
    end
end
