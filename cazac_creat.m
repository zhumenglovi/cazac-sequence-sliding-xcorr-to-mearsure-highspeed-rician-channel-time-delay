function [ cazac_seq ] = cazac_creat( signal_length )
%cazac_creat ����cazac����
%   signal_length:����cazac�źų���
%   cazac_seq:���ɵ�cazac����
k=signal_length-1;
n=1:signal_length;
if mod(signal_length,2)==0
    cazac_seq=exp(1i*pi*2*k/signal_length*(n+n.*n/2));
else
    cazac_seq=exp(1i*pi*2*k/signal_length*(n.*(n+1)/2+n));
end
end

