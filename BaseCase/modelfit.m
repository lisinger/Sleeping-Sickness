function[] = modelfit()


    x0 = 2.515;
    f = @(x)abs(runHATmodel(x) - 0.9)
    [xopt,fopt] = fminsearch(f ,x0)



    t = linspace(2.1,2.8,20)
    i = 1;
    for x = t
        out = runHATmodel(x)
        err1(i) = abs(out-0.9)
        err2(i) = (out-0.9)^.2
        i = i+1
    end

















% function[out] = error_func(x)
% out = abs(runHATmodel(x) - 0.9)
% end
