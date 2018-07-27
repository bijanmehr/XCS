function  y = toggle(x)

if x == 4
    t = ceil(rand*4);
    temp = [1 2 3 -1];
    y = temp(:,t);
elseif x == 5
    t =ceil(rand*5) ;
    temp = [1 2 3 4 -1];
    y = temp(:,t);
else %for x == 6 for action part
    t = ceil(rand*4);
    temp = [1 2 3 4];
    y = temp(:,t);
end

end