function [an, cellnum, celltype, startT, stretchtype] = filename2vars(filename)
breaks = find(filename == '-' | filename == '_' | filename == '.');
an = filename(1:breaks(3)-1);
cellnum = filename(breaks(4)+1:breaks(5)-1);
celltype = filename(breaks(5)+1:breaks(6)-1);
startT = filename(breaks(end-2)+1:breaks(end-1)-1);
stretchtype = filename(breaks(end-1)+1:breaks(end)-1);