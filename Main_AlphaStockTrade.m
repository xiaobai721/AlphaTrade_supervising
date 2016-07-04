% this is the main function for alpha stock trading
function Main_AlphaStockTrade()
global fid_log
global fid_data

fid_data = AlphaData();
cd('..');
%% generate log
fid_log = AlphaTradeLog();

%% parse the xml config file, get account information
AccountInfo = ParseAccountConfig();

%% check some data file
CheckDataFile(AccountInfo);

cd('AlphaTrade_supervising');
%% trade process including: 1.get current holding, 2.generate target, 3.generate trade vol
TradeProcess(AccountInfo);

%% end log
[idate, itime] = GetDateTimeNum();
fprintf('\n--->>> %s_%s,\tEnd generate all accounts trade files.\n', num2str(idate), num2str(itime));
fprintf(fid_log, '\n--->>> %s_%s,\tEnd generate all accounts trade files.\n', num2str(idate), num2str(itime));
fclose(fid_log);