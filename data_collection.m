db_path = "audioDB";

ads = audioDatastore(db_path, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

ads_reduit = splitEachLabel(ads,0.05);

[ads1,ads2,ads3,ads4] = splitEachLabel(ads,0.25,0.25,0.25);