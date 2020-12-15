path = "audioDB";%Adreça a la carpeta que conté la base de dades d’àudio
fs = 44.1e3;
methodML = "knn" ;% knn , cart , svm , gmm
PercentOfDataSet = 5; 
% Segons el classificador que escullen s'han d'inizialitzar els parametres
% corresponents
switch methodML
    case 'knn' 
        knn_K = 5; 
        knn_NSMethod = 'kd-tree';
        knn_Distance = 'euclidean';
        knn_Standardize = 1;
    case 'cart'
        cart_showModel = 0;
    case 'svm'
        t = templateSVM('KernelFunction','rbf','Standardize',true);    
    case 'gmm'

end
% knn_K , svm_Kernel , gmm_N;

%% 1. Definició de la base de dades a processar

% Ho heu de fer en una funció
ads = audioDatastore(path, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

aFE = audioFeatureExtractor("SampleRate",fs,...
    "Window",hamming(round(0.035*fs),"periodic"),...
    "OverlapLength",round(0.0175*fs),...
    "barkSpectrum",true,"mfcc",true,...
    "spectralCentroid",true,"spectralCrest",true,...
    "spectralKurtosis",true,"spectralSpread",true);

ads_reduit = splitEachLabel(ads,PercentOfDataSet/100);

%Extracció dades (features i labels)

[ads1,ads2,ads3,ads4] = splitEachLabel(ads_reduit,0.25,0.25,0.25);

ads1Tall = tall(ads1);
ads2Tall = tall(ads2);
ads3Tall = tall(ads3);
ads4Tall = tall(ads4);

specsTall = cellfun(@(x)extract(aFE,x),ads1Tall,"UniformOutput",false);
features1_Tall = gather(specsTall);

specsTall = cellfun(@(x)extract(aFE,x),ads2Tall,"UniformOutput",false);
features2_Tall = gather(specsTall);

specsTall = cellfun(@(x)extract(aFE,x),ads3Tall,"UniformOutput",false);
features3_Tall = gather(specsTall);

specsTall = cellfun(@(x)extract(aFE,x),ads4Tall,"UniformOutput",false);
features4_Tall = gather(specsTall);

features = cell(1,4);
labels = cell(1,4);

features{1} = gather(features1_Tall);
labels{1} = ads1.Labels;

features{2} = gather(features2_Tall);
labels{2} = ads2.Labels;

features{3} = gather(features3_Tall);
labels{3} = ads3.Labels;

features{4} = gather(features4_Tall);
labels{4} = ads4.Labels;

%1st Cell

dbFull = features{1}{1};

clearvars labelsFull

labelsFull(1:length(dbFull),1) = labels{1}(1);

for i=2:length(features{1})
    
    labelWindows(1:height(features{1}{i}),1) = labels{1}(i);
    labelsFull = [labelsFull;labelWindows];
    dbFull = [dbFull;features{1}{i}];
    
end

testDB = dbFull;
testGT = labelsFull;

%2nd Cell

dbFull = features{2}{1};

clearvars labelsFull

labelsFull(1:length(dbFull),1) = labels{2}(1);

for i=2:length(features{2})
    
    labelWindows(1:height(features{2}{i}),1) = labels{2}(i);
    labelsFull = [labelsFull;labelWindows];
    dbFull = [dbFull;features{2}{i}];
    
end

learnDB1 = dbFull;
learnGT1 = labelsFull;

%3rd Cell

dbFull = features{3}{1};

clearvars labelsFull

labelsFull(1:length(dbFull),1) = labels{3}(1);

for i=2:length(features{3})
    
    labelWindows(1:height(features{3}{i}),1) = labels{3}(i);
    labelsFull = [labelsFull;labelWindows];
    dbFull = [dbFull;features{3}{i}];
    
end

learnDB2 = dbFull;
learnGT2 = labelsFull;

%4th Cell

dbFull = features{4}{1};

clearvars labelsFull

labelsFull(1:length(dbFull),1) = labels{4}(1);

for i=2:length(features{4})
    
    labelWindows(1:height(features{4}{i}),1) = labels{4}(i);
    labelsFull = [labelsFull;labelWindows];
    dbFull = [dbFull;features{4}{i}];
    
end

learnDB3 = dbFull;
learnGT3 = labelsFull;

%Full Data

learnDB = [learnDB1;learnDB2;learnDB3];
learnGT = [learnGT1;learnGT2;learnGT3];

%KNN Classificador

KNN = fitcknn(learnDB,learnGT,'NumNeighbors',knn_K,'NSMethod',knn_NSMethod,'Distance',knn_Distance,'Standardize',knn_Standardize);

%resultat = predict(KNN,testDB);

%encerts = 0;

%for i=1:length(resultat)
    
%    if resultat(i) == testGT(i)
%        encerts = encerts + 1;
%    end
    
%end

%percentatgeErrorKNN = encerts/length(resultats) * 100;

%CART Classificador

%CART = fitctree(learnDB,learnGT);

%SVM Classificador

%svmModel = fitcecoc(learnDB,learnGT,'Learner',t);

%GMM Classificador

%TO-DO Configurar el classificador GMM amb la funcio fitgmdist

%fitgmdist

%% 2. Per a cadascuna de les 4 iteracions del 4FCV cal fer:
for i=1:4
    %2.1 Calcular dos matrius
    
    %2.2 Entrenament d’un mètode de classificació

    %2.3 Classificació del conjunt de test 
end


%% 3. Mostrar els resultats d’eficiència de classificació