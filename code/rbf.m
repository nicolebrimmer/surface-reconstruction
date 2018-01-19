%{
    Performs the radial basis function (RBF) that is specified by the
    parameters [rbfName] and [arguments] on the points in the array x and
    returns the results in the vector y.

    This function currently supports the following RBF's:
        * Tri-harmonic basis functions
            y = (r(x)) ^ 3
            [rbfName] = 'tri-harmonic'
            [arguments] = []
        * Polyharmonic spline
            y = (r(x) ^ k) * log(k) when k = 2, 4, 6,...
            y = (r(x) ^ k) when k = 1, 3, 5,...
            [rbfName] = 'polyharmonic'
            [arguments] = [k], where k must be a positive integer
        * Multiquadratic
            y = sqrt(r .^ 2 + beta ^ 2)
            [rbfName] = 'multiquadratic'
            [arguments] = [beta]
        * Gaussian
            y = exp(-beta * r .^ 2)
            [rbfName] = 'gaussian'
            [arguments] = [beta]


    where r(x) is a vector of the magntitudes of all of the points in x.

    @param rbfName the name of the rbf to be performed on the points in x.
    @param arguments the values of the constants in the function definition
                     of the rbf to be performed on the points in x.
    @param x the points on which the rbf will be performed.  Each row of
             the array [x] represents a point.  Therefore, the dimensions
             of x is [Number of Points] x [Number of Dimensions of Each
             Points].  For example, x will have 3 columns if we are dealing
             with the 3D world.

    @return y a vector containing the results of performing the specified
              rbf on the points in x.  More specifically, y[n] is the 
              result of performing the rbf on the point x[n, :].
%}

function [ y ] = rbf( rbfName, arguments, x )
    % The number of points is the number of rows of x.
    numOfPoints = size(x, 1);
    
    r = zeros(numOfPoints, 1);
    for pointIndex = 1:numOfPoints
        point = x(pointIndex, :);
        r(pointIndex) = norm(point);
    end
    
    y = zeros(numOfPoints, 1);
    if (strcmp(rbfName,'tri-harmonic'))
        y = r .^ 3;
        
    elseif (strcmp(rbfName, 'polyharmonic'))
        k = arguments(1);
        
        if (mod(k, 2) == 0)
            y = (r .^ k) .* log(k);
        elseif(mod(k, 2) == 1)
            y = (r .^ k);
        else
            error('The k value for the polyharmonic spline is not an integer.');
        end
        
    elseif (strcmp(rbfName, 'multiquadratic'))
        beta = arguments(1);
        y = sqrt((r .^ 2) + (beta ^ 2));
    
    elseif (strcmp(rbfName, 'gaussian'))
        beta = arguments(1);
        y = exp(- beta * r .^ 2);
        
    else
        error (strcat(rbfName, ' is not recognized as a valid RBF name'))
    end

end

