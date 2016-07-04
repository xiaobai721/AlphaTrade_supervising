function [idate, itime] = GetDateTimeNum()
times = clock;
idate = times(1) * 10000 + times(2) * 100 + times(3);
itime = times(4) * 10000 + times(5) * 100 + floor(times(6));