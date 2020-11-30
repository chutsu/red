clc;
clear all;
close all;
%%
% Bag file 
bag_file_path = '/home/dimos/PhD/ros_ws/mpc_ws/hover_3.bag';
bag_file_path = '/home/dimos/PhD/ros_ws/groundstation_old_ws/hover_aabm.bag'; 
bag_file_path = '/home/dimos/PhD/ros_ws/mpc_ws/hover_aabm_ground.bag';
bag_file_path = '/home/dimos/Downloads/ICRA2020_exploration_mav_2019-09-11-20-59-49_battery_calib.bag';

bag = rosbag(bag_file_path);

% Data topics 
topic_battery  = '/mavros/battery';
topic_vicon    = '/vicon/f450/pose';
topic_setpoint = '/mavros/setpoint_raw/attitude';


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
clear msgs_vicon;

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

% Read Battery Data
msgs_battery = readMessages(select(bag,'Topic',topic_battery));
battery.voltage = zeros(length(msgs_battery),1);
battery.percentage = zeros(length(msgs_battery),1);
battery.t = zeros(length(msgs_battery),1);
for i=1:length(msgs_battery)
    battery.voltage(i) = msgs_battery{i}.Voltage;
    battery.percentage(i) = msgs_battery{i}.Percentage;
    battery.t(i) = seconds(msgs_battery{i}.Header.Stamp);
end

% Resample Battery Data
% Crop data to avoid problems with interpolation later
t_min_ = max([ battery.t(1), ref.t(1)]);
t_max_ = min([ battery.t(end), ref.t(end)]);

vicon.q = vicon.q(vicon.t >= t_min_ & vicon.t <= t_max_,:);
vicon.r = vicon.r(vicon.t >= t_min_ & vicon.t <= t_max_,:);
vicon.t = vicon.t(vicon.t >= t_min_ & vicon.t <= t_max_) - t_min_;

battery.voltage = battery.voltage(battery.t >= t_min_ & battery.t <= t_max_,:);
battery.t = battery.t(battery.t >= t_min_ & battery.t <= t_max_) - t_min_;

ref.q = ref.q(ref.t >= t_min_ & ref.t <= t_max_,:);
ref.Tr = ref.Tr(ref.t >= t_min_ & ref.t <= t_max_,:);
ref.t = ref.t(ref.t >= t_min_ & ref.t <= t_max_) - t_min_;

t_new = 10:0.01:350;

% Resample Battery Data
battery.voltage = interpolate_1d(battery.voltage, battery.t, t_new);
battery.percentage = interpolate_1d(battery.percentage, battery.t, t_new);
battery.t = t_new;

% Resample Vicon Data 
vicon.q = interpolate_quat(vicon.q, vicon.t, t_new);
vicon.r = interpolate_3d(vicon.r, vicon.t, t_new);
vicon.t = t_new;

% Resample Reference Data
ref.q  = interpolate_quat(ref.q, ref.t, t_new);
ref.Tr = interpolate_1d(ref.Tr, ref.t, t_new);
ref.t  = t_new;

plot(battery.voltage(1000:end),ref.Tr(1000:end));
plot(battery.voltage(1:end),ref.Tr(1:end));