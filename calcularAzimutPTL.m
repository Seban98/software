function calcularAzimutPTL()
    % Leer las coordenadas PTL desde el archivo generado
    data = 'coordenadas_ptl.txt';
    coords = load(data);
    N = coords(:, 1);
    E = coords(:, 2);

    % Crear una matriz para almacenar los azimuts
    azimuts = zeros(length(N) - 1, 1);

    % Calcular los azimuts entre pares de puntos
    for i = 1:length(N) - 1
        deltaE = E(i+1) - E(i);
        deltaN = N(i+1) - N(i);
        azimut = atan2d(deltaE, deltaN);
        
        % Asegurar que el azimut esté en el rango [0, 400)
        if azimut < 0
            azimut = azimut + 400;
        end
        
        azimuts(i) = azimut;
    end

    % Filtrar los azimuts para mantener solo los impares
    azimutsImpares = azimuts(1:2:end);

    % Guardar los azimuts impares en un archivo de texto
    guardarArchivoAzimut('azimuts.txt', azimutsImpares);

    % Mostrar resultados
    fprintf(['Cálculo de azimuts completado. Los azimuts se han' ...
        'guardado en "azimuts.txt".\n']);
end

function guardarArchivoAzimut(nombreArchivo, azimuts)
    % Guardar los azimuts en un archivo de texto
    fileID = fopen(nombreArchivo, 'w');
    for i = 1:length(azimuts)
        fprintf(fileID, '%.2f\n', azimuts(i));
    end
    fclose(fileID);
end

