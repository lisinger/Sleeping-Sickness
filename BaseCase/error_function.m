function[out] =  error_function(x)

% Data:
d = 0.3;
mo = runHATmodel(x);
out = abs(d-mo)

end