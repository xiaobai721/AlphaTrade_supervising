function ParseTmp2CurrHolding_a8(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

path_source = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
path_dest   = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
path_com    = [AccountInfo{ai}.BASEPATH 'com_data\'];
sourceFile  = [path_source 'stock_holding.xlsx'];
destFile    = [path_dest 'current_holding.txt'];
file_split  = [path_com 'split.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% load split files
if exist(file_split, 'file')
	split = load(file_split);
end

%% parse holding log file
if exist(sourceFile, 'file')
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tBegin to parse holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
    
    [~, ~, rawData] = xlsread(sourceFile);
    numOfInst = size(rawData,1) - 3;
    if numOfInst > 0
        holding = zeros(numOfInst, 3);
        for im = 1:numOfInst
            holding(im,1) = str2double(rawData{im + 2, 3});%ticker
            holding(im,2) = rawData{im + 2, 5}(1) * unit;%vol
            holding(im,3) = holding(im,2) - rawData{im + 2, 10}(1) * unit;%available vol
        end
        holding(any(isnan(holding),2),:) = [];    
    end
else
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tError when open holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
end

if exist(path_dest, 'dir')
else
    mkdir(path_dest);
end
if exist('holding','var')
    if ~isempty(holding)
		if exist('split', 'var')
			[co_ticker, pHolding, pSplit] = intersect(holding(:,1), split(:,1));
			if isempty(co_ticker)
			else
				holding(pHolding,2) = holding(pHolding,2) .* (1 + split(pSplit,2));
			end
		end
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end

%% copy file to history direction
[idate, itime] = GetDateTimeNum();
dst_sourceFile = [path_source 'HistoricalLog\stock_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_destFile   = [path_dest 'HistoricalCurrentHolding\current_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_split = [path_dest 'HistoricalSplit\split_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(sourceFile, dst_sourceFile);
CopyFile2HistoryDir(destFile, dst_destFile);
CopyFile2HistoryDir(file_split, dst_file_split);

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);