function CheckDataFile(AccountInfo)
global fid_log
%% check the share_alphaxxxxx file exist or not
num_account = length(AccountInfo);
[idate,itime] = GetDateTimeNum();
for i = 1:num_account
    if strcmp(AccountInfo{i}.STATUS, 'on') 
        dir_account = [AccountInfo{i}.BASEPATH AccountInfo{i}.NAME '\'];
        file_alpha = AccountInfo{i}.ALPHAFILE;
        num_file_alpha = length(file_alpha);
        for j = 1:num_file_alpha
            file_share = [dir_account 'share_' file_alpha{j} 'txt'];
            if exist(file_share, 'file')
            else
                fid = fopen(file_share, 'w');
                if fid > 0
                    fprintf(fid, '%d\t%d\t%d\n', 0,0,0);
                    fprintf(fid_log, '--->>> %s_%s,\tDone Intialise share file. account = %s. file = %s.\n', num2str(idate), num2str(itime), AccountInfo{i}.NAME, file_share);
                    fprintf('--->>> %s_%s,\tDone Intialise share file. account = %s. file = %s.\n', num2str(idate), num2str(itime), AccountInfo{i}.NAME, file_share);
                    fclose(fid);
                else
                    fprintf(fid_log, '--->>> %s_%s,\tError Intialise share file. account = %s. file = %s.\n', num2str(idate), num2str(itime), AccountInfo{i}.NAME, file_share);
                    fprintf(2, '--->>> %s_%s,\tError Intialise share file. account = %s. file = %s.\n', num2str(idate), num2str(itime), AccountInfo{i}.NAME, file_share);
                end
            end
        end
    end
end