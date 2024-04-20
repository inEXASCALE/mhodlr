classdef hodlr
    properties(Access=public)
        A11
        A22
        
        U1
        V2

        U2
        V1
           
        D
        level
    end

    properties(Access=private)
        min_block_size
        method
        threshold
    end

    methods(Access=public)
        function obj = hodlr(varargin)
            if nargin == 1
                obj.method = 'svd';
                obj.threshold = 1.0e-12;
                obj.min_block_size = 2;

            elseif nargin == 2
                obj.method = varargin{2};
                obj.threshold = 1.0e-12;
                obj.min_block_size = 2;

            elseif nargin == 3
                obj.method = varargin{2};
                obj.threshold = varargin{3};
                obj.min_block_size = 2;

            elseif nargin == 4
                obj.method = varargin{2};
                obj.threshold = varargin{3};
                obj.min_block_size = varargin{4};
            else 
                disp(['Please enter the correct number or type of' ...
                    ' parameters.']);
            end
            
            obj.level = 1;
            obj = build_hodlr_mat(obj, varargin{1}, obj.level);
        end
        
        function obj =  build_hodlr_mat(obj, A, level)
            [rowSize, colSize] = size(A);
            

            if rowSize <= obj.min_block_size | colSize <= obj.min_block_size
                obj.D = A;
                return;
            else
                obj.level = level;
    
                level = level + 1;
                rowSplit = ceil(rowSize / 2);
                colSplit = ceil(colSize / 2);
               
                obj.A11 = build_hodlr_mat(obj, A(1:rowSplit, 1:colSplit), ...
                    level);
                obj.A22 = build_hodlr_mat(obj, A(rowSplit+1:end, colSplit+1:end), ...
                    level);

                [obj.U1, obj.V2] = compress(obj, A(1:rowSplit, colSplit+1:end));
                [obj.U2, obj.V1] = compress(obj, A(rowSplit+1:end, 1:colSplit));
            end
        end
        
        function obj = transpose(obj)
            if isempty(obj.D)
                copyU2 = obj.U2;
                copyV1 = obj.V1;
                obj.U2 = obj.V2.';
                obj.V1 = obj.U1.';

                obj.U1 = copyV1.';
                obj.V2 = copyU2.';
                obj.A11 = transpose(obj.A11);
                obj.A22 = transpose(obj.A22);
            else
                obj.D = obj.D.';
            end
        end

        function inv_obj = inverse(obj)
            if ~issqaure(A)
                error('Inverse is only applied to a square HODLR matrix.');
            end
            
            if isempty(obj.D)
                X22 = inverse(obj.D);
                % X11 = inverse(obj.A11 - );
            else
                obj.D = inv(obj.D);
            end
        end

        function load_params(obj)
            fprintf(...
                'minimum block size: %d\n', obj.min_block_size);
            fprintf(...
                'Approximation method: %s\n', obj.method);
            fprintf(...
                'Approximation threshold: %d\n', obj.threshold);
        end
    end

    methods(Access=private)
        function [U, V] = compress(obj, A)
            [U, V] = compress_m(A, obj.method, obj.threshold);
        end
    end

end

       

        