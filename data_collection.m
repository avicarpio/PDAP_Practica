db_path = "audioDB";

ads = audioDatastore(db_path, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

ads1 = splitEachLabel(ads,0.05);

[data,dataInfo] = read(ads1);

[audio1,fs] = audioread(dataInfo.FileName);