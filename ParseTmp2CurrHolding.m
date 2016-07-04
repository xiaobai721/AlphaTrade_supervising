function ParseTmp2CurrHolding(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

[idate,itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin to parse holding log file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

ID = str2double(AccountInfo{ai}.ID);
Client = AccountInfo{ai}.LOGCLIENT;
eval(['ParseTmp2CurrHolding_' Client '(AccountInfo, ID);']);

[idate,itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd to parse holding log file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);