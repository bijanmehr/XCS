function y = RG(x)

    if x == 4
        if round(rand*100) < 20
            y = 1;
        elseif round(rand*100) < 40 && round(rand*100) >= 20
            y = 2;
        elseif round(rand*100) < 60 && round(rand*100) >= 40
            y = 3;
        else
            y = -1;
        end
    end
    
    if x == 5
       if round(rand*100) < 17
          y = 1;
       elseif round(rand*100) < 34 && round(rand*100) >= 17
          y = 2;
       elseif round(rand*100) < 51 && round(rand*100) >= 34
           y = 3;
       elseif round(rand*100) < 68 && round(rand*100) >= 51
           y = 4;
       else
           y = -1;
       end
    end
end