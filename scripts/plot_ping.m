#!/usr/bin/octave
pkg load statistics;

arg_list = argv();
ping_csv_path = arg_list{1};
ping_csv = csvread(ping_csv_path);

ip = ping_csv(1, 1);
ping_id = ping_csv(:, 2);
ping_time = ping_csv(:, 3);
ping_timestamp_ns = ping_csv(:, 4);

ts_first = ping_timestamp_ns(1);
ping_rel_time = zeros(length(ping_timestamp_ns), 1);
for i = 2:length(ping_timestamp_ns)
  ping_rel_time(i) = (ping_timestamp_ns(i) - ts_first) * 1e-9;
end

figure(1);
hold on;
boxplot(ping_time);
title("Ping Distribution");
set(gca, "XTick", [1], "xticklabel", {"drone"});
ylabel("Round trip time (ms)");
% saveas(1, "ping_plot.png");

figure(2);
hold on;
title("Ping over time");
plot(ping_rel_time, ping_time, "rx-", "linewidth", 1.0);
xlabel("Time [s]");
ylabel("Round trip time [ms]");

ginput();
