function [features, attack_points] = km_getattack(pathwav,tempo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to detect attack points in a audio of karnatic music
% Author: Ashwin Kalyan V

% inputs:
% pathwav - path to audio .wav file
% tempo - approximate value of the tempo of the song in seconds
% sa - the tonic of the song in Hz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ischar(pathwav)
    [xdat,fs] = wavread(pathwav);
    %t = (1:length(xdat))/fs;
else
    display('Error: Enter path to wav file')
end

% tempo parameter in terms of samples
sample_tempo = tempo*fs;

% fetch amplitude envelope
envs=env_gen(xdat);
tenv = (1:length(envs))/fs;

% wavelet transform the envelope signal
% division by 4 is random - assuming attack takes 25% of the time! 
wavs = cwt(envs,sample_tempo/4,'rbio 4.4');

en_frame = 10;
[ten,sigen]=getenergy(xdat,fs,en_frame);

% get wavelet transform of the obtained energy
% set wavelet scale correspoding to number of frames 
% making 1 note. generally: sample_tempo/2000 + delta!!
wavscl=sample_tempo/2000;
waven = cwt(sigen,wavscl,'rbio 4.4');

% amplitude based features
% find peaks in the envelope
[wavpks, wavlocs]= findpeaks(-wavs,'minpeakdistance',floor(sample_tempo/4),'minpeakheight',0);
figure,plot(tenv,wavs); hold on; plot(wavlocs/fs,-wavpks,'*r');

amppks = envs(wavlocs);
figure,plot(tenv,envs); hold on; plot(wavlocs/fs,amppks,'*r');

% find energy based features
[wavenpks, wavenlocs]= findpeaks(-waven, 'minpeakdistance',floor(wavscl),'minpeakheight',0);
figure,plot(ten,waven); hold on; plot(wavenlocs/100,-wavenpks,'*r');

enpks = sigen(wavenlocs);
figure,plot(ten,sigen); hold on; plot(wavenlocs/100, enpks, '*r');

features = []; attack_points = [];
% put both the features together
epsilon = 50/1000; % in ms
for i = 1:length(wavlocs)
    [val,idx]= min(abs(wavenlocs/100 - wavlocs(i)/fs));
    if abs(val) < epsilon
        features = [features; [amppks(i) -wavpks(i) enpks(idx) -wavenpks(idx)] ];
        attack_points = [ attack_points ; wavlocs(i)/fs ];
    end
end





