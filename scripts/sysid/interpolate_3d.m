function [pos_interpolated] = interpolate_3d(pos_original,t_original, t_new)
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

    pos_interpolated=[];
    for i =1:length(t_new)
        q_k_minus_1 = pos_original(prev_i(i),:);
        q_k = pos_original(next_i(i),:);
        Dq = q_k - q_k_minus_1;
        pos_interpolated =[pos_interpolated;q_k_minus_1 + alpha_correction(i)*Dq];   
    end
end

