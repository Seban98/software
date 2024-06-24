% function geodesicToPTL(~, ~)
%     %Conexión a la base de datos
%     conn = database('mysql1','alexs','localhost');
% 
%     if isopen(conn)
%         % Leer datos de la base de datos
%         data = fetch(conn, ['SELECT latitud, longitud, altura ' ...
%             'FROM coordenadas']);
%         close(conn);
% 
%         % Extraer coordenadas
%         latitudes = data.latitud;
%         longitudes = data.longitud;
%         altura = data.altura;
% 
%         MeridianoC = -70; % Meridiano central 
% 
%         % Parámetros PTL
%         R = 6378000; % Radio medio
%         hptl = 600; % Altura plano PTL
%         falsoN = 7000000; % Falso Norte
%         falsoE = 200000;  % Falso Este
%         Factoresc = (R+hptl)/R; % Factor escala
% 
%         % Parámetros elipsoide (WGS84)
%         a = 6378137.0; % Eje semi mayor
%         f = 1 / 298.257223563; % achatamiento
%         e2 = 2*f - f^2; % excentricidad al cuadrado
% 
%         % Convertir el meridiano central a radianes
%         MeridianoC = deg2rad(MeridianoC);
% 
%         % Crear matrices para almacenar los resultados
%         N = zeros(size(latitudes));
%         E = zeros(size(longitudes));
% 
%         % Convertir cada par de coordenadas
%         for i = 1:length(latitudes)
%             lat = latitudes(i);
%             lon = longitudes(i);
% 
%             % Convertir latitud y longitud a radianes
%             lat = deg2rad(lat);
%             lon = deg2rad(lon);
% 
%             % Diferencia de longitud con el meridiano central
%             deltaLambda = lon - MeridianoC;
% 
%             % Calcular parámetros necesarios
%             N1 = a / sqrt(1 - e2 * sin(lat)^2);
%             T = tan(lat)^2;
%             C = e2 * cos(lat)^2 / (1 - e2);
%             A = deltaLambda * cos(lat);
% 
%             % Calcular coordenadas Norte (N) y Este (E)
%             M = a * ((1 - e2/4 - 3*e2^2/64 - 5*e2^3/256) * lat ...
%                    - (3*e2/8 + 3*e2^2/32 + 45*e2^3/1024) * sin(2*lat) ...
%                    + (15*e2^2/256 + 45*e2^3/1024) * sin(4*lat) ...
%                    - (35*e2^3/3072) * sin(6*lat));
% 
%             N(i) = falsoN + Factoresc * (M + N1 * tan(lat) * (A^2/2 + ...
%                 (5 - T + 9*C + 4*C^2) * A^4/24 + (61 - 58*T + T^2 + ...
%                 600*C - 330*e2) * A^6/720));
%             E(i) = falsoE + Factoresc * N1 * (A + (1 - T + C) * A^3/6 + ...
%                 (5 - 18*T + T^2 + 72*C - 58*e2) * A^5/120);
%         end
% 
%         % Guardar los resultados en un archivo de texto
%         guardarArchivo('coordenadas_ptl.txt', N, E, altura);
% 
%         % Mostrar resultados
%         fprintf(['Conversión completada. Las coordenadas PTL se han ' ...
%             'guardado en "coordenadas_ptl.txt".\n']);
%     end
% end
% 
% function guardarArchivo(nombreArchivo, N, E, altura)
%     % Guardar las coordenadas UTM y la altura en un archivo de texto
%     fileID = fopen(nombreArchivo, 'w');
%     for i = 1:length(N)
%         fprintf(fileID, '%.2f %.2f %.2f\n', N(i), E(i), altura(i));
%     end
%     fclose(fileID);
% end


