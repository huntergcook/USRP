function upsampled = my_upsample(signal,rate);
    jj = 1;
    for ii = 1:numel(signal)
        upsampled(jj:jj+(rate-1)) = signal(ii);
        jj = ii*rate+1;
    end
end