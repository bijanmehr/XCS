clc; clear; close all;
[~,txt,raw] = xlsread('C:\Users\BMH\matlab prjs\xcs\dt.xlsx');
%% turn real value to int

buying_price = zeros(1699,1);
for i=1:1699
    if strcmp(cell2mat(raw(i,1)),'vhigh')== 1
        buying_price(i,1) = 4;
    end
    if strcmp(cell2mat(raw(i,1)),'high')== 1
        buying_price(i,1) = 3;
    end
    if strcmp(cell2mat(raw(i,1)),'med')== 1
        buying_price(i,1) = 2;
    end
    if strcmp(cell2mat(raw(i,1)),'low')== 1
        buying_price(i,1) = 1;
    end
end


cost_maintanance = zeros(1699,1);
for i=1:1699
    if strcmp(cell2mat(raw(i,2)),'vhigh')== 1
        cost_maintanance(i,1) = 4;
    end
    if strcmp(cell2mat(raw(i,2)),'high')== 1
        cost_maintanance(i,1) = 3;
    end
    if strcmp(cell2mat(raw(i,2)),'med')== 1
        cost_maintanance(i,1) = 2;
    end
    if strcmp(cell2mat(raw(i,2)),'low')== 1
        cost_maintanance(i,1) = 1;
    end
end


num_door = zeros(1699,1);
for i=1:1699
    if cell2mat(raw(i,3)) == 2
        num_door(i,1) = 1;
    end
    if cell2mat(raw(i,3)) == 3
        num_door(i,1) = 2;
    end
    if cell2mat(raw(i,3)) == 4
        num_door(i,1) = 3;
    end
    if strcmp(cell2mat(raw(i,3)),'5more')== 1
        num_door(i,1) = 4;
    end
end


pas_cap = zeros(1699,1);
for i=1:1699
    if cell2mat(raw(i,4)) == 2
        pas_cap(i,1) = 1;
    end
    if cell2mat(raw(i,4)) == 4
        pas_cap(i,1) = 2;
    end
    if strcmp(cell2mat(raw(i,4)),'more')== 1
        pas_cap(i,1) = 3;
    end
end


lug_cap = zeros(1699,1);
for i=1:1699
    if strcmp(cell2mat(raw(i,5)),'small')== 1
        lug_cap(i,1) = 1;
    end
    if strcmp(cell2mat(raw(i,5)),'med')== 1
        lug_cap(i,1) = 2;
    end
    if strcmp(cell2mat(raw(i,5)),'big')== 1
        lug_cap(i,1) = 3;
    end
end


safty = zeros(1699,1);
for i=1:1699
    if strcmp(cell2mat(raw(i,6)),'high')== 1
        safty(i,1) = 3;
    end
    if strcmp(cell2mat(raw(i,6)),'med')== 1
        safty(i,1) = 2;
    end
    if strcmp(cell2mat(raw(i,6)),'low')== 1
        safty(i,1) = 1;
    end
end


quality = zeros(1699,1);
for i=1:1699
    if strcmp(cell2mat(raw(i,7)),'vgood')== 1
        quality(i,1) = 4;
    end
    if strcmp(cell2mat(raw(i,7)),'good')== 1
        quality(i,1) = 3;
    end
    if strcmp(cell2mat(raw(i,7)),'acc')== 1
        quality(i,1) = 2;
    end
    if strcmp(cell2mat(raw(i,7)),'unacc')== 1
        quality(i,1) = 1;
    end
end

%% separate test and train datas
index = ones(1699,1);
for i = 1:1699
    index(i,:) = i;
end
data_set = cat(2,index,buying_price,cost_maintanance,num_door,pas_cap,lug_cap,safty,quality);
data_set = data_set(randperm(size(data_set,1)),:);

[test_set,idx] = datasample(data_set,170,'Replace',false);
mask = ones(1699, 1);
mask(idx) = 0;
train_set = data_set(mask~=0, :);

%% general parameters

Asmin = 2;
gamma = 5;
ep0 = 2.5;

%% GA parameters

T_ga = 23;

%% generate classifier

pop = zeros(500,11); %population+fitness
for i =1:500
    pop(i,1) = i; %row number
    pop(i,2:8) = CG;
    pop(i,9) = .05; %initial fitness
    pop(i,10) = 4*ep0; %initial epsilon
    pop(i,11) = 0; %Xp
    pop(i,12) = randi([0 20],1,1); %prediction
end

%% Match set
q =1;
flag = 1;
num = 0;
validity = 0;
stop_criterion = 0;
if q<250
    beta = .6;
elseif q<400 && q>=250
    beta = .5;
elseif q<600 && q>=400
    beta = .4;
elseif q<800 && q>=600
    beta = .2;
else
    beta = .1;
