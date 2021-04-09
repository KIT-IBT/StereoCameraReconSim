function [x_out, y_out] = poly2cw_custom(x_in, y_in)
    %% poly2cw_custom
    %converts 2D polygons to clockwise orientation if they are not already
    %clockwise
    %
    %N.B. this does not support cell array or NaN separated inputs, only 
    %vectors.
    N = numel(x_in);
    assert(N == numel(y_in),'x_in and y_in length mismatch.')
    assert(isvector(x_in),'x_in is not a 1xN or Nx1 vector')
    assert(isvector(y_in),'y_in is not a 1xN or Nx1 vector')
    assert(N >= 3,'Input polygon has less than 3 vertices.')

    %Determine order, method see accepted answer:
    %https://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order
    edgeSum = 0;
    for i = 1:N-1
            edgeSum = edgeSum + (x_in(i+1)-x_in(i))*(y_in(i+1)+y_in(i));
    end
    %last segment, wrap around
    edgeSum = edgeSum + (x_in(1)-x_in(i))*(y_in(1)+y_in(i));

    if sign(edgeSum) == -1 %poly is ccw, flip order
        x_out  = flip(x_in);
        y_out  = flip(y_in);
    else %poly was cw already
        x_out  = x_in;
        y_out  = y_in;
    end

end

