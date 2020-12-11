% La funci� audiodatastore.m permet manipular grans bases de dades sense 
% necessitat que Matlab les carregui de forma expl�cita en mem�ria.

db_path = "audioDB";

ads = audioDatastore(db_path, ...
 'IncludeSubfolders',true, ...
 'FileExtensions','.wav', ...
 'LabelSource','foldernames');

% ads.Lavels -> retornar� un vector de N valors categ�rics amb el nom de la classe de cadascun dels N fitxers analitzats
% ads.Files -> retornar� el nom de cadascun dels N fitxers de la base de dades

[ads1, ads2, ads3, ads4] = splitEachLabel(ads,0.25,0.25,0.25);