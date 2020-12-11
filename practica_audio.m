testDB = ads1;

learnDB = [ads2, ads3, ads4];

[data,dataInfo] = read(ads1);

[audio1,fs] = audioread(dataInfo.FileName);