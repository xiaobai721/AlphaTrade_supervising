function CopyFile2HistoryDir(f_src, f_dst)
global fid_log

%% make dest direction
tmp = find(f_dst == '\');
try
    dir_dst = f_dst(1:tmp(end));
    if exist(dir_dst, 'dir');
    else
        try
            mkdir(dir_dst);
        catch
            [idate, itime] = GetDateTimeNum();
            fprintf(fid_log, '--->>> %s_%s,\tError when mkdir. dir = %s.\n', num2str(idate), num2str(itime), dir_dst);
        end
    end
catch
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tError when get dest dir. file_dest = %s.\n', num2str(idate), num2str(itime), f_dst);
end

%% copy file
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tCopy %s TO %s.\n', num2str(idate), num2str(itime), f_src, f_dst);
if exist(f_src, 'file')
    try
        copyfile(f_src, f_dst);
        fprintf(fid_log, '--->>> %s_%s,\tDONE. Copy %s TO %s.\n', num2str(idate), num2str(itime), f_src, f_dst);
    catch
        fprintf(fid_log, '--->>> %s_%s,\tError when copy %s TO %s.\n', num2str(idate), num2str(itime), f_src, f_dst);
    end
else
    fprintf(fid_log, '--->>> %s_%s,\tNo source file to be copied when copy %s TO %s.\n', num2str(idate), num2str(itime), f_src, f_dst);
end