function mfid_data = AlphaData()
dir_data = './Data';
if exist(dir_data, 'dir')
else
    mkdir(dir_data);
end

[idate, itime] = GetDateTimeNum();
file_data = [dir_data '/supervising_data_' num2str(idate) '_' num2str(itime) '.csv'];
mfid_data = fopen(file_data,'w');