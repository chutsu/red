function [q_interpolated] = interpolate_quat(q_original,t_original, t_new)
    prev_i = [];
    next_i = [];
    alpha_correction = [];
    for i =1:length(t_new)
        prev_index = find(t_original <= t_new(i),1,'last');
        next_index = find(t_original >= t_new(i),1,'first');
        prev_i = [prev_i;prev_index];
        next_i = [next_i;next_index];
        if prev_index == next_index
            alpha = 0.0;
        else
          alpha = (t_new(i) - t_original(prev_index) )/(t_original(next_index) - t_original(prev_index));
        end
        alpha_correction = [alpha_correction;alpha];
    end

    q_interpolated=[];
    for i =1:length(t_new)
        q_k_minus_1 = [q_original(prev_i(i),1),q_original(prev_i(i),2),q_original(prev_i(i),3),q_original(prev_i(i),4)];
        q_k = [q_original(next_i(i),1),q_original(next_i(i),2),q_original(next_i(i),3),q_original(next_i(i),4)];
        q_interpolated =[q_interpolated;quatinterp(q_k_minus_1,q_k,alpha_correction(i),'slerp')];   
    end
end