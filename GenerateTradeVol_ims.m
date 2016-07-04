function GenerateTradeVol_ims(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

%% log
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

N_PART = str2double(AccountInfo{ai}.NPART);% 要写成N_PART个篮子文件，在xml中设置
path_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];

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
position = max(unionHolding(:,2), unionHolding(:,3) - unionHolding(:,4));
diffHolding = [unionHolding(:,1), position - unionHolding(:,3)];

fid = fopen(file_trade, 'w');
fprintf(fid, [repmat('%15d\t',1,size(diffHolding,2)), '\n'], diffHolding');
fclose(fid);
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tDONE. Write trade vol file. file = %s.\n', num2str(idate), num2str(itime), file_trade);

dst_file_trade = [path_account 'HistoricalTrade\trade_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_trade, dst_file_trade);

%% write into trade files for client
diffHolding(all(diffHolding(:,2) == 0,2), :) = [];

% devide into N_PART
numOfTrade = size(diffHolding,1);
one = ones(numOfTrade, numOfTrade);

dev_vol = floor(abs(diffHolding(:,2)) / 100 / N_PART);
rem_vol = rem(floor(abs(diffHolding(:,2) / 100)), N_PART);

dev_vol = diag(dev_vol);
dev_vol = (one * dev_vol)';
dev_vol(:,N_PART+1:end) = [];

rem_vol = diag(rem_vol);
rem_vol = (one * rem_vol)';
rem_vol(:, N_PART+1:end) = [];
tmp = 1:N_PART;
tmp = repmat(tmp, numOfTrade, 1);
tmp(:, N_PART+1:end) = [];
rem_vol = ((rem_vol - tmp) >= 0);

bs = abs(diffHolding(:,2)) ./ diffHolding(:,2);
bs = diag(bs);
bs = (one * bs)';
bs(:,N_PART+1:end) = [];

child_vol = (dev_vol + rem_vol) .* bs * 100; % 乘以100后变成股数, 并且带有符号

% begin to write in parts
[idate, itime] = GetDateTimeNum();
fprintf('--->>> %s_%s,\tTotal Part = %d. account = %s\n', num2str(idate), num2str(itime), N_PART, AccountInfo{ai}.NAME);
for ipart = 1:N_PART
	[idate, itime] = GetDateTimeNum();
	fprintf('--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	fprintf(fid_log, '--->>> %s_%s,\tGenerate Part %d.\n', num2str(idate), num2str(itime), ipart);
	
	file_name = ['trade_p' num2str(ipart)];
	file_today = [path_account file_name '.txt'];
	
	fid = fopen(file_today, 'w');
	if fid > 0
		PriceType = 'ANY';
		Price = '0';
		for i = 1:numOfTrade
            if child_vol(i, ipart) == 0
                continue;
            end
			if diffHolding(i,1) < 600000
				Market = '1';
			else
				Market = '0';
			end
			Ticker = num2str(diffHolding(i,1), '%06d');
			if child_vol(i,ipart) > 0
				BS = 'B';
			elseif child_vol(i,ipart) < 0
				BS = 'S';
			end
			Vol = num2str(abs(child_vol(i,ipart)));
			
			lines = [Market '|' Ticker '|' BS '|' '|' PriceType '|' '|' Price '|' Vol '\n'];
			fprintf(fid, lines);
		end
		fclose(fid);
		
		[idate, itime] = GetDateTimeNum();
		fprintf(fid_log, '--->>> %s_%s,\tDone write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
		dst_file_today = [path_account 'HistoricalTrade\' file_name '_' num2str(idate) '_' num2str(itime) '.txt'];
		CopyFile2HistoryDir(file_today, dst_file_today);   
	else
		fprintf(fid_log, '--->>> %s_%s,\tError when write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
		fclose(fid);
		return;
	end
end

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);