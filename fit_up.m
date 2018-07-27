function y = fit_up(fit,k,ksum,beta)
%     beta = .5;
    y = fit + beta*((k/ksum)-fit);
end