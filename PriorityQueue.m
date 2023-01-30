classdef PriorityQueue < handle
    properties
        Elements = {};
        SortFeature = @(x) x;
    end
    methods
        function obj = PriorityQueue(Elements, SortFeature)
            arguments
                Elements = {};
                SortFeature = @(x) x;
            end
            obj.SortFeature = SortFeature;
            obj.Elements = sort_by(Elements, SortFeature);
        end
        function n = size(obj)
            n = size(obj.Elements, 2);
        end
        function x = is_empty(obj)
            x = size(obj) == 0; 
        end
        function x = is_not_empty(obj)
            x = size(obj) > 0; 
        end
        function x = first(obj)
            if is_not_empty(obj)
                x = obj.Elements{1};
            else
                error('no elements available');
            end
        end
        function x = pop_first(obj)
            x = first(obj);
            obj.Elements(1) = [];
        end
        function push(obj, element)
            v = obj.Elements;
            v{end+1} = element;
            obj.Elements = sort_by(v, obj.SortFeature);
        end
    end
end