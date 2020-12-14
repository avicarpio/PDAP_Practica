path = "audioDB";%Adreça a la carpeta que conté la base de dades d’àudio
methodML = "" ;% knn , cart , svm , gmm
PercentOfDataSet = 0; 
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
            
    case 'gmm'

end
% knn_K , svm_Kernel , gmm_N;

%% 1. Definició de la base de dades a processar

% Ho heu de fer en una funció
ads = audioDatastore(path, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

adsTall = tall(ads);

%Parametrització de la bbdd mitjançant atributs d'audio (3.2) 
fileName = "";
stWin = 0.2;        % O.2
stStep = 0.1;       % 0.1
mtWin= 2;           % 2
mtStep = 1;         % 1
featureShort = {'ZCR', 'energy', 'enEntropy', 'specCentroid', 'specSpread', 'specEntropy', 'specFlux'}; % Heu de triar els q vosaltres creieu
featureStatistics = {'stdbymean', 'median', 'std', 'meanNonZero', 'max', 'min', 'medianNonZero'}; % Heu de triar els q vosaltres creieu
audioFeatureExtraction(fileName, stWin, stStep, mtWin, mtStep, featureStatistics, featureShort);

%% 2. Per a cadascuna de les 4 iteracions del 4FCV cal fer:
for i=1:4
    %2.1 Calcular dos matrius

    %2.2 Entrenament d’un mètode de classificació

    %2.3 Classificació del conjunt de test 
end


%% 3. Mostrar els resultats d’eficiència de classificació