function geodesicToPTL(~, ~)
    % Permitir al usuario seleccionar un archivo
    [fileName, filePath] = uigetfile({'*.txt;*.csv', ...
        'Text and CSV files (*.txt, *.csv)'}, 'Select a file');
    if isequal(fileName, 0)
        disp('Selección de archivo cancelada.');
        return;
    else 
        disp('Selección de archivo correcto');
    end
    filePath = fullfile(filePath, fileName);
    
    % Leer datos del archivo
    data = leerArchivo(filePath);
    
    % Conexión a la base de datos
    conn = database('mysql1', 'alexs', 'localhost');
    if isopen(conn)
        disp('Conexión a la base de datos exitosa.');
        
        % Vaciar la tabla antes de insertar nuevos datos
        try
            exec(conn, 'DELETE FROM coordenadas');
            disp('Tabla "coordenadas" vaciada correctamente.');
        catch ME
            disp(['Error al vaciar la tabla "coordenadas": ', ME.message]);
            close(conn);
            return;
        end
        
        % Almacenar los datos en la base de datos
        insertData(conn, data);
        
        % Leer datos de la base de datos
        data = fetch(conn, ['SELECT latitud, longitud, altura ' ...
            'FROM coordenadas']);
        close(conn);
        
        % Extraer coordenadas
        latitudes = data.latitud;
        longitudes = data.longitud;
        altura = data.altura;
        
        MeridianoC = -70; % Meridiano central
        
        % Parámetros PTL
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
        N = zeros(size(latitudes));
        E = zeros(size(longitudes));
        
        % Convertir cada par de coordenadas
        for i = 1:length(latitudes)
            lat = latitudes(i);
            lon = longitudes(i);
            
            % Convertir latitud y longitud a radianes
            lat = deg2rad(lat);
            lon = deg2rad(lon);
            
            % Diferencia de longitud con el meridiano central
            deltaLambda = lon - MeridianoC;
            
            % Calcular parámetros necesarios
            N1 = a / sqrt(1 - e2 * sin(lat)^2);
            T = tan(lat)^2;
            C = e2 * cos(lat)^2 / (1 - e2);
            A = deltaLambda * cos(lat);
            
            % Calcular coordenadas Norte (N) y Este (E)
            M = a * ((1 - e2 / 4 - 3 * e2^2 / 64 - 5 * e2^3 / 256) * lat ...
                   - (3 * e2 / 8 + 3 * e2^2 / 32 + 45 * e2^3 / 1024) ...
                   * sin(2 * lat) ...
                   + (15 * e2^2 / 256 + 45 * e2^3 / 1024) * sin(4 * lat) ...
                   - (35 * e2^3 / 3072) * sin(6 * lat));
            
            N(i) = falsoN + Factoresc * (M + N1 * tan(lat) * (A^2 / 2 + ...
                (5 - T + 9 * C + 4 * C^2) * A^4 / 24 + (61 - 58 * T ...
                + T^2 + ...
                600 * C - 330 * e2) * A^6 / 720));
            E(i) = falsoE + Factoresc * N1 * (A + (1 - T + C) * A^3 / 6 + ...
                (5 - 18 * T + T^2 + 72 * C - 58 * e2) * A^5 / 120);
        end
        
        % Guardar los resultados en un archivo de texto
        guardarArchivo('coordenadas_ptl.txt', N, E, altura);
        
        % Mostrar resultados
        fprintf(['Conversión completada. Las coordenadas PTL se han ' ...
            'guardado en "coordenadas_ptl.txt".\n']);
    else
        disp('Error al conectar a la base de datos.');
    end
end

function data = leerArchivo(filePath)
    [~, ~, ext] = fileparts(filePath);
    if strcmp(ext, '.txt')
        data = readtable(filePath, 'Delimiter', ' ', 'Format', ...
            '%f%f%f', 'ReadVariableNames', false);
    elseif strcmp(ext, '.csv')
        data = readtable(filePath, 'Format', '%f%f%f', ...
            'ReadVariableNames', false);
    else
        error('Unsupported file format.');
    end
    data.Properties.VariableNames = {'latitud', 'longitud', 'altura'};
end

function insertData(conn, data)
    for i = 1:height(data)
        latitud = data.latitud(i);
        longitud = data.longitud(i);
        altura = data.altura(i);
        insert(conn, 'coordenadas', {'latitud', 'longitud', 'altura'}, ...
            {latitud, longitud, altura});
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

