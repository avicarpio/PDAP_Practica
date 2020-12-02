function [error] = searchForErrors(filename,T_error)
    %SEARCHFORERRORS Summary of this function goes here
    %   Detailed explanation goes here

    error = false;
    
    for i = 1:size(T_error,1)
        errorFile = cell2mat(T_error{i,1});
        if strcmp(filename,errorFile)
           error = true; 
        end
    end

end

