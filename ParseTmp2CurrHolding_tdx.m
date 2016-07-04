function ParseTmp2CurrHolding_tdx(AccountInfo, id)
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
path_dest   = [AccountInfo{ai}.BASEPATH  AccountInfo{ai}.NAME '\'];
path_com    = [AccountInfo{ai}.BASEPATH 'com_data\'];
sourceFile  = [path_source 'stock_holding.txt'];
destFile    = [path_dest 'current_holding.txt'];
file_split  = [path_com 'split.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% load split files
if exist(file_split, 'file')
	split = load(file_split);
end

%% parse holding log file
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tBegin to parse holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
    
    holding = zeros(1000000,3);
    nHolding = 0;
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    while ~feof(fid_s)
        nHolding = nHolding + 1;
        fline = fgetl(fid_s);%rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','         ');
        s = strrep(fline, '   ',',');
        d = strfind(s,',');
        p = [];
        for k = 1:length(d)
            p = [p '%s'];
        end
        t = textscan(s, p, 'delimiter',',');
        tmp = zeros(1,3);%3代表着ticker，holding，可用holding，共3个值
        nPiece = size(tmp,2);
        n = 0;%找到这一行中的第几列，用来定位哪一列是想要的数据，例如n == 4，第4列是证券名称，就算不是想要的数据
        m = 0;%一共nPiece个数据，当m == 9 时，表示都找到了，就可以跳出循环了。
        for k = 1:length(t)
            if m >= nPiece
                break;
            end
            if isempty(t{1,k}{1,1})
                continue;
            else
                n = n + 1;
                if n == 1
                    m = m + 1;
                    tmp(1) = str2double(t{1,k});%ticker
                elseif n == 3
                    m = m + 1;
                    tmp(2) = str2double(t{1,k}) * unit;%vol
                elseif n == 4
                    m = m + 1;
                    tmp(3) = str2double(t{1,k}) * unit;%available vol
                end
            end
        end
        holding(nHolding, :) = tmp;
    end
    
    holding(all(holding==0,2),:) = [];
    fclose(fid_s);
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
dst_destFile   = [path_dest '\HistoricalCurrentHolding\current_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_split = [path_dest 'HistoricalSplit\split_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(sourceFile, dst_sourceFile);
CopyFile2HistoryDir(destFile, dst_destFile);
CopyFile2HistoryDir(file_split, dst_file_split);

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);