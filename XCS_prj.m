clc; clear; close all;

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
beta = .1;
gamma = 5;
% ep0 = .01;

%% generate classifier

pop = zeros(500,11); %population+fitness
for i =1:500
   pop(i,1:7) = CG;
   pop(i,8) = .05; %initial fitness
   pop(i,9) = .01; %initial epsilon
   pop(i,10) = 0; %Xp
   pop(i,11) = round(rand*20); %prediction
end 

%% update classifier parameters

% if i=1:500
%    xp(i+1) = xp(i) 
% end

%% Match set

train_set = train(:,1:6);
train_act = train(:,7);

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
    [a,b] = size(temp);
    for j = 1:a
       sim = zeros(a,1);
       sim(j,1) = temp(j,7);
       while size(unique(sim)) < Asmin
           if size(unique(sim)) == 0
               train_tmp = train(i,:);
               rnd = round(rand*6);
               while rnd ~= 0
                train_tmp(1,rnd) = -1;
               end
                train_tmp(1,7) = round(rand*4);
               rnd = round(rand*500);
               while rnd ~= 0
                pop(rnd,1:7) = train_tmp;
               end
           else
               rnd = round(rand*6);
               while rnd ~= 0
               temp(1,rnd) = -1;
               break
               end
               rdm = ceil(rand*4);
                while  rdm ~= temp(1,7)
                     temp(1,7) = rdm;
                end
                rnd = round(rand*500);
                while rnd ~= 0
                     pop(rnd,1:7) = temp(1,1:7);
                end
%                 break
           end
%             break
       end
%        break
    end
   while  a ~= 0
   choice_idx = ceil(rand*a);
%    while choice_idx ~= 0
      choice = temp(choice_idx,:);
%    end
   if choice(1,7) == train(i,7)
       reward = round(rand*20);
       tst = updater(choice(1,10),choice(1,9),choice(1,11),reward);
       z=0;
       ksum = 0;
       while z == a
            kk = kcalc(temp(a,9));
            ksum = ksum + kk;
       end
   end
   end
%    break
end

%% applying payoff