end
tic;
while stop_criterion < 90
    
    for i = 1:length(train_set)
        match_set(i).x = [];
        for j = 1:500
            r = pop(j,:);
            c = (r(2:7)==train_set(i,2:7));
            f = find(c==0);
            if all(r(f) == 3*ones(1,length(f))) || isempty(f)
                match_set(i).x = [match_set(i).x;r];
            end
        end
    end
    
    for z = 1:length(train_set)
        match = cell2mat(struct2cell(match_set(z)));
        if isempty(match) ~= 0
            chk(z,1) = 1;
        else
            chk(z,1) = 0;
        end
        flag = chk(chk==0);
    end
    
    good_pop_id = zeros(5000,1);
    for i=1:length(match_set)
        match = cell2mat(struct2cell(match_set(i)));
        while size(match,1) ~= 0
            for j = 0:size(match,1)-1
                good_pop_id(i,:) = match(j+1,1);
            end
            break;
        end
    end
    
    good_pop_id = unique(sort(good_pop_id(good_pop_id~=0)));
    
    for i=1:length(match_set)
        match = cell2mat(struct2cell(match_set(i)));
        while size(match,1) == 0
            subpop = train_set(i,2:end);
            subpop(:,randi([1 6],1,1)) = -1;
            subpop(:,randi([1 6],1,1)) = -1;
            subpop(:,7) = randi([1 4],1,1);
            subpop(:,8) = .05; %initial fitness
            subpop(:,9) = 4*ep0; %initial epsilon
            subpop(:,10) = 0; %Xp
            subpop(:,11) = randi([0 20],1,1);
            
            rnd = randi([1 500],1,1);
            while ismember(rnd,good_pop_id) == 1
                rnd = randi([1 500],1,1);
            end
            pop(rnd,2:end) = subpop;
            num = num +1;
            break;
        end
        
        if size(match,1) ~= 0
            action_part = match(:,8);
            if size(unique(action_part),1) < Asmin
                covered_match = match(1,2:end);
                covered_match(:,randi([1 6],1,1)) = -1;
                rnd = randi([1 4],1,1);
                while ismember(rnd,unique(action_part)) == 1
                    rnd = randi([1 4],1,1);
                end
                covered_match(:,7) = rnd;
                rnd = randi([1 500],1,1);
                while ismember(rnd,good_pop_id) == 1
                    rnd = randi([1 500],1,1);
                end
                pop(rnd,2:end) = covered_match;
                num = num +1;
            end
        end
    end
    
    
    %% apply payoff
    u = 1;
    for i=1:length(match_set)
        payoff = cell2mat(struct2cell(match_set(i)));
        if size(payoff,1) ~= 0
            choice_idx = ceil(rand*size(payoff,1));
            choice = payoff(choice_idx,:);
            reward = randi([0 20],1,1);
            counter = 1;
            ksum = 0;
            while counter ~= size(payoff,1)+1
                ksum = kcalc(payoff(counter,10),beta) + ksum;
                counter=counter+1;
            end
            
            [avlb, id]=ismember(choice,pop,'row');
            if avlb ~= 0
                if choice(:,8) == train_set(i,8)
                    update = updater(choice(1,11),choice(1,10),choice(1,12),reward,beta);
                    newfit = fit_up(choice(1,9),update(:,4),ksum,beta);
                    newpop = pop(id,:);
                    newpop(1,9) = newfit;
                    newpop(1,10) = update(1,2);
                    newpop(1,11) = update(1,1);
                    newpop(1,12) = update(1,3);
                    pop(id,:) = newpop;
                else
                    reward = 0;
                    update = updater(choice(1,11),choice(1,10),choice(1,12),reward,beta);
                    newfit = fit_up(choice(1,9),update(:,4),ksum,beta);
                    newpop = pop(id,:);
                    newpop(1,9) = newfit;
                    newpop(1,10) = update(1,2);
                    newpop(1,11) = update(1,1);
                    newpop(1,12) = update(1,3);
                    pop(id,:) = newpop;
                end
            end
            u = u+1;
            %apply GA
            if mod(u,T_ga) == 0
                pop = sortrows(pop,9,'descend');
                child = GNA(pop(1,:),pop(2,:));
                pop(500,2:8) = child(1,1);
                pop(500,12) = (pop(1,12)+pop(2,12))/2;
                pop(500,10) = (pop(1,10)+pop(2,10))/2;
                pop(500,9) = (pop(1,9)+pop(2,9))/2;
                pop(499,2:8) = child(1,2);
                pop(499,12) = (pop(1,12)+pop(2,12))/2;
                pop(499,10) = (pop(1,10)+pop(2,10))/2;
                pop(499,9) = (pop(1,9)+pop(2,9))/2;
                pop;
                num = num +2;
            end
            
        end
    end
    
    
    %% apply test
    
    for i = 1:170
        test(i).o = [];
        for j = 1:500
            r = pop(j,:);
            c = (r(2:7)== test_set(i,2:7));
            f = find(c==0);
            if all(r(f) == 3*ones(1,length(f))) || isempty(f)
                test(i).o = [test(i).o;r];
            end
        end
    end
    
    for h = 1:length(test)
        result = cell2mat(struct2cell(test(i)));
        if size(result,1) ~= 0
            result = result(:,8);
            if ismember(test_set(h,8),result,'row')
                validity(h,1) = 1;
            else
                validity(h,1) = 0;
            end
        end
    end
    
    
    val_index = validity(validity==1);
    stop_criterion(q,1) = (size(val_index,1)/170)*100
    
%     emptyIndex = find(arrayfun(@(test) isempty(test.o),test));
%     stop_criterion(q,:) = ((170 - size(emptyIndex,2))/170)*100
    Rule_num(q,:) = num;
    maxfit(q,:) = max(pop(:,9));
    avgfit(q,:) = mean(pop(:,9));
    num = 0;
    q=q+1
    toc;
end
toc;

%% plots
plot(stop_criterion);
title('Stop Criterion');
figure;
plot(Rule_num);
title('Generated Classifiers');
figure;
plot(maxfit);
hold on
plot(avgfit);
legend('Maximum fitness','average fitness');
hold off