function main_CreateManifest
clc;clear;close all
f_ls = fopen('LS.txt','r');
mp = '_R1_001.fastq';
pp = '/projects/academic/pidiazmo/lu/DM_Extended/fastq';
fid = fopen('pe-32-manifest','w');
fprintf(fid,'sample-id\tforward-absolute-filepath\treverse-absolute-filepath\n');
while ~feof(f_ls)
    line = fgetl(f_ls);
    if contains(line,mp)
        T1 = line;
        T2 = strrep(line,mp,strrep(mp,'_R1_','_R2_'));
        S = strrep(line,mp,'');
        fprintf(fid,'%s\t%s/%s\t%s/%s\n',S,pp,T1,pp,T2);
    end
end
end