clc; clear; close all;
tic;
[num,txt,raw] = xlsread('C:\Users\BMH\matlab prjs\xcs\dt.xlsx');
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

data = cat(2,buying_price,cost_maintanance,num_door,pas_cap,lug_cap,safty,quality);
data = data(randperm(size(data,1)),:);

[test,idx] = datasample(data,170,'Replace',false);
mask = ones(1699, 1);
mask(idx) = 0;
train = data(mask~=0, :);

%% general parameters

Asmin = 2;
% beta = .5;
gamma = 5;
ep0 = 2.5;

%% GA parameters

T_ga = 11;
toc;
%% generate classifier
tic;
pop = zeros(500,11); %population+fitness
for i =1:500
   pop(i,1:7) = CG;
   pop(i,8) = .05; %initial fitness
   pop(i,9) = 4*ep0; %initial epsilon
   pop(i,10) = 0; %Xp
   pop(i,11) = round(rand*20); %prediction
   pop(i,12) = 0; %usefullness
end 

%% Match set

train_set = train(:,1:6);
train_act = train(:,7);

ii = 1;
SC = 0;
elapsedTime = toc;

if ii<250
    beta = .8;
elseif ii<400 && ii>=250
    beta = .6;
elseif ii<600 && ii>=400
    beta = .4;
elseif ii<800 && ii>=600
    beta = .2;  
else
    beta = .1;
end

num = 0;
while SC < 70
% while ii ~= 10
    tic;
for i = 1:1529
    index(i).s = [];
        for j = 1:500
            r = pop(j,:);
            c = (r(1:6)==train_set(i,1:6));
            f = find(c==0);
                if all(r(f) == 3*ones(1,length(f))) || isempty(f)
                    index(i).s = [index(i).s;r];
                end
        end
end

%% action set
for i = 1:1529
    temp = cell2mat(struct2cell(index(i)));
%     [a,~] = size(temp);
    while size(temp,1) == 0
        train_tmp_1 = train(i,:);
        train_tmp_1(1,ceil(rand*6)) = -1;
        train_tmp_1(1,7) = ceil(rand*4);
        train_tmp_1(1,8) = .05; %initial fitness
        train_tmp_1(1,9) = 4*ep0; %initial epsilon
        train_tmp_1(1,10) = 0; %Xp
        train_tmp_1(1,11) = round(rand*20);
        train_tmp_1(1,12) = 0;
        
        train_tmp_2 = train_tmp_1;
        train_tmp_2(1,ceil(rand*6)) = -1;
        rdm = ceil(rand*4);
                while  rdm ~= train_tmp_1(1,7)
                     train_tmp_2(1,7) = rdm;
                     break
                end
        train_tmp(1,:) = train_tmp_1;
        train_tmp(2,:) = train_tmp_2;
        num = num + 2;
        index(i).s = train_tmp;
        
        rnid = ceil(rand*500);
        pop(rnid,:) = train_tmp_1;
        rnid = ceil(rand*500);
        pop(rnid,:) = train_tmp_2;
        break
    end

    temp = cell2mat(struct2cell(index(i)));
    [a,~] = size(temp);
    
    for j = 1:size(temp,1)
       sim = zeros(a,1);
       sim(j,1) = temp(j,7);
       if size(unique(sim)) < Asmin
           if size(unique(sim)) == 1
               temp(1,ceil(rand*6)) = -1;
               rdm = ceil(rand*4);
                while  rdm == temp(1,7)
                    rdm = ceil(rand*4);
                end
                    temp(1,7) = rdm;
                    rnid = ceil(rand*500);
                    pop(rnid,:) = temp;
                    rep = index(i).s;
                    index(i).s = cat(1,temp,rep);
                    num = num +1;
           end
       end
    end
end

%% applying payoff
q = 1;
for i = 1:1529
    temp = cell2mat(struct2cell(index(i)));
    [a,~] = size(temp);
    mat = temp;
    choice_idx = ceil(rand*a);
    choice = mat(choice_idx,:);
    reward = round(rand*20);
    z = 1;
    ksum = 0;
    while z ~= a+1
        ksum = kcalc(mat(z,9),beta) + ksum;
        z=z+1;
    end
    [chk, id]=ismember(choice,pop,'row');
    if chk ~= 0
        if choice(:,7) == train(i,7)
            update = updater(choice(1,10),choice(1,9),choice(1,11),reward,beta);
            newfit = fit_up(choice(1,8),update(:,4),ksum,beta);
            newpop = pop(id,:);
            newpop(1,8) = newfit;
            newpop(1,9) = update(1,2);
            newpop(1,10) = update(1,1);
            newpop(1,11) = update(1,3);
            pop(id,:) = newpop;
        else
            reward = 0;
            update = updater(choice(1,10),choice(1,9),choice(1,11),reward,beta);
            newfit = fit_up(choice(1,8),update(:,4),ksum,beta);
            newpop = pop(id,:);
            newpop(1,8) = newfit;
            newpop(1,9) = update(1,2);
            newpop(1,10) = update(1,1);
            newpop(1,11) = update(1,3);
            pop(id,:) = newpop;
        end
    end
    q = q+1;
    %apply GA
    if mod(q,T_ga) == 0
        pop = sortrows(pop,8,'descend');
        child = GNA(pop(1,:),pop(2,:));
        pop(500,1:7) = child;
        pop(500,11) = (pop(1,11)+pop(2,11))/2;
        pop(500,9) = (pop(1,9)+pop(2,9))/2;
        pop(500,8) = (pop(1,8)+pop(2,8))/2;
        num = num +1;
    end
end

% end
%% apply test

for i = 1:170
    tst(i).o = [];
        for j = 1:500
            r = pop(j,:);
            t = test(i,1:6);
            c = (r(1:6)== t);
            f = find(c==0);
                if all(r(f) == 3*ones(1,length(f))) || isempty(f)
                    tst(i).o = [tst(i).o;r];
                end
        end
end

emptyIndex = find(arrayfun(@(tst) isempty(tst.o),tst));
SC(ii,:) = ((170 - size(emptyIndex,2))/170)*100
Rule_num(ii,:) = num;
maxfit(ii,:) = max(pop(:,8));
avgfit(ii,:) = mean(pop(:,8));
num = 0;
ii = ii +1
elapsedTime = toc + elapsedTime
end

%% plots
plot(SC);
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
toc;