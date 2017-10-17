bit_width = 7;
max_value = 2^7-1;
rgb_i = 0:max_value;

gamma = [0.8 0.9 1.1 1.2];   % gamma values
fileName = 'gamma_vals.hex'; % file-name for mem-init

rgb_o = round(((rgb_i.'*ones(1,length(gamma)))/max_value).^...
               (ones(max_value+1,1)*gamma)*max_value);

rgb_o = reshape(rgb_o,1,[]);

intelhex_gen(rgb_o,fileName);