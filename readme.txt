本文件对一些约定的路径及文件命名等信息进行说明：

1.trade log 下面的 目录结构及文件命名规则：
 E:\Chn_Stocks_Trading_System\Trade_Logs\HANDE_GUANTONG\yyyymmdd\stock_holding.xx
 E:\Chn_Stocks_Trading_System\Trade_Logs\HANDE_GUANTONG\yyyymmdd\stock_order.xx
 E:\Chn_Stocks_Trading_System\Trade_Logs\HANDE_GUANTONG\yyyymmdd\stock_trade.xx
 
2. trade goal 下面的 目录及文件命名规则：
 E:\Chn_Stocks_Trading_System\Trade_Goals\currentHolding\HANDE_GUANTONG\yyyymmdd\
 
3.在ParseTmp2CurrHolding的程序中，只是把holding中的股票全部提取出来，不区分是否是股票，还是债券

4.share放在currentHolding路径的对应的账号下。
  share.txt中的第一列是日期，第二列是IF，第三列式IH，第四列式IC的手数

5.  currentHolding\HANDE_GUANTONG\ 路径下，应该有adds.txt/forbidden.txt文件, 在currentHolding/目录下应该有co_forbidden_list.txt和 modle.xlsx

6.ims & hundsun pb 导出csv文件。