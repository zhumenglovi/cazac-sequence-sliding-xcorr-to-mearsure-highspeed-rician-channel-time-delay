%% 莱斯（Rician）分布的多径衰落信道仿真
% 使用Rician多径衰减信道模型，以及其内嵌可视化模型。
% 对于仿真实际无线通信场景，Rician衰减信道模型是非常有用的衰减现象。
% 它们包括多径散射效应，时间弥散，相对运动引起的多普勒频移等现象。

% 使用衰减信号模型来处理信号包括以下几步：
% 1.创建一个通道系统对象.
% 2.调整路径延迟或平均路径增益。

%% 初始化initialization
%以下变量控制Rician通道对象。 
%该信道被建模为3个衰落路径，
%每个衰落路径代表一组以大约相同的延迟接收的多径分量。

% 初始化，3条多径，每条频移和时间延迟
sampleRate800KHz=1e8;             % 采样率
maxDopplerShift=50e3;               % 散射分量的最大多普勒频移
delayVector = [5e-7 7.5e-7 2e-6];   % 3路径通道的离散延迟(s)
%delayVector = [1e-6 5e-6 8e-6];
gainVector  = [0 -3 -6];            % 平均路径增益(dB)

%% 莱斯因子设定
% 以下变量控制Rician Channel System对象。 
% 镜面反射分量的多普勒频移通常小于最大多普勒偏移（上方），
% 并且取决于移动台相对于镜面反射分量的行进方向。 
% K因子指定了来自镜面反射分量的平均接收功率相对于关联的漫反射分量的线性比例。

KFactor = 10;            %镜面功率与扩散功率的线性比

specDopplerShift = 100;  % 镜面反射分量的多普勒频移 (Hz)

%% 创建Rician信道
% 莱斯信道
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

%cazac序列
signal_length=100;
cazac_seq = cazac_creat(signal_length).';%写成列向量用.' (不能用’，因为’是取共轭转置)

%周期循环的cazac序列
%周期设为100，循环100次
cazac_100=repmat(cazac_seq,10000,1);

% 在调制数据上应用Rician通道对象
ricChan(cazac_100);
r=ricChan(cazac_100);
%% 可视化
% 衰落信道系统对象具有内置的可视化效果，可显示| step |中的信道脉冲响应，频率响应或多普勒频谱。
% 方法
% 要调用它，请设置| Visualization |。 
% 属性在调用| step |之前达到其所需的值 
% 方法
% 现在释放Rician通道系统对象，以便我们可以更改它们的属性值。
%  release(ricChan);

%  ricChan.Visualization = 'Impulse and frequency responses'; 

%  ricChan.SampleRate = sampleRate800KHz; 

%  ricChan.SamplesToDisplay = '100%';  % 展示

% numFrames = 1;
%  for i = 1:numFrames % 显示脉冲和频率响应2帧
%     s =cazac_seq ; 
%     ricChan(s); 
%  end

%% 显示通过莱斯信道后的cazac序列
n_100=1:1:1000000;
figure(1)
plot(n_100,ricChan(cazac_100));
xlabel('序列长度');
ylabel('序列幅度');
title('通过莱斯信道后的cazac序列图');

%% 通过莱斯信道后的cazac序列加噪声
cazac_rician_noise=awgn(ricChan(cazac_100),10);
figure(2)
plot(n_100,cazac_rician_noise);
xlabel('序列长度');
ylabel('序列幅度');
title('加噪图');

%% 显示通过信道后的cazac序列的频谱
cazac_rician_fft=fft(cazac_rician_noise);
n_100=1:1:1000000;
figure(3)
plot(n_100,cazac_rician_fft);
xlabel('频率');
ylabel('幅度');
title('通过莱斯信道后的cazac序列频谱图');

%% 产生本地cazac信号
cazac_local=cazac_creat(100);%产生长度为100的本地cazac信号

%% 本地信号与接收信号做互相关 
xcorr_c_r_c=xcorr(ricChan(cazac_100),cazac_local);
n_100=1:1:1999999;
figure(4)
plot(n_100,xcorr_c_r_c);
xlabel('相关');
ylabel('幅度');
title('相关图');
%信道相关后包络图
hh=xcorr_c_r_c(ceil(length(xcorr_c_r_c)/2):end);%ceil函数：朝正无穷大方向取整
[C,I]=max(abs(hh(1:signal_length)));%取最大值
h=hh(I:signal_length:end);
figure(5)
plot(abs(h));
xlabel('相关数值');
ylabel('max幅值');
title('相关幅值图');
figure(6)
plot(angle(h))
xlabel('相关数值');
ylabel('角度值');
title('相关角度图');
%信道相关后的结果
figure(7)
a=(abs(xcorr_c_r_c(ceil(length(xcorr_c_r_c)/2):end)));%幅值（取相关值的整数（从相关值的1/2到最后一个值））
t=(0:1:length(a)-1)/1e8;%x值时间值（采样点）
plot(t,abs(a));
xlabel('时间/s');
ylabel('幅度');
title('相关图');