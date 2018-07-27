function y = updater(xp,ep,pre,rew,beta)
    
%     beta = .5;
    

    xp = xp + 1;
    if xp < 1/beta
        pre = pre + (rew - pre)/xp;
        ep = ep +(abs(rew - pre) - ep)/xp;
    else
       pre = pre + beta*(rew - pre);
       ep = ep + beta*(abs(rew - pre) - ep);
    end
        
    k = kcalc(ep,beta);
    
y = [xp,ep,pre,k];

end