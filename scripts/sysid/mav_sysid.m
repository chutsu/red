clc;
clear all;
close all;

% Bag file 
bag_file_path = '/home/dimos/Desktop/tuning/ucl/thrust_1.bag';

bag = rosbag(bag_file_path);

% Data topics 
topic_imu      = '/mavros/imu/data';
topic_vicon    = '/vicon/aabm02/pose';
topic_setpoint = '/mavros/setpoint_raw/target_attitude';

% Read Vicon data 
msgs_vicon = readMessages(select(bag,'Topic',topic_vicon));

vicon.q = zeros(length(msgs_vicon),4); % Orientation quaternion
vicon.r = zeros(length(msgs_vicon),3); % Position
vicon.t = zeros(length(msgs_vicon),1); % Timestamps

for i=1:length(msgs_vicon)             % Todo -> avoid for loops 
   vicon.q(i,:) = quatnormalize([msgs_vicon{i}.Pose.Orientation.W,msgs_vicon{i}.Pose.Orientation.X,msgs_vicon{i}.Pose.Orientation.Y ...
       msgs_vicon{i}.Pose.Orientation.Z]);
   vicon.r(i,:) = [msgs_vicon{i}.Pose.Position.X,msgs_vicon{i}.Pose.Position.Y,msgs_vicon{i}.Pose.Position.Z];
   vicon.t(i) = seconds(msgs_vicon{i}.Header.Stamp);
end
% for i=1:length(msgs_vicon)             % Todo -> avoid for loops 
%    vicon.q(i,:) = quatnormalize([msgs_vicon{i}.Transform.Rotation.W,msgs_vicon{i}.Transform.Rotation.X,msgs_vicon{i}.Transform.Rotation.Y ...
%        msgs_vicon{i}.Transform.Rotation.Z]);
%    vicon.r(i,:) = [msgs_vicon{i}.Transform.Translation.X,msgs_vicon{i}.Transform.Translation.Y,msgs_vicon{i}.Transform.Translation.Z];
%    vicon.t(i) = seconds(msgs_vicon{i}.Header.Stamp);
% end
clear msgs_vicon;

% Read IMU data
msgs_IMU = readMessages(select(bag,'Topic',topic_imu));
imu.q = zeros(length(msgs_IMU),4); % Orientation quaternion
imu.t = zeros(length(msgs_IMU),1); % Timestamps
for i=1:length(msgs_IMU)           % Todo -> avoid for loops 
    imu.q(i,:) = quatnormalize([msgs_IMU{i}.Orientation.W, msgs_IMU{i}.Orientation.X, msgs_IMU{i}.Orientation.Y, msgs_IMU{i}.Orientation.Z]);
    imu.t(i) = seconds(msgs_IMU{i}.Header.Stamp);
end
clear msgs_IMU;

% Read Attitude Commands
msgs_ref = readMessages(select(bag,'Topic',topic_setpoint));
ref.q = zeros(length(msgs_ref),4);  % Reference Orientation
ref.Tr = zeros(length(msgs_ref),1); % Reference Thrust
ref.t = zeros(length(msgs_ref),1);  % Timestamps
for i=1:length(msgs_ref)            % Todo -> avoid for loops 
    ref.q(i,:) = quatnormalize([msgs_ref{i}.Orientation.W, msgs_ref{i}.Orientation.X, msgs_ref{i}.Orientation.Y, msgs_ref{i}.Orientation.Z]);
    ref.Tr(i) = msgs_ref{i}.Thrust;
    ref.t(i) = seconds(msgs_ref{i}.Header.Stamp);
end
clear msgs_ref;

% Crop data to avoid problems with interpolation later
t_min_ = max([vicon.t(1), imu.t(1), ref.t(1)]);
t_max_ = min([vicon.t(end), imu.t(end), ref.t(end)]);

vicon.q = vicon.q(vicon.t >= t_min_ & vicon.t <= t_max_,:);
vicon.r = vicon.r(vicon.t >= t_min_ & vicon.t <= t_max_,:);
vicon.t = vicon.t(vicon.t >= t_min_ & vicon.t <= t_max_) - t_min_;

imu.q = imu.q(imu.t >= t_min_ & imu.t <= t_max_,:);
imu.t = imu.t(imu.t >= t_min_ & imu.t <= t_max_) - t_min_;

ref.q = ref.q(ref.t >= t_min_ & ref.t <= t_max_,:);
ref.Tr = ref.Tr(ref.t >= t_min_ & ref.t <= t_max_,:);
ref.t = ref.t(ref.t >= t_min_ & ref.t <= t_max_) - t_min_;

% Resample Data using the same time vector 
t_min = 30.0;
t_max = 45.0;

thrust_ff = 0.5675;

g = 9.81;

if t_max > t_max_ - t_min_
    t_max = min([vicon.t(end), imu.t(end), ref.t(end)]);
end

Ts = 10*1e-3;

t_new = t_min:Ts:t_max;

% Compute Linear Velocities 
lpFilt = designfilt('lowpassfir','PassbandFrequency',0.01, ...
         'StopbandFrequency',0.15,'PassbandRipple',0.5, ...
         'StopbandAttenuation',65,'DesignMethod','kaiserwin');
vicon.r_dot = [filtfilt(lpFilt,diff(vicon.r/Ts));zeros(1,3)];

% Compute velocity in the N frame
for i=1:length(vicon.t)
   psi = rad2deg(quat2eul(vicon.q(i,:)));
   vicon.r_dot_N(i,:) = rotz(psi(1))*vicon.r_dot(i,:)';
   vicon.r_dot_B(i,:) = quat2rotm(vicon.q(i,:))'*vicon.r_dot(i,:)';
   vicon.g(i,:) = quat2rotm(vicon.q(i,:))'*[0,0,-1]';
end

% Resample IMU data
imu.q = interpolate_quat(imu.q, imu.t, t_new);
imu.t = t_new;

% Resample Vicon Data 
vicon.q = interpolate_quat(vicon.q, vicon.t, t_new);
vicon.r = interpolate_3d(vicon.r, vicon.t, t_new);
vicon.r_dot   = interpolate_3d(vicon.r_dot, vicon.t, t_new);
vicon.r_dot_N = interpolate_3d(vicon.r_dot_N, vicon.t, t_new);
vicon.r_dot_B = interpolate_3d(vicon.r_dot_B, vicon.t, t_new);
vicon.g = interpolate_1d(vicon.g(:,3), vicon.t, t_new);
vicon.t = t_new;

% Resample Reference Data 
ref.q  = interpolate_quat(ref.q, ref.t, t_new);
ref.Tr = interpolate_1d(ref.Tr/thrust_ff, ref.t, t_new);
ref.t  = t_new;

vicon.eul = quat2eul(vicon.q);
imu.eul = quat2eul(imu.q);
%% Pitch subsystem ID 

% Use IMU or Vicon ?
useIMU = false;
sys_order = 1;

% Get MAV pitch angle (theta)
if useIMU
    mav_orientation_eul = zeros(length(imu.q),3);
    for i=1:length(imu.q)
         mav_orientation_eul(i,:) = quat2eul(imu.q(i,:),'ZYX');
    end
    theta_ts = timeseries(mav_orientation_eul(:,2),imu.t);
else
    mav_orientation_eul = zeros(length(vicon.q),3);
    for i=1:length(vicon.q)
      mav_orientation_eul(i,:) = quat2eul(vicon.q(i,:),'ZYX');
    end
    theta_ts = timeseries(mav_orientation_eul(:,2),vicon.t);
end

% Get MAV reference pitch angle (theta_ref)
mav_ref_orientation_eul = zeros(length(ref.q),3);
for i=1:length(ref.q)
    mav_ref_orientation_eul(i,:) = quat2eul(ref.q(i,:),'ZYX');
end
theta_ref_ts = timeseries(mav_ref_orientation_eul(:,2),ref.t);

% Estimate pitch transfer function 
theta_data = iddata(detrend(theta_ts.Data), detrend(theta_ref_ts.Data), Ts);
pitch_tf = tfest(theta_data, sys_order,0);
compare(theta_data,pitch_tf);

%% Roll subsystem ID

% Use IMU or Vicon ?
useIMU = true;
sys_order = 1;

% Get MAV pitch angle (theta)
if useIMU
    mav_orientation_eul = zeros(length(imu.q),3);
    for i=1:length(imu.q)
         mav_orientation_eul(i,:) = quat2eul(imu.q(i,:),'ZYX');
    end
    roll_ts = timeseries(mav_orientation_eul(:,3),imu.t);
else
    mav_orientation_eul = zeros(length(vicon.q),3);
    for i=1:length(vicon.q)
      mav_orientation_eul(i,:) = quat2eul(vicon.q(i,:),'ZYX');
    end
    roll_ts = timeseries(mav_orientation_eul(:,3),vicon.t);
end

% Get MAV reference pitch angle (theta_ref)
mav_ref_orientation_eul = zeros(length(ref.q),3);
for i=1:length(ref.q)
    mav_ref_orientation_eul(i,:) = quat2eul(ref.q(i,:),'ZYX');
end
roll_ref_ts = timeseries(mav_ref_orientation_eul(:,3),ref.t);

% Estimate pitch transfer function 
roll_data = detrend(iddata(roll_ts.Data, roll_ref_ts.Data, Ts));


roll_tf = tfest(roll_data,sys_order);
compare(roll_data,roll_tf);

%% X_dot subsystem

% Use IMU or Vicon ?
useIMU = false;
sys_order = 1;

% Get MAV pitch angle (theta)
if useIMU
    mav_orientation_eul = zeros(length(imu.q),3);
    for i=1:length(imu.q)
         mav_orientation_eul(i,:) = quat2eul(imu.q(i,:),'ZYX');
    end
    pitch_ts = timeseries(mav_orientation_eul(:,2),imu.t);
else
    mav_orientation_eul = zeros(length(vicon.q),3);
    for i=1:length(vicon.q)
      mav_orientation_eul(i,:) = quat2eul(vicon.q(i,:),'ZYX');
    end
    pitch_ts = timeseries(mav_orientation_eul(:,2),imu.t);
end
x_dot_ts = timeseries(vicon.r_dot_N(:,1),vicon.t); 

% Estimate xdot tf
init_sys = idtf(9.81,[1, 0.2]);
init_sys.Structure.Numerator.Minimum = 9.81;
init_sys.Structure.Numerator.Maximum = 9.81;

x_dot_data = iddata(x_dot_ts.Data, pitch_ts.Data, Ts);
x_dot_tf = tfest(x_dot_data,init_sys);
compare(x_dot_data,x_dot_tf);


%% Y_dot subsystem

% Use IMU or Vicon ?
useIMU = true;
sys_order = 1;

% Get MAV pitch angle (theta)
if useIMU
    mav_orientation_eul = zeros(length(imu.q),3);
    for i=1:length(imu.q)
         mav_orientation_eul(i,:) = quat2eul(imu.q(i,:),'ZYX');
    end
    roll_ts = timeseries(mav_orientation_eul(:,3),imu.t);
else
    mav_orientation_eul = zeros(length(vicon.q),3);
    for i=1:length(vicon.q)
      mav_orientation_eul(i,:) = quat2eul(vicon.q(i,:),'ZYX');
    end
    roll_ts = timeseries(mav_orientation_eul(:,3),imu.t);
end
y_dot_ts = timeseries(vicon.r_dot_N(:,2),vicon.t); 

% Estimate ydot tf
y_dot_data = iddata(y_dot_ts.Data, roll_ts.Data, Ts);

init_sys = idtf(-9.81,[1, 0.2]);
init_sys.Structure.Numerator.Minimum = -9.81;
init_sys.Structure.Numerator.Maximum = -9.81;

y_dot_tf = tfest(y_dot_data,init_sys);
compare(y_dot_data,y_dot_tf);

%% Z_dot subsystem 

z_dot_ts = timeseries(vicon.r_dot_B(:,3),vicon.t); 
thrust_ref_ts = timeseries((ref.Tr + vicon.g)*g,vicon.t);

z_dot_data = iddata(z_dot_ts.Data, thrust_ref_ts.Data, Ts);
init_sys = idtf(1,[1, 0.2]);
init_sys.Structure.Numerator.Minimum = 0.7;
init_sys.Structure.Numerator.Maximum = 1.3;

z_dot_tf = tfest(z_dot_data,init_sys);
compare(z_dot_data,z_dot_tf);
