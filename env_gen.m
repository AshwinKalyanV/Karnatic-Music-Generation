function[env_full]=env_gen(xs)
% Returns envelope of the data with avergaing of sub-frames.
% Control length of sub-frame in fhold function.

f=11025; %frame length

length=size(xs);
length=length(1,1);

for i=0:f-1
    if rem(length+i,f)==0
        zeropad=i;
    end
end

xs=[xs' zeros(1,zeropad)];
xs=xs';
len=length+zeropad;
env_full=zeros(len,1);
n=len/f;

for i=1:n
    xpart=xs((i-1)*f+1:i*f);
    env_full((i-1)*f+1:i*f)=fhold(xpart);
end

end