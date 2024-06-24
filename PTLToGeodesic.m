% function PTLToGeodesic(~, ~)
%     Conexión a la base de datos
%     conn = database('mysql2','alexs','localhost');
% 
%     if isopen(conn)
%         Leer datos de la base de datos
%         data = fetch(conn, ['SELECT Norte, Este, Altura ' ...
%             'FROM coordenadas_ptl']);
%         close(conn);
% 
%         Extraer coordenadas
%         N = data.Norte;
%         E = data.Este;
%         altura = data.Altura;
% 
%         MeridianoC = -70; % Meridiano central en grados decimales
% 
%         Parámetros PTL
%         R = 6378000; % Radio medio
%         hptl = 600; % Altura plano PTL
%         falsoN = 7000000; % Falso Norte
%         falsoE = 200000;  % Falso Este
%         Factoresc = (R + hptl) / R; % Factor escala
% 
%         Parámetros elipsoide (WGS84)
%         a = 6378137.0; % Eje semi mayor
%         f = 1 / 298.257223563; % Achatamiento
%         e2 = 2 * f - f^2; % Excentricidad al cuadrado
% 
%         Convertir el meridiano central a radianes
%         MeridianoC = deg2rad(MeridianoC);
% 
%         Crear matrices para almacenar los resultados
%         latitudes = zeros(size(N));
%         longitudes = zeros(size(E));
% 
%         Calcular las coordenadas geodésicas a partir de PTL
%         for i = 1:length(N)
%             Convertir coord. PTL a coord. en sistema de proyección
%             N_proj = (N(i) - falsoN) / Factoresc;
%             E_proj = (E(i) - falsoE) / Factoresc;
% 
%             Aproximación inicial de la latitud meridional
%             M = N_proj;
%             mu = M / (a * (1 - e2 / 4 - 3 * e2^2 / 64 - 5 * e2^3 / 256));
%             e1 = (1 - sqrt(1 - e2)) / (1 + sqrt(1 - e2));
% 
%             Serie de Taylor inversa para obtener la latitud geodésica
%             lat1 = mu + (3 * e1 / 2 - 27 * e1^3 / 32) * sin(2 * mu) ...
%                 + (21 * e1^2 / 16 - 55 * e1^4 / 32) * sin(4 * mu) ...
%                 + (151 * e1^3 / 96) * sin(6 * mu) ...
%                 + (1097 * e1^4 / 512) * sin(8 * mu);
% 
%             Calcular parámetros necesarios
%             N1 = a / sqrt(1 - e2 * sin(lat1)^2);
%             T1 = tan(lat1)^2;
%             C1 = e2 * cos(lat1)^2 / (1 - e2);
%             R1 = a * (1 - e2) / (1 - e2 * sin(lat1)^2)^(3 / 2);
%             D = E_proj / N1;
% 
%             Calcular la latitud geodésica
%             lat = lat1 - (N1 * tan(lat1) / R1) * (D^2 / 2 - (5 + 3 * T1 + ...
%                 10 * C1 - 4 * C1^2 - 9 * e2) * D^4 / 24 ...
%                 + (61 + 90 * T1 + 298 * C1 + 45 * T1^2 - 252 * e2 - 3 * ...
%                 C1^2) * D^6 / 720);
% 
%             Calcular la longitud geodésica
%             lon = MeridianoC + (D - (1 + 2 * T1 + C1) * D^3 / 6 ...
%                 + (5 - 2 * C1 + 28 * T1 - 3 * C1^2 + 8 * e2 + 24 * T1^2) * ...
%                 D^5 / 120) / cos(lat1);
% 
%             Convertir radianes a grados
%             latitudes(i) = rad2deg(lat);
%             longitudes(i) = rad2deg(lon);
%         end
% 
%         Guardar los resultados en un archivo de texto
%         guardarArchivo('coordenadas_geodesicas.txt', latitudes, ...
%             longitudes, altura);
% 
%         Mostrar resultados
%         fprintf(['Conversión completada. Las coordenadas geodésicas se ' ...
%             'han guardado en "coordenadas_geodesicas.txt".\n']);
%     end
% end
% 
% function guardarArchivo(nombreArchivo, latitudes, longitudes, altura)
%     Guardar las coordenadas geodésicas y la altura en un archivo de texto
%     fileID = fopen(nombreArchivo, 'w');
%     for i = 1:length(latitudes)
%         fprintf(fileID, '%.6f %.6f %.2f\n', latitudes(i), longitudes(i), ...
%             altura(i));
%     end
%     fclose(fileID);
% end

