function SagData = SouthwellAvgIntegration(slopeX,slopeY, hx, hy)
% Integrate slope data using the method outlined in Southwell's paper,
%
% INPUTS:
% 1) Slopes: struct with Slopes.X and Slopes.Y of dimension MXN
% 2) hx: Distance between x points in physical units
% 3) hy: Distance between y points in physical units
%
% OUTPUT:
% 1) Integrated data

   
    M = size(slopeX,1);
    N = size(slopeX,2);
    
    % Compute the slope averages
    avgSlopeX = (slopeX(:,1:end-1) + slopeX(:,2:end))/2;
    avgSlopeY = (slopeY(1:end-1,:) + slopeY(2:end,:))/2;
    
    yMaskNaNs = ~isnan(avgSlopeY);
    xMaskNaNs = ~isnan(avgSlopeX);
    
    % Convert NaN mask to 0s
    avgSlopeX(isnan(avgSlopeX)) = 0;
    avgSlopeY(isnan(avgSlopeY)) = 0;
    
    % Reshape into vectors
    avgSlopeXvec = reshape(avgSlopeX,M*(N-1),1);
    avgSlopeYvec = reshape(avgSlopeY,(M-1)*N,1);
    % Combine x and y slopes
    avgSlopeVec = [avgSlopeXvec; avgSlopeYvec];

    % Preallocate space
    slopeYi = zeros(2*(M-1)*N,1);
    slopeYj = zeros(2*(M-1)*N,1);
    slopeYv = zeros(2*(M-1)*N,1);
    slopeYjIndex = 1;
    
    for i = 1:(M-1)*N
        
        slopeYi(2*i-1) = i;
        slopeYi(2*i) = i;

        
        if mod(slopeYjIndex,M) == 0
            % End of Column adjustment
            slopeYjIndex = slopeYjIndex+1;
        end
        
        slopeYj(2*i-1) = slopeYjIndex;
        slopeYj(2*i) = slopeYjIndex+1;
        
        % Compute the value of each nonzero element in the matrix
        slopeYv(2*i-1) = -1/hy*yMaskNaNs(i);
        slopeYv(2*i) = 1/hy*yMaskNaNs(i);

        slopeYjIndex = slopeYjIndex+1;
    end

    % Preallocate space 
    slopeXi = zeros(2*M*(N-1),1);
    slopeXj = zeros(2*M*(N-1),1);
    slopeXv = zeros(2*M*(N-1),1);
    
    for i = 1:M*(N-1)
        % The i index for each nonzero element in the matrix
        slopeXi(2*i-1) = i;
        slopeXi(2*i) = i;

        % The j index for each nonzero element in the matrix
        slopeXj(2*i-1) = i;
        slopeXj(2*i) = i+M;

        % The value of the coefficient at i,j
        slopeXv(2*i-1) = -1/hx*xMaskNaNs(i);
        slopeXv(2*i) = 1/hx*xMaskNaNs(i);
    end

    % Generate the sparse coefficient matrices
    Ax = sparse(slopeXi,slopeXj,slopeXv,M*(N-1),M*N);
    Ay = sparse(slopeYi,slopeYj,slopeYv,(M-1)*N,M*N);

    % Combine to create coefficient matrix for the system of equations
    A = [Ax; Ay];
    
    % Solve system of equations
    
    SagData = A\avgSlopeVec;
    
    % Reshape sag to the same dimensions as the input slopes
    SagData = reshape(SagData,M,N);
    
    % Mask the data with the original NaN values
    SagData(isnan(slopeX) | isnan(slopeY)) = NaN;
end