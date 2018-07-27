function y = CG(~)

    a1 = RG(5);
    a2 = RG(5);
    a3 = RG(5);
    a4 = RG(4);
    a5 = RG(4);
    a6 = RG(4);
    
    if round(rand*100) < 25
        a7 = 1;
    elseif round(rand*100) < 50 && round(rand*100) >= 25
        a7 = 2;
    elseif round(rand*100) < 75 && round(rand*100) >= 50
        a7 = 3;
    else
        a7 = 4;
    end

    y = [a1,a2,a3,a4,a5,a6,a7];
end