path = "audioDB";%Adreça a la carpeta que conté la base de dades d’àudio
methodML = "cart" ;% knn , cart , svm , gmm , 4fcv
PercentOfDataSet = 5; 
% Segons el classificador que escullen s'han d'inizialitzar els parametres
% corresponents
fs = 44.1e3;
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
        
    case '4fcv'
        knn_K = 5; 
        knn_NSMethod = 'kd-tree';
        knn_Distance = 'euclidean';
        knn_Standardize = 1;
        cart_showModel = 0;
        t = templateSVM('KernelFunction','rbf','Standardize',true);

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


switch methodML
    case 'knn' 
        %KNN Classificador
        KNN = fitcknn(learnDB,learnGT,'NumNeighbors',knn_K,'NSMethod',knn_NSMethod,'Distance',knn_Distance,'Standardize',knn_Standardize);
        fprintf('KNN Predict');
        resultatKNN = predict(KNN,testDB);
    case 'cart'
        %CART Classificador
        CART = fitctree(learnDB,learnGT);
        fprintf('CART Predict');
        resultatCART = predict(CART,testDB);
    case 'svm'
        %SVM Classificador
        svmModel = fitcecoc(learnDB,learnGT,'Learner',t);
        fprintf('SVM Predict');
        resultatSVM = predict(svmModel,testDB); 
    case 'gmm'
        %GMM Classificador

        % Definim l'array en el que registrarem els resultats
        resultsArray = cell(size(learnDB,1),1);

        % Definim l'array en el que guardarem el model de cada classe
        gmmodel = cell(15, 1);
        classTypes = ["beach","bus","cafe-restaurant","car","city_center","forest_path","grocery_store","home","library","metro_station","office","park","residential_area","train","tram"];
        % Recorrem datasets
        for k = 1:size(learnDB,1)
           % Recorrem classes
            for j = 1:length(classTypes)
                % Prenem la posició l'element respecte la classe concreta i en
                % prenem el valor
                classPosition = find( learnGT{k} == classTypes(j));
                positionValue = learnDB{k}( classPosition, :);
                % Entrenem GMM
                gmmModel{j} = fitgmdist( positionValue, 6, 'RegularizationValue', 0.1, 'CovarianceType', 'diagonal');
            end

        end
        
        fprintf('GMM Predict');
        pdfs = [];
        %Recorrem valors
        for j = 1:testSize
            % Recorrem classes
            for i = 1: numTypes
                % calculem la probabilitat del parametre amb la pdf
                pdfs(j,i) = pdf(gmmModel{i}, testDB{k}(j,:));
            end
            % Trobem valor màxim
            label(j) = find(pdfs(j, :) == max(pdfs(j, :)));
        end
        % Guardem resultat del dataset
        resultatGMM = label;
        
    case '4fcv'
        %Entrenament classificadors    

        %KNN Classificador
        KNN = fitcknn(learnDB,learnGT,'NumNeighbors',knn_K,'NSMethod',knn_NSMethod,'Distance',knn_Distance,'Standardize',knn_Standardize);

        %CART Classificador
        CART = fitctree(learnDB,learnGT);

        %SVM Classificador
        svmModel = fitcecoc(learnDB,learnGT,'Learner',t);    

        %GMM Classificador

        % Definim l'array en el que registrarem els resultats
        resultsArray = cell(size(learnDB,1),1);

        % Definim l'array en el que guardarem el model de cada classe
        gmmodel = cell(15, 1);
        classTypes = ["beach","bus","cafe-restaurant","car","city_center","forest_path","grocery_store","home","library","metro_station","office","park","residential_area","train","tram"];
        % Recorrem datasets
        for k = 1:size(learnDB,1)
           % Recorrem classes
            for j = 1:length(classTypes)
                % Prenem la posició l'element respecte la classe concreta i en
                % prenem el valor
                classPosition = find( learnGT{k} == classTypes(j));
                positionValue = learnDB{k}( classPosition, :);
                % Entrenem GMM
                gmmModel{j} = fitgmdist( positionValue, 6, 'RegularizationValue', 0.1, 'CovarianceType', 'diagonal');
            end

        end


        fprintf('KNN Predict');
        resultatKNN = predict(KNN,testDB);

        fprintf('CART Predict');
        resultatCART = predict(CART,testDB);

        fprintf('SVM Predict');
        resultatSVM = predict(svmModel,testDB); 

        fprintf('GMM Predict');
        pdfs = [];
        %Recorrem valors
        for j = 1:testSize
            % Recorrem classes
            for i = 1: numTypes
                % calculem la probabilitat del parametre amb la pdf
                pdfs(j,i) = pdf(gmmModel{i}, testDB{k}(j,:));
            end
            % Trobem valor màxim
            label(j) = find(pdfs(j, :) == max(pdfs(j, :)));
        end
        % Guardem resultat del dataset
        resultatGMM = label;
end




%% 3. Mostrar els resultats d’eficiència de classificació

encertsKNN = 0;
encertsCART = 0;
encertsSVM = 0;
encertsGMM = 0;

switch methodML
    case 'knn' 
        for j=1:length(resultatKNN)
            if resultatKNN(j) == testGT(j)
                encertsKNN = encertsKNN + 1;
            end
        end
        percentatgeEncertsKNN = encertsKNN/length(resultatKNN) * 100;
        fprintf('KNN: %.2f', percentatgeEncertsKNN);
        fprintf('\n');
    case 'cart'
        for j=1:length(resultatCART)
            if resultatCART(j) == testGT(j)
                encertsCART = encertsCART + 1;
            end
        end
        percentatgeEncertsCART = encertsCART/length(resultatCART) * 100;
        fprintf('CART: %.2f', percentatgeEncertsCART);
        fprintf('\n');
    case 'svm'
        for j=1:length(resultatSVM)
            if resultatSVM(j) == testGT(j)
                encertsSVM = encertsSVM + 1;
            end
        end
        percentatgeEncertsSVM = encertsSVM/length(resultatSVM) * 100;
        fprintf('SVM: %.2f', percentatgeEncertsSVM);
        fprintf('\n');
    case 'gmm'
        for j=1:length(resultatGMM)
            if resultatGMM(j) == testGT(j)
                encertsGMM = encertsGMM + 1;
            end
        end
        percentatgeEncertsGMM = encertsGMM/length(resultatGMM) * 100;
        fprintf('GMM: %.2f', percentatgeEncertsGMM);
        fprintf('\n');
    case '4fcv'
        for j=1:length(resultatKNN)
            if resultatKNN(j) == testGT(j)
                encertsKNN = encertsKNN + 1;
            end
        end
        percentatgeEncertsKNN = encertsKNN/length(resultatKNN) * 100;
        for j=1:length(resultatCART)
            if resultatCART(j) == testGT(j)
                encertsCART = encertsCART + 1;
            end
        end
        percentatgeEncertsCART = encertsKNN/length(resultatKNN) * 100;
        for j=1:length(resultatSVM)
            if resultatSVM(j) == testGT(j)
                encertsSVM = encertsSVM + 1;
            end
        end
        percentatgeEncertsSVM = encertsKNN/length(resultatKNN) * 100;
        for j=1:length(resultatGMM)
            if resultatGMM(j) == testGT(j)
                encertsGMM = encertsGMM + 1;
            end
        end
        percentatgeEncertsGMM = encertsKNN/length(resultatKNN) * 100;
        
        fprintf('KNN: %.2f', percentatgeEncertsKNN);
        fprintf('\n');
        fprintf('CART: %.2f', percentatgeEncertsCART);
        fprintf('\n');
        fprintf('SVM: %.2f', percentatgeEncertsSVM);
        fprintf('\n');
        fprintf('GMM: %.2f', percentatgeEncertsGMM);
        fprintf('\n');
end