
function [ten,sig_energy]=getenergy(data,fs,framelen)
% function calculates energy in a frame of 10ms
% assuming this amout of accuracy is necessary to identify attack points
% framelen should be in ms and no overlap in code

frame = floor(framelen/1000 * fs);
nframe=floor(length(data)/frame);
for i=1:nframe
    ten(i)=floor((i-0.5)*frame)/fs;
    x=data((i-1)*frame+1:i*frame);
    sig_energy(i)=sum(x.^2);
end