function PTLToGeodesic(~, ~)
    % Permitir al usuario seleccionar un archivo
    [fileName, filePath] = uigetfile({'*.txt;*.csv', ...
        'Text and CSV files (*.txt, *.csv)'}, 'Select a file');
    if isequal(fileName, 0)
        disp('File selection canceled.');
        return;
    end
    filePath = fullfile(filePath, fileName);

     % Leer datos del archivo
    data = leerArchivo(filePath);
    
    
    % Conexión a la base de datos
    conn = database('mysql2', 'alexs', 'localhost');
    
    % Vaciar la tabla antes de insertar nuevos datos
        exec(conn, 'DELETE FROM coordenadas_ptl');

    if isopen(conn)
        % Insertar datos del archivo seleccionado en la base de datos
        insertData(conn, data);
        
        % Leer datos de la base de datos
        data = fetch(conn, ['SELECT Norte, Este, ' ...
            'Altura FROM coordenadas_ptl']);
        close(conn);

        % Extraer coordenadas
        N = data.Norte;
        E = data.Este;
        altura = data.Altura;

        % Parámetros para los cálculos geodésicos
        MeridianoC = -70; % Meridiano central en grados decimales
        R = 6378000; % Radio medio
        hptl = 600; % Altura plano PTL
        falsoN = 7000000; % Falso Norte
        falsoE = 200000;  % Falso Este
        Factoresc = (R + hptl) / R; % Factor escala

        % Parámetros elipsoide (WGS84)
        a = 6378137.0; % Eje semi mayor
        f = 1 / 298.257223563; % Achatamiento
        e2 = 2 * f - f^2; % Excentricidad al cuadrado

        % Convertir el meridiano central a radianes
        MeridianoC = deg2rad(MeridianoC);

        % Crear matrices para almacenar los resultados
        latitudes = zeros(size(N));
        longitudes = zeros(size(E));

        % Calcular las coordenadas geodésicas a partir de PTL
        for i = 1:length(N)
            % Convertir coord. PTL a coord. en sistema de proyección
            N_proj = (N(i) - falsoN) / Factoresc;
            E_proj = (E(i) - falsoE) / Factoresc;

            % Aproximación inicial de la latitud meridional
            M = N_proj;
            mu = M / (a * (1 - e2 / 4 - 3 * e2^2 / 64 - 5 * e2^3 / 256));
            e1 = (1 - sqrt(1 - e2)) / (1 + sqrt(1 - e2));
            
            % Serie de Taylor inversa para obtener la latitud geodésica
            lat1 = mu + (3 * e1 / 2 - 27 * e1^3 / 32) * sin(2 * mu) ...
                + (21 * e1^2 / 16 - 55 * e1^4 / 32) * sin(4 * mu) ...
                + (151 * e1^3 / 96) * sin(6 * mu) ...
                + (1097 * e1^4 / 512) * sin(8 * mu);

            % Calcular parámetros necesarios
            N1 = a / sqrt(1 - e2 * sin(lat1)^2);
            T1 = tan(lat1)^2;
            C1 = e2 * cos(lat1)^2 / (1 - e2);
            R1 = a * (1 - e2) / (1 - e2 * sin(lat1)^2)^(3 / 2);
            D = E_proj / N1;

            % Calcular la latitud geodésica
            lat = lat1 - (N1 * tan(lat1) / R1) * (D^2 / 2 - (5 + 3 * T1 + ...
                10 * C1 - 4 * C1^2 - 9 * e2) * D^4 / 24 ...
                + (61 + 90 * T1 + 298 * C1 + 45 * T1^2 - 252 * e2 - 3 * ...
                C1^2) * D^6 / 720);

            % Calcular la longitud geodésica
            lon = MeridianoC + (D - (1 + 2 * T1 + C1) * D^3 / 6 ...
                + (5 - 2 * C1 + 28 * T1 - 3 * C1^2 + 8 * e2 + 24 * T1^2) * ...
                D^5 / 120) / cos(lat1);

            % Convertir radianes a grados
            latitudes(i) = rad2deg(lat);
            longitudes(i) = rad2deg(lon);
        end

        % Guardar los resultados en un archivo de texto
        guardarArchivo('coordenadas_geodesicas.txt', ...
            latitudes, longitudes, altura);

        % Mostrar resultados
        fprintf(['Conversión completada. Las coordenadas geodésicas se ' ...
            'han guardado en "coordenadas_geodesicas.txt".\n']);
    end
end

function data = leerArchivo(filePath)
    [~, ~, ext] = fileparts(filePath);
    if strcmp(ext, '.txt')
        data = readtable(filePath, 'Delimiter', ' ', ...
            'Format', '%f%f%f', 'ReadVariableNames', false);
    elseif strcmp(ext, '.csv')
        data = readtable(filePath, 'Format', '%f%f%f', ...
            'ReadVariableNames', false);
    else
        error('Unsupported file format.');
    end
    data.Properties.VariableNames = {'Norte', 'Este', 'Altura'};
end

function insertData(conn, data)
    for i = 1:height(data)
        N = data.Norte(i);
        E = data.Este(i);
        altura = data.Altura(i);
        insert(conn, 'coordenadas_ptl', {'Norte', 'Este', 'Altura'}, ...
            {N, E, altura});
    end
end

function guardarArchivo(nombreArchivo, N, E, altura)
    % Guardar las coordenadas UTM y la altura en un archivo de texto
    fileID = fopen(nombreArchivo, 'w');
    for i = 1:length(N)
        fprintf(fileID, '%.4f %.4f %.4f\n', N(i), E(i), altura(i));
    end
    fclose(fileID);
end





