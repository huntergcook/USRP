function [r lag] = my_maxcorr(signal1,signal2);
    chunk_size = length(signal1);
    for ii = 1:numel(signal2) - chunk_size;
        chunk = signal2(ii:ii+chunk_size-1);
        dot_product(ii) = signal1'*chunk;
    end
 [r lag] = max(dot_product);
end