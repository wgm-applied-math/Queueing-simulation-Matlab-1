classdef PriorityQueue < handle
    % PriorityQueue Container that maintains items that have an ordering
    % feature.  The item with the least value is made available.

    % This is not a particularly good implementation.  An ordered heap is
    % the usual data structure for a priority queue.  Since there isn't one
    % built into MATLAB, I'm just using a cell array and sorting it each
    % time a new element is inserted or removed.

    properties (GetAccess=private)
        Elements = {};
        SortFeature = @(x) x;
    end
    methods
        function obj = PriorityQueue(Elements, SortFeature)
            % PriorityQueue - Create a priority queue.

            arguments
                % Elements - A cell array with the initial elements.
                % The default is {}.
                Elements = {};

                % SortFeature - A function that computes the value by which
                % elements are to be sorted.  The default is the identity
                % function, which is appropriate for number-like elements.
                SortFeature = @(x) x;
            end
            obj.SortFeature = SortFeature;
            obj.Elements = sort_by(Elements, SortFeature);
        end
        function n = size(obj)
            % size - Number of elements in this container.
            n = length(obj.Elements);
        end
        function x = is_empty(obj)
            % is_empty - Whether this container is empty.
            x = size(obj) == 0; 
        end
        function x = is_not_empty(obj)
            % is_not_empty - Whether this container has at least one
            % element.
            x = size(obj) > 0; 
        end
        function x = first(obj)
            % first - Get the element with least sort feature.
            if is_not_empty(obj)
                x = obj.Elements{1};
            else
                error('no elements available');
            end
        end
        function x = pop_first(obj)
            % pop_first - Get the element with least sort feature and
            % remove it from this container.
            x = first(obj);
            obj.Elements(1) = [];
        end
        function push(obj, element)
            % push - Insert a new element into this container.
            v = obj.Elements;
            v{end+1} = element;
            obj.Elements = sort_by(v, obj.SortFeature);
        end
    end
end