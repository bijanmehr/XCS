function y = kcalc(ep,beta)

ep0 = 2.5;
% beta = .5;
gamma = 5;

    if ep < ep0
        k = 1;
    else
        k = (beta*(ep/ep0))^(-1*gamma);
    end

    y = k;

end