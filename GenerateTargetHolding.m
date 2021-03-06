function [alpha_benchMoney, MkValue, stocksize_50, stockindex_50, stocksize_250, stockindex_250, stocksize_300, stockindex_300, share_IF, share_IC500, share_IC1200] = GenerateTargetHolding(AccountInfo, id)
global fid_log

alpha_benchMoney = 0;
MkValue = 0;
stock_in_IC = 0;
stock_in_IH = 0;
stock_in_IF = 0;
IC_benchmoney = 0;
IF_benchmoney = 0;
IH_benchmoney = 0;
IH_in_IF = 0;
IFNoIH = 0;
stock_in_IFNoIH = 0;
stock_in_IC500 = 0;
stock_in_IC1200 = 0;
stocksize_50 = 0;
stockindex_50 = 0;
stocksize_250 = 0;
stockindex_250 = 0;
stocksize_300 = 0;
stockindex_300 = 0;

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

[idate, itime] = GetDateTimeNum();
dir_account = [AccountInfo{ai}.BASEPATH AccountInfo{ai}.NAME '\'];
dir_strategy = AccountInfo{ai}.STRATEGYPATH;
dir_matdata = AccountInfo{ai}.MATDATA8PATH;
file_name_alpha   = AccountInfo{ai}.ALPHAFILE;
file_currHolding  = [dir_account 'current_holding.txt'];
file_dateList     = [dir_matdata 'dateList.mat'];
file_stockList = [dir_matdata 'stkList_num'];
file_HS300  = [dir_matdata 'HS300Pct.mat'];
file_SZ50   = [dir_matdata 'SH000016Pct.mat'];
file_ZZ500 = [dir_matdata 'SH000905Pct.mat'];


%% load share, share(:,1) -> IF, share(:,2) -> IH, share(:,3) -> IC
num_file_alpha = length(file_name_alpha);
share_today = zeros(num_file_alpha, 3);   
for i = 1:num_file_alpha
    file_share = [dir_account 'share_' file_name_alpha{i} 'txt'];
    dst_file_share            = [dir_account 'HistoricalShare\share_' num2str(idate) '_' num2str(itime) file_name_alpha{i} 'txt'];
    CopyFile2HistoryDir(file_share, dst_file_share);
    if exist(file_share,'file')
        share_today(i,:) = load(file_share);%每一行的share_today对应到alpha文件
    else
        fprintf(fid_log, '--->>> %s_%s,\Error when load share. file = %s.\n', num2str(idate), num2str(itime), file_share);
        return;
    end
end


%% load stock price
[idate,itime] = GetDateTimeNum();
mins     = floor(itime / 100);
if mins < 931 || mins > 1500
    mins = 1459;
end
%     fprintf(2, '--->>> %s_%s,\tError when loading price mat file. error = not trading time.\n', num2str(idate), num2str(itime));
%     fprintf(fid_log, '--->>> %s_%s,\tError when loading price mat file. error = not trading time.\n', num2str(idate), num2str(itime));
%     return;
% else
fprintf(fid_log, '--->>> %s_%s,\tLoad price mat file.\n', num2str(idate), num2str(itime));
    
price_date = idate;
price_mins = mins;
file_price_stock = [dir_strategy num2str(price_date) '\stockPrice_' num2str(price_date) '_' num2str(price_mins) '.mat'];
file_price_index = [dir_strategy num2str(price_date) '\indexPrice_' num2str(price_date) '_' num2str(price_mins) '.mat'];
n_try = 0;
while ~exist(file_price_stock, 'file') || ~exist(file_price_index, 'file')
    pause(2);
    n_try = n_try + 1;
    [idate, itime] = GetDateTimeNum();
    fprintf('--->>> %s_%s,\tWaiting for price mat file from LTS. try = %d. price-file = %s.\n', num2str(idate), num2str(itime), n_try, file_price_stock);
    fprintf(fid_log, '--->>> %s_%s,\tWaiting for price mat file from LTS. try = %d. price-file = %s.\n', num2str(idate), num2str(itime), n_try, file_price_stock);
    if n_try == 60
        [idate, itime] = GetDateTimeNum();
        fprintf(2, '--->>> %s_%s,\tError when getting price mat file from LTS. price-file = %s.\n', num2str(idate), num2str(itime), file_price_stock);
        fprintf(fid_log, '--->>> %s_%s,\tError when getting price mat file from LTS. price-file = %s.\n', num2str(idate), num2str(itime), file_price_stock);
        return;
    end
end   
load(file_price_stock);%stockPrice
load(file_price_index);%indexPrice

% end

%w_stockPrice = stockPrice;

p300  = find(indexPrice(:,3) == 300);
p50    = find(indexPrice(:,3) == 16);
p500  = find(indexPrice(:,3) == 905);
if isempty(p300)
    datas      = urlread('http://hq.sinajs.cn/list=s_sh000300');
    positions  = find(datas == ',');
    HS300Price = str2double(datas(positions(1)+1:positions(2)-1));
    fprintf('HS300Price urlread.\n');
else
    HS300Price = indexPrice(p300, 1);
end
if isempty(p50)
    datas2     = urlread('http://hq.sinajs.cn/list=s_sh000016');
    positions2 = find(datas2 == ',');
    A50Price   = str2double(datas2(positions2(1)+1:positions2(2)-1));
    fprintf('A50Price urlread.\n');
else
    A50Price   = indexPrice(p50, 1);
end
if isempty(p500)
    datas2     = urlread('http://hq.sinajs.cn/list=s_sh000905');
    positions2 = find(datas2 == ',');
    ZZ500Price   = str2double(datas2(positions2(1)+1:positions2(2)-1));
    fprintf('A50Price urlread.\n');
else
    ZZ500Price   = indexPrice(p500, 1);
end


%%%load current_holding
if exist(file_currHolding, 'file')
    tmpHolding = load(file_currHolding);
    col = size(tmpHolding,1);    
end

tHolding = tmpHolding;

for i = 1:col
    Pt = find(stockPrice(:,3) == tmpHolding(i,1));
    if isempty(Pt) || tmpHolding(i,2) == 0 
        continue;
    else
        MkValue = MkValue + stockPrice(Pt,1) * tmpHolding(i,2);
    end
end

%% generate money
alpha_benchMoney  = (HS300Price * sum(share_today(:, 1)) - A50Price * sum(share_today(:, 2))) * 300 + ZZ500Price * sum(share_today(:, 3)) * 200;% 每个alpha对应的benchMoney

load(file_dateList);%dateList
load(file_stockList);%stockList


%%Compare IC/IF/IH
if exist(file_HS300, 'file') && exist(file_SZ50, 'file')&&exist(file_ZZ500,'file')
    load(file_HS300);
	load(file_SZ50);
    load(file_ZZ500);
else
	fprintf(2, '--->>> %s_%s,\tError when loading HS300 and SZ50 mat file. \n', num2str(idate), num2str(itime));
end

IC_benchmoney = ZZ500Price * sum(share_today(:, 3)) * 200;
IF_benchmoney = HS300Price * sum(share_today(:, 1)) * 300;
IH_benchmoney = A50Price * sum(share_today(:, 2)) * 300;

PC = find(HS300Pct(end,:) == 0);
PF = find(HS300Pct(end,:) > 0);
PH = find(SH000016Pct(end,:) > 0);
PC500 = find(SH000905Pct(end,:) > 0);
PC1200 = intersect(find(HS300Pct(end,:) == 0) , find(SH000016Pct(end,:) == 0));

% if length(stkList_num) ~= size(HS300Pct,2)
%     fprintf(2, '--->>> %s_%s,\tError stkList is not matching with HS300Pct. \n', num2str(idate), num2str(itime));
% end

%stock in IC
for  i = 1 : length(PC)
	Pa = find(stockPrice(:,3) == stkList_num(1,PC(i)));	
     if isempty(Pa)
         continue;
     end
    Pi = find(stockPrice(Pa,3) == tHolding(:,1));
     if isempty(Pi)
         continue;
     end
    stock_in_IC = stock_in_IC + tHolding(Pi,2) * stockPrice(Pa,1);
end

%stock in IF
for  i = 1 : length(PF)
	Pa = find(stockPrice(:,3) == stkList_num(1,PF(i)));	
    if isempty(Pa)
        continue;
    end
    Pi = find(stockPrice(Pa,3) == tHolding(:,1));
    if isempty(Pi)
        continue;
    end
    stock_in_IF = stock_in_IF + tHolding(Pi,2) * stockPrice(Pa,1);
end
	
%stock in IH
for  i = 1 : length(PH)
	Pa = find(stockPrice(:,3) == stkList_num(1,PH(i)));	
    if isempty(Pa)
        continue;
    end
    Pi = find(stockPrice(Pa,3) == tHolding(:,1));
    if isempty(Pi)
        continue;
    end
    stock_in_IH = stock_in_IH + tHolding(Pi,2) * stockPrice(Pa,1);
end
    
	
	
%IH in IF
Post = find(HS300Pct(end,:) .* SH000016Pct(end,:)>0); 
%Ticker = intersect(find(HS300Pct(end,:) > 0) , find(SH000016Pct(end,:) > 0)); %返回索引
IH_in_IF = IF_benchmoney * sum(HS300Pct(end,Post))*0.01;


%IF - IH
Ti = intersect(find(HS300Pct(end,:) > 0) , find(SH000016Pct(end,:) == 0));
IFNoIH = IF_benchmoney * sum(HS300Pct(end,Ti))*0.01;

%stock in IFNoIH
for  i = 1 : length(Ti)
	Pa = find(stockPrice(:,3) == stkList_num(1,Ti(i)));	
     if isempty(Pa)
         continue;
     end
    Pi = find(stockPrice(Pa,3) == tHolding(:,1));
     if isempty(Pi)
         continue;
     end
    stock_in_IFNoIH = stock_in_IFNoIH + tHolding(Pi,2) * stockPrice(Pa,1);
end

%stock in IC500
for  i = 1 : length(PC500)
	Pa = find(stockPrice(:,3) == stkList_num(1,PC500(i)));	
     if isempty(Pa)
         continue;
     end
    Pi = find(stockPrice(Pa,3) == tHolding(:,1));
     if isempty(Pi)
         continue;
     end
    stock_in_IC500 = stock_in_IC500 + tHolding(Pi,2) * stockPrice(Pa,1);
end

%stock in IC1200
for  i = 1 : length(PC1200)
	Pa = find(stockPrice(:,3) == stkList_num(1,PC1200(i)));	
     if isempty(Pa)
         continue;
     end
    Pi = find(stockPrice(Pa,3) == tHolding(:,1));
     if isempty(Pi)
         continue;
     end
    stock_in_IC1200 = stock_in_IC1200 + tHolding(Pi,2) * stockPrice(Pa,1);
end


stocksize_50 = 	stock_in_IH + IH_benchmoney;
stockindex_50 = IH_in_IF;
stocksize_250 = stock_in_IFNoIH;
stockindex_250 = IFNoIH;
stocksize_300 = stock_in_IC;
stockindex_300 = IC_benchmoney;

share_IF = stock_in_IF/(HS300Price * 300);
share_IC500 = stock_in_IC500/(ZZ500Price * 200);
share_IC1200 = 	stock_in_IC1200/(ZZ500Price * 200);
	

