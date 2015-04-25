function[fhold]=fhold(xpart)
% A first order interpolation type method to estimate envelope of a
% vector of length 22050

f=11025; %frame length
n=25; % number of sub-frames
s=f/n;
fhold=zeros(f,1);
for i=1:n
    high=max(xpart((i-1)*s+1:i*s));
    if i==1
        for j=1:s
            fhold(j,1)=high;
        end
    end
    if i~=1
        for j=1:s
            x_init=fhold((i-1)*s);
            x_final=high;
            slope=(x_final-x_init)/s;
            fhold((i-1)*s+j,1)=(j-1)*slope + x_init;
        end
    end
end

end