% % Prueba: Insertar datos en la base de datos
% conn = database('mysql1', 'alexs', 'localhost');
% data = table([10; 20], [30; 40], [50; 60], 'VariableNames', ...
%     {'latitud', 'longitud', 'altura'});
% insertData(conn, data);
% function insertData(conn, data)
%     for i = 1:height(data)
%         latitud = data.latitud(i);
%         longitud = data.longitud(i);
%         altura = data.altura(i);
%         insert(conn, 'coordenadas', {'latitud', 'longitud', 'altura'}, ...
%             {latitud, longitud, altura});
%     end
% end
% Prueba: Guardar resultados en archivo



N = [1000; 2000];
E = [3000; 4000];
altura = [50; 60];

function guardarArchivo(~,~, ~)

    % Guardar las coordenadas UTM y la altura en un archivo de texto
    fileID = fopen('testoutput.txt', 'w');
    for i = 1:length(N)
        fprintf(fileID, '%.4f %.4f %.4f\n', N, E, altura);
    end
    fclose(fileID);


guardarArchivo('testoutput.txt', N, E, altura);

end



