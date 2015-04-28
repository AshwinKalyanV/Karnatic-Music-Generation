clear all; close all;
for datj = 5 % iterate over files

% load audio
dat_root = 'D:\SPer\ISMIR - music paper\ismir_data\';
dat_file = strcat('dat',num2str(datj),'.wav');
% load ground truth
ftdat = load(strcat(dat_root,'ftdat',num2str(datj),'.mat'));
ftdata = eval(strcat('ftdat.','ftdata',num2str(datj)));
actualtempo = eval(strcat('ftdat.','actualtempo'));

% generate tempos to evaluate on
% 20% to 200% of actual tempo
incrtempo = 20:20:200;
test_tempo = incrtempo/100*actualtempo;

meansqer = []; flag = []; nwrong = []; trgdata = []; precision = [];
tempthresh = 0.1*actualtempo;

for tt=1:length(incrtempo) 
fprintf('starting iteration for tempo: \t %d  \n', incrtempo(tt));
    t = test_tempo(tt);
    [ap,ft]= km_getattack(strcat(dat_root,dat_file), t);
    %close all;
   
    ap1 = ap(:,1);
    j = 1:length(ft);
    ftcomp = zeros(length(ftdata),1);

    for i=1:length(ftdata);
        samp = ft((ft(j)>(ftdata(i)-tempthresh))&(ft(j)<(ftdata(i)+tempthresh)));
        s = 1:length(samp);
        
        if ~isempty(samp)
            jnew = zeros(length(samp),1);
            ap1new = zeros(length(samp),1);
            for sp=1:length(samp)
                jnew(sp) = j(ft(j)==samp(sp));
                ap1new(sp) = ap1(jnew(sp));
            end
            s = s(ap1new(s)==min(ap1new));
            ftcomp(i) = samp(s);
        else
            % extend range to twice the threshold
            samp = ft((ft(j)>(ftdata(i)-4*tempthresh))&(ft(j)<(ftdata(i)+4*tempthresh)));
            s = 1:length(samp);
            if ~isempty(samp)
                jnew = zeros(length(samp),1);
                ap1new = zeros(length(samp),1);
                for sp=1:length(samp)
                    jnew(sp) = j(ft(j)==samp(sp));
                    ap1new(sp) = ap1(jnew(sp));
                end
                s = s(ap1new(s)==min(ap1new));
                ftcomp(i) = samp(s);
            else
                ftcomp(i) = NaN;
            end
        end
    end
    
    clear jnew ap1new

check = zeros(length(ft),1);           %identifying the correct points (assigning each point a 1/0)
for j=1:length(ft)
    for i=1:length(ftdata)
        if(ft(j)==ftcomp(i))
            check(j) = 1;
            break;
        end
    end
end    
trgdata = [trgdata; ft ap check];      %generating training data by adding the new label

Nc = sum(~isnan(ftcomp));              %number of correct points  

if sum(isnan(ftcomp)) == 0
    flag = [flag 1];
else
    flag = [flag 0];
end

ftdiff = ftcomp-ftdata';
ftdiff = ftdiff.^2;
meansqer= [ meansqer nanmean(ftdiff)];
nwrong = [nwrong sum(isnan(ftcomp))];
precision = [precision (Nc/length(ft))];

end 

%save(strcat('workspace', num2str(i)));                      %saving the workspace
%csvwrite(strcat('trgdata', num2str(i)), trgdata);          %writing training data to a csv file

%integrating with meanplot

figure,plot(incrtempo,meansqer,'k'); xlabel('percentage of actual tempo'); ylabel('Mean Square Error');

hold on
for i = 1:length(flag)
    if flag(i) == 1
        plot(incrtempo(i),meansqer(i),'*');
        hold on;
    else
        plot(incrtempo(i),meansqer(i),'*r'); 
    end
end
figure,plot(incrtempo,1-(nwrong/length(ftdata)),'-*r'); 
hold on;
plot(incrtempo,precision,'-+b');
xlabel('percentage of actual tempo'); ylabel('ratio'); 
legend('accuracy','precision');
end