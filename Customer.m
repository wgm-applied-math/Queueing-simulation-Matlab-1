classdef Customer < handle
    properties
        Id;
        ArrivalTime;
        BeginServiceTime;
        DepartureTime;
    end
    methods
        function obj = Customer(Id, ArrivalTime, BeginServiceTime, DepartureTime)
            arguments
                Id = 0;
                ArrivalTime = Inf;
                BeginServiceTime = Inf;
                DepartureTime = Inf;
            end
            obj.Id = Id;
            obj.ArrivalTime = ArrivalTime;
            obj.BeginServiceTime = BeginServiceTime;
            obj.DepartureTime = DepartureTime;
        end
    end
end