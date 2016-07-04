function TradeProcess(AccountInfo)
global fid_log
global fid_data

%% log
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin Checking Process.\n', num2str(idate), num2str(itime));

numAccount = length(AccountInfo);

for i = 1:numAccount
    %% 配置文件中的账号的顺序可能并不等于其id的值，例如排在顺序第4个的账号，其id可能是6，虽然应该尽力避免顺序与id不符。
    j_id = str2double(AccountInfo{i}.ID);
    
    if j_id == 6 || j_id ==8 || j_id ==11 || j_id == 15 || j_id == 16 || j_id == 17 || j_id == 18
    %if strcmp(AccountInfo{i}.STATUS, 'on') %当前账号active
        
        %% process tmp holding to get current holding
        %统一命名为tmpHolding_20160331.*类似的，并放在TradeLogs/（各账号）/的目录下。
        ParseTmp2CurrHolding(AccountInfo, j_id);
         %% load current_holding and benchMoney
        [alpha_benchMoney, MkValue, stocksize_50, stockindex_50, stocksize_250, stockindex_250, stocksize_300, stockindex_300, share_IF, share_IC500, share_IC1200] = GenerateTargetHolding(AccountInfo, j_id);
         %[MkValue] = CheckDiff(AccountInfo, j_id,w_stockPrice);
        if alpha_benchMoney * MkValue == 0
            fprintf(2, ' %25s:\tERROR load holding and generate benchmoney.\n', AccountInfo{j_id}.NAME);
            continue;
        end
        
        fprintf(2, ' %30s:\t%20.4f%20.4f%20.4f\n', AccountInfo{j_id}.NAME, MkValue,alpha_benchMoney,abs(MkValue - alpha_benchMoney)/alpha_benchMoney);       
		fprintf(2, ' %30s:\t%20.4f%20.4f%20.4f\n', 'IH',stocksize_50 , stockindex_50, (stocksize_50 - stockindex_50)/stocksize_50);%IH		
		fprintf(2, ' %30s:\t%20.4f%20.4f%20.4f%20.4f\n', 'IF',stocksize_250 , stockindex_250, (stocksize_250 - stockindex_250)/stocksize_250, share_IF);%IF	
		fprintf(2, ' %30s:\t%20.4f%20.4f%20.4f%20.4f%20.4f\n', 'IC',stocksize_300 , stockindex_300, (stocksize_300 - stockindex_300)/stocksize_300, share_IC500, share_IC1200);%IC	
        
        fprintf(fid_data, ' %30s:\t%20.4f%20.4f%20.4f\n', AccountInfo{j_id}.NAME, MkValue,alpha_benchMoney,abs(MkValue - alpha_benchMoney)/alpha_benchMoney);       
		fprintf(fid_data, ' %25s:\t%20.4f%20.4f%20.4f\n', 'IH',stocksize_50 , stockindex_50, (stocksize_50 - stockindex_50)/stocksize_50);%IH		
		fprintf(fid_data, ' %25s:\t%20.4f%20.4f%20.4f%20.4f\n', 'IF',stocksize_250 , stockindex_250, (stocksize_250 - stockindex_250)/stocksize_250, share_IF);%IF	
		fprintf(fid_data, ' %25s:\t%20.4f%20.4f%20.4f%20.4f%20.4f\n', 'IC',stocksize_300 , stockindex_300, (stocksize_300 - stockindex_300)/stocksize_300, share_IC500, share_IC1200);%IC	
        
        
		fprintf('\n--->>> %s_%s,\t..........................................................Ending..........................................................................\n', num2str(idate), num2str(itime));
    end
end