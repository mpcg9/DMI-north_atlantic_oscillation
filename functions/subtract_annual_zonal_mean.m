function gbi_red = subtract_annual_zonal_mean(gbi_data,gbi_annual_zonal_mean)
% gbi_red = subtract_annual_zonal_mean(gbi_data,gbi_annual_zonal_mean)

for k = 1 : length(gbi_annual_zonal_mean)
m = 1; j = 1;
    while (m + 11) <= length(gbi_data{k})
        gbi_red{k}(m:(m+11),1) = gbi_data{k}(m :(m+11))...
            - gbi_annual_zonal_mean{k}.GBI(j);
        m = m + 12;
        j = j + 1;
    end
end

end