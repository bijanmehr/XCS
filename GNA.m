function y = GNA(in1,in2)

R_cross = .7;
p_mut = .03;

temp1 = in1(:,2:8);
temp2 = in2(:,2:8);

cross = ceil(R_cross*7);
child11 = temp1(:,1:cross);
child12 = temp2(:,cross+1:end);
child21 = temp1(:,cross+1:end);
child22 = temp2(:,1:cross);
child1 = cat(2,child11,child12);
child2 = cat(2,child21,child22);
y = [child1 child2];
    
    if rand <= p_mut
    id = ceil(rand*(length(child1)));
        if id ~= 4 && id ~= 5 && id ~= 6 && id ~= 7
            child1(:,id) = toggle(5);
            child2(:,id) = toggle(5);
        elseif id == 1 && id == 2 && id == 3 && id ~= 7
            child1(:,id) = toggle(4);
            child2(:,id) = toggle(4);
        else
            child1(:,id) = toggle(6);
            child2(:,id) = toggle(6);
        end
    y = [child1 child2];    
    end
end