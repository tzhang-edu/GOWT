% Time Series Trend Detection Tests
% [ z, sl, lcl, ucl ] = trend( y, dt )
% where z = Mann-Kendall Statistic
% sl = Sen's Slope Estimate
% lcl = Lower Confidence Limit of sl
% ucl = Upper Confidence Limit of sl
% y = Time Series of Data
% dt = Time Interval of Data
function [ z, sl, lcl, ucl ] = mk( y )
n = length( y );
dt=1;

% calculate statistic
s = 0;
for k = 1:n-1,
    for j = k+1:n,
        s = s + sign( y(j) - y(k) );
    end;
end;

% variance ( assuming no tied groups )
v = ( n * ( n - 1 ) * ( 2 * n + 5 ) ) / 18;

% test statistic
if s == 0,
    z = 0;
elseif s > 0,
    z = ( s - 1 ) / sqrt( v );
else
    z = ( s + 1 ) / sqrt( v );
end;

% should calculate Normal value here
nor = 1.96;
% results
disp( [ ' n = ' num2str( n ) ] );
disp( [ ' Mean Value = ' num2str( mean( y ) ) ] );
disp( [ ' Z statistic = ' num2str( z ) ] );
if abs( z ) < nor,
    disp( ' No significant trend' );
    z = 0;
elseif z > 0,
    disp( ' Upward trend detected' );
else
    disp( ' Downward trend detected' );
end;
disp( 'Sens Nonparametric Estimator:' );

% calculate slopes
ndash = n * ( n - 1 ) / 2;
s = zeros( ndash, 1 );
i = 1;
for k = 1:n-1,
    for j = k+1:n,
        s(i) = ( y(j) - y(k) ) / ( j - k ) / dt;
        i = i + 1;
    end;
end;

% the estimate
sl = median( s );
disp( [ ' Slope Estimate = ' num2str( sl ) ] );
% variance ( assuming no tied groups )
v = ( n * ( n - 1 ) * ( 2 * n + 5 ) ) / 18;
m1 = fix( ( ndash - nor * sqrt( v ) ) / 2 );
m2 = fix( ( ndash + nor * sqrt( v ) ) / 2 );
s = sort( s );
lcl = s( m1 );
ucl = s( m2 + 1 );
disp( [ ' Lower Confidence Limit = ' ...
    num2str( lcl ) ] );
disp( [ ' Upper Confidence Limit = ' ...
    num2str( ucl ) ] );