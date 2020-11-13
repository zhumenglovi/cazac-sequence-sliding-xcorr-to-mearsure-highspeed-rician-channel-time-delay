%% ��˹��Rician���ֲ��Ķྶ˥���ŵ�����
% ʹ��Rician�ྶ˥���ŵ�ģ�ͣ��Լ�����Ƕ���ӻ�ģ�͡�
% ���ڷ���ʵ������ͨ�ų�����Rician˥���ŵ�ģ���Ƿǳ����õ�˥������
% ���ǰ����ྶɢ��ЧӦ��ʱ����ɢ������˶�����Ķ�����Ƶ�Ƶ�����

% ʹ��˥���ź�ģ���������źŰ������¼�����
% 1.����һ��ͨ��ϵͳ����.
% 2.����·���ӳٻ�ƽ��·�����档

%% ��ʼ��initialization
%���±�������Ricianͨ������ 
%���ŵ�����ģΪ3��˥��·����
%ÿ��˥��·������һ���Դ�Լ��ͬ���ӳٽ��յĶྶ������

% ��ʼ����3���ྶ��ÿ��Ƶ�ƺ�ʱ���ӳ�
sampleRate800KHz=1e8;             % ������
maxDopplerShift=50e3;               % ɢ���������������Ƶ��
delayVector = [5e-7 7.5e-7 2e-6];   % 3·��ͨ������ɢ�ӳ�(s)
%delayVector = [1e-6 5e-6 8e-6];
gainVector  = [0 -3 -6];            % ƽ��·������(dB)

%% ��˹�����趨
% ���±�������Rician Channel System���� 
% ���淴������Ķ�����Ƶ��ͨ��С����������ƫ�ƣ��Ϸ�����
% ����ȡ�����ƶ�̨����ھ��淴��������н����� 
% K����ָ�������Ծ��淴�������ƽ�����չ�������ڹ�������������������Ա�����

KFactor = 10;            %���湦������ɢ���ʵ����Ա�

specDopplerShift = 100;  % ���淴������Ķ�����Ƶ�� (Hz)

%% ����Rician�ŵ�
% ��˹�ŵ�
ricChan = comm.RicianChannel(...
    'SampleRate', sampleRate800KHz,...
    'PathDelays',delayVector,...
    'AveragePathGains',gainVector,...
    'KFactor',KFactor,...
    'DirectPathDopplerShift',specDopplerShift,...
    'MaximumDopplerShift',maxDopplerShift,...
    'RandomStream','mt19937ar with seed',...
    'Seed',100,...
    'PathGainsOutputPort',true);

%cazac����
signal_length=100;
cazac_seq = cazac_creat(signal_length).';%д����������.' (�����á�����Ϊ����ȡ����ת��)

%����ѭ����cazac����
%������Ϊ100��ѭ��100��
cazac_100=repmat(cazac_seq,10000,1);

% �ڵ���������Ӧ��Ricianͨ������
ricChan(cazac_100);
r=ricChan(cazac_100);
%% ���ӻ�
% ˥���ŵ�ϵͳ����������õĿ��ӻ�Ч��������ʾ| step |�е��ŵ�������Ӧ��Ƶ����Ӧ�������Ƶ�ס�
% ����
% Ҫ��������������| Visualization |�� 
% �����ڵ���| step |֮ǰ�ﵽ�������ֵ 
% ����
% �����ͷ�Ricianͨ��ϵͳ�����Ա����ǿ��Ը������ǵ�����ֵ��
%  release(ricChan);

%  ricChan.Visualization = 'Impulse and frequency responses'; 

%  ricChan.SampleRate = sampleRate800KHz; 

%  ricChan.SamplesToDisplay = '100%';  % չʾ

% numFrames = 1;
%  for i = 1:numFrames % ��ʾ�����Ƶ����Ӧ2֡
%     s =cazac_seq ; 
%     ricChan(s); 
%  end

%% ��ʾͨ����˹�ŵ����cazac����
n_100=1:1:1000000;
figure(1)
plot(n_100,ricChan(cazac_100));
xlabel('���г���');
ylabel('���з���');
title('ͨ����˹�ŵ����cazac����ͼ');

%% ͨ����˹�ŵ����cazac���м�����
cazac_rician_noise=awgn(ricChan(cazac_100),10);
figure(2)
plot(n_100,cazac_rician_noise);
xlabel('���г���');
ylabel('���з���');
title('����ͼ');

%% ��ʾͨ���ŵ����cazac���е�Ƶ��
cazac_rician_fft=fft(cazac_rician_noise);
n_100=1:1:1000000;
figure(3)
plot(n_100,cazac_rician_fft);
xlabel('Ƶ��');
ylabel('����');
title('ͨ����˹�ŵ����cazac����Ƶ��ͼ');

%% ��������cazac�ź�
cazac_local=cazac_creat(100);%��������Ϊ100�ı���cazac�ź�

%% �����ź�������ź�������� 
xcorr_c_r_c=xcorr(ricChan(cazac_100),cazac_local);
n_100=1:1:1999999;
figure(4)
plot(n_100,xcorr_c_r_c);
xlabel('���');
ylabel('����');
title('���ͼ');
%�ŵ���غ����ͼ
hh=xcorr_c_r_c(ceil(length(xcorr_c_r_c)/2):end);%ceil�����������������ȡ��
[C,I]=max(abs(hh(1:signal_length)));%ȡ���ֵ
h=hh(I:signal_length:end);
figure(5)
plot(abs(h));
xlabel('�����ֵ');
ylabel('max��ֵ');
title('��ط�ֵͼ');
figure(6)
plot(angle(h))
xlabel('�����ֵ');
ylabel('�Ƕ�ֵ');
title('��ؽǶ�ͼ');
%�ŵ���غ�Ľ��
figure(7)
a=(abs(xcorr_c_r_c(ceil(length(xcorr_c_r_c)/2):end)));%��ֵ��ȡ���ֵ�������������ֵ��1/2�����һ��ֵ����
t=(0:1:length(a)-1)/1e8;%xֵʱ��ֵ�������㣩
plot(t,abs(a));
xlabel('ʱ��/s');
ylabel('����');
title('���ͼ');