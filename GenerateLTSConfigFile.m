function GenerateLTSConfigFile(mAccountInfo)
global fid_log

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin generate config file for LTS. account = %s.\n', num2str(idate), num2str(itime), mAccountInfo.NAME);
fprintf('--->>> %s_%s,\tBegin generate config file for LTS. account = %s.\n', num2str(idate), num2str(itime), mAccountInfo.NAME);

dir_account = [mAccountInfo.BASEPATH mAccountInfo.NAME '\'];
dir_lts   = mAccountInfo.LTSPATH;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dir_account = 'E:\Chn_Stocks_Trading_System\Trade_Goals\currentHolding\ZQIN_HUABAO\';
% dir_lts = 'E:\Chn_Stocks_Trading_System\Execution\ZQIN_HUABAO\';
file_at      = [dir_lts 'At.config'];
file_md      = [dir_lts 'Md.config'];

target_holdings = load([dir_account 'target_holding.txt']);
current_holdings = load([dir_account 'current_holding.txt']);
N_STOCK = size(target_holdings, 1);
N_CURRENT = size(current_holdings, 1);

for ii = 1:N_CURRENT
    post = find(target_holdings(1:N_STOCK, 1) == current_holdings(ii, 1), 1, 'first');
    if (isempty(post))
        N_STOCK = N_STOCK + 1;
        target_holdings(N_STOCK, 1) = current_holdings(ii, 1);
        target_holdings(N_STOCK, 2) = max(0, current_holdings(ii, 2) - current_holdings(ii, 3));
    end
end

compare_holdings = zeros(N_STOCK, 2);
for ii = 1:N_STOCK
    compare_holdings(ii, 1) = target_holdings(ii, 2);
    
    post = find(current_holdings(:, 1) == target_holdings(ii, 1), 1, 'first');
    if (isempty(post))
        compare_holdings(ii, 2) = 0;
    else
        compare_holdings(ii, 2) = current_holdings(post, 2);
    end
end

rmAble = zeros(N_STOCK, 1);
for ii = 1:N_STOCK
    if (compare_holdings(ii, 1) == compare_holdings(ii, 2))
        rmAble(ii) = 1;
    end
end

N_SH = 0;
N_SZ = 0;
for ii = 1:N_STOCK
    if (rmAble(ii) == 1)
        continue
    end
    
    if (target_holdings(ii, 1) >= 500000)
        N_SH = N_SH + 1;
    else
        N_SZ = N_SZ + 1;
    end
end

% AT config
op_file = fopen(file_at, 'w');
fprintf(op_file, '0\n');
fprintf(op_file, '1\n');
fprintf(op_file, '5\n');
fprintf(op_file, '500000\n');
fprintf(op_file, '60000\n');
fprintf(op_file, '10\n');
fprintf(op_file, '50\n');
fprintf(op_file, '10\n');
fprintf(op_file, '10000\n');
fprintf(op_file, '1\n');
fprintf(op_file, [mAccountInfo.BASEPATH mAccountInfo.NAME '\PositionList.txt\n']);
fprintf(op_file, '%d\n', N_SH);
fprintf(op_file, '%d\n', N_SZ);
for ii = 1:N_STOCK
    if (rmAble(ii) == 1)
        continue
    end
    
    if (target_holdings(ii, 1) >= 500000)
        fprintf(op_file, '%06d\n', target_holdings(ii, 1));
    end
end

for ii = 1:N_STOCK
    if (rmAble(ii) == 1)
        continue
    end
    
    if (target_holdings(ii, 1) < 500000)
        fprintf(op_file, '%06d\n', target_holdings(ii, 1));
    end
end
fclose(op_file);

% MD config
op_file = fopen(file_md, 'w');
fprintf(op_file, '1000\n');
fprintf(op_file, '10\n');
fprintf(op_file, '300000\n');
fprintf(op_file, '%d\n', N_SH);
for ii = 1:N_STOCK
    if (rmAble(ii) == 1)
        continue
    end
    
    if (target_holdings(ii, 1) >= 500000)
        fprintf(op_file, '%06d\n', target_holdings(ii, 1));
    end
end

fprintf(op_file, '%d\n', N_SZ);
for ii = 1:N_STOCK
    if (rmAble(ii) == 1)
        continue
    end
    
    if (target_holdings(ii, 1) < 500000)
        fprintf(op_file, '%06d\n', target_holdings(ii, 1));
    end
end

fprintf(op_file, '0\n');
fprintf(op_file, [mAccountInfo.FRONT '\n']);
fprintf(op_file, [mAccountInfo.BROKER '\n']);
fprintf(op_file, [mAccountInfo.CAPITAL '\n']);
fprintf(op_file, [mAccountInfo.PSWD '\n']);
fclose(op_file);


[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate config file for LTS. account = %s.\n', num2str(idate), num2str(itime), mAccountInfo.NAME);
fprintf('--->>> %s_%s,\tEnd generate config file for LTS. account = %s.\n', num2str(idate), num2str(itime), mAccountInfo.NAME);