#!/usr/bin/octave
pkg load statistics;

ping_csv = csvread("~/ping-drone.csv");

ip = ping_csv(1, 1);
ping_id = ping_csv(:, 2);
ping_time_ms = ping_csv(:, 3);
ping_timestamp = ping_csv(:, 4);


ts_first = ping_timestamp(1);

ping_rel_time = zeros(length(ping_timestamp), 1);
for i = 2:length(ping_timestamp)
  ping_rel_time(i) = ping_timestamp(i) - ts_first;
end

figure(1);
hold on;
boxplot(ping_time_ms);
title("Ping time over 1 min from Laptop to SRL drone");
set(gca, "YTick", 0:5:max(ceil(ping_time_ms) + 5));
set(gca, "XTick", [1], "xticklabel", {"Drone"});
ylabel("Round trip time (ms)");
% saveas(1, "ping_plot.png");

figure(2);
hold on;
plot(ping_rel_time, ping_time_ms, "rx-");
set(gca, "YTick", 0:5:max(ceil(ping_time_ms) + 5));
xlabel("Timestamp");
ylabel("Round trip time (ms)");

ginput();
