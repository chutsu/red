#!/usr/bin/octave
pkg load statistics;

function [ts_int] = str2uint64(ts_str)
  assert(typeinfo(ts_str) == "sq_string");

  ts_int = uint64(0);
  for i = 0:(length(ts_str) - 1)
    ts_int += str2num(ts_str(end - i)) * 10**i;
  end
endfunction

arg_list = argv();
csv_path = arg_list{1};

fmt_str = "%u64 %f";
fid = fopen(csv_path, "r");
csv = textscan(fid, fmt_str, "delimiter", ",", "headerlines", 1);
ts = csv{1};
td = csv{2};



printf("Time delays\n");
printf("------------------------------\n");
printf("min: %.4f ms\n", min(td));
printf("max: %.4f ms\n", max(td));
printf("mean: %.4f ms\n", mean(td));
printf("median: %.4f ms\n", median(td));

ts_first = ts(1);
rel_time = zeros(length(ts), 1);
for i = 2:length(ts)
  rel_time(i) = double(ts(i) - ts_first) * 1e-9;
end

% figure(1);
% hold on;
% boxplot(td);
% title("Time Delays");
% set(gca, "XTick", [1], "xticklabel", {""});
% ylabel("Time delay (s)");

figure(2);
hold on;
title("Time delay over time");
plot(rel_time, td, "rx-", "linewidth", 1.0);
xlabel("Time [s]");
ylabel("Time delay [s]");
xlim([0, max(rel_time) + 1.0])

ginput();
