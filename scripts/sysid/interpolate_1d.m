function [thrust_interpolated] = interpolate_1d(thrust_original,t_original, t_new)
    prev_i = [];
    next_i = [];
    alpha_correction = zeros(length(t_new),1);
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
        alpha
        alpha_correction(i) = alpha;
    end
        thrust_interpolated= zeros(length(t_new),1);
        
    for i =1:length(t_new)
        q_k_minus_1 = thrust_original(prev_i(i),:);
        q_k = thrust_original(next_i(i),:);
        Dq = q_k - q_k_minus_1;
        thrust_interpolated(i) =  q_k_minus_1 + alpha_correction(i)*Dq;   
    end
end

