function names = unpack(path)
D = dir(path);
D = D(3:end);
filenum = 0;
for ii = 1:numel(D)
    subdir = dir([D(ii).folder filesep D(ii).name]);
    subdir = subdir(3:end);
    
    filenum = filenum + length(subdir);
end

names = cell(filenum, 1);
count = 1;
for jj = 1:numel(D)
    subdir = dir([D(jj).folder filesep D(jj).name]);
    subdir = subdir(3:end);
    for kk = 1:numel(subdir)
        names{count, 1} = [subdir(kk).folder filesep subdir(kk).name];
        count = count + 1;
    end
end