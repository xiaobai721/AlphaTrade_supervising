function GenerateTradeVol_winner(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

%% winner需要先生成LTS的configfile
GenerateLTSConfigFile(AccountInfo{ai});

%% log of generate trade vol
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

path_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
path_lts = AccountInfo{ai}.LTSPATH;

file_target = [path_account 'target_holding.txt'];
file_current = [path_account 'current_holding.txt'];
file_trade = [path_account 'trade_holding.txt'];

%% load target file
if exist(file_target, 'file')
    tHolding = load(file_target);
else
    tHolding = 0;
end
%% load current file
if exist(file_current, 'file')
    cHolding = load(file_current);
else
    cHolding = 0;
end
cHolding(all(rem(floor(cHolding(:,1) / 100000), 3) ~= 0, 2),:) = [];

%% generate trade vol, and write into trade file
unionTicker = union(tHolding(:,1), cHolding(:,1));
unionTicker(all(unionTicker == 0, 2), :) = [];
if isempty(unionTicker)
	[idate, itime] = GetDateTimeNum();
	fprintf(2, '--->>> %s_%s,\tError when generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
	fprintf(fid_log, '--->>> %s_%s,\tError when generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
	return;
end
numOfTicker = size(unionTicker,1);
unionHolding = zeros(numOfTicker, 4);%第一列是ticker，第二列是target，第三列是current, 第四列是available
unionHolding(:,1) = unionTicker;
for i = 1:numOfTicker
    pT = find(tHolding(:,1) == unionHolding(i,1), 1, 'first');
    pC = find(cHolding(:,1) == unionHolding(i,1), 1, 'first');
    if isempty(pT)
		unionHolding(i,2) = 0;
    else
        unionHolding(i,2) = tHolding(pT, 2);
    end
    if isempty(pC)
        unionHolding(i,3) = 0;
		unionHolding(i,4) = 0;
    else
        unionHolding(i,3) = cHolding(pC, 2);
		unionHolding(i,4) = cHolding(pC, 3);
    end
end
position_list = [unionHolding(:,1) max(unionHolding(:,2), unionHolding(:,3) - unionHolding(:,4))];
diffHolding = [unionHolding(:,1) position_list(:,2) - unionHolding(:,3)];
diffHolding(all(diffHolding(:,2) == 0,2),:) = [];
numOfTrade = size(diffHolding,1);

fid = fopen(file_trade, 'w');
fprintf(fid, [repmat('%15d\t',1,size(diffHolding,2)), '\n'], diffHolding');
fclose(fid);
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tDONE. Write trade vol file. file = %s.\n', num2str(idate), num2str(itime), file_trade);

dst_file_trade = [path_account 'HistoricalTrade\trade_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_trade, dst_file_trade);

%% write into trade files for client
[idate, itime] = GetDateTimeNum();
fprintf('--->>> %s_%s,\tBegin generate Position List for LTS. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
	
file_name = 'PositionList.txt';
file_today = [path_lts file_name];
fid = fopen(file_today, 'w');
fprintf(fid, '%d\n', numOfTrade);
position_list = sort(position_list,'descend');
for i = 1:numOfTrade
	fprintf(fid, '%06d%10d%10d%10d%15s%10d\n', position_list(i, 1), position_list(i,2), 0, 1, '8:45:40', 384);
end
fclose(fid);

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tDone write position list for LTS. file = %s.\n', num2str(idate), num2str(itime), file_today);
dst_file_today = [path_account 'HistoricalTrade\' file_name '_' num2str(idate) '_' num2str(itime) '.csv'];
CopyFile2HistoryDir(file_today, dst_file_today); 

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);