metaPath = "data\meta.txt";
errorPath = "data\error.txt";

T = readtable(metaPath,'Delimiter','\t','ReadVariableNames',false);
T_error = readtable(errorPath,'Delimiter','\t','ReadVariableNames',false);

categories = unique(T{:,2});

mkdir("audioDB")
for c = 1:size(categories)
    nom_carpeta=string(categories(c,1));
    nom_carpeta=strrep(nom_carpeta,'/','-');
    mkdir(strcat("audioDB/",nom_carpeta))
end

path = "data/";

for r = 1:size(T,1)
    filename = cell2mat(T{r,1});
    category = cell2mat(T{r,2});
    
    if not(searchForErrors(filename,T_error))
       [a,Fs] = audioread(strcat(path,filename));
       mono_a = 0.5*sum(a,2);
       audiowrite(strcat("audioDB/",strrep(category,'/','-'),"/",strrep(filename,"audio/","")),mono_a,Fs);
    end
    
end