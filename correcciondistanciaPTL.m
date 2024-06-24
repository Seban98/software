function correcciondistanciaPTL()

    % Leer las coordenadas PTL desde el archivo generado
    data = 'coordenadas_ptl.txt';
    coords = load(data);
    N = coords(:, 1);
    E = coords(:, 2);
    h = coords(:, 3);
    hptl = 600;
    R = 6378000;

    % Inicializar las matrices para almacenar los resultados
    DPtl = zeros(length(N)-1, 1);
    Cm = zeros(length(N)-1, 1);
    difS = zeros(length(N)-1, 1);
    Dhm = zeros(length(N)-1, 1);

    % Calcular las ecuaciones para cada par de coordenadas
    for i = 1:length(N) - 1
        DPtl(i)=sqrt((N(i+1)-N(i)).^2 + (E(i+1)-E(i)).^2); % Dist plana PTL
        Cm(i) = ((h(i)+h(i+1))/2) - hptl; % Cota media respecto PTL
        difS(i) = (DPtl(i) * Cm(i)) / R; % Corrección
        Dhm(i) = DPtl(i) + difS(i); % Distancia horizontal
    end

    % Crear una tabla para almacenar los resultados
    resultados = table(DPtl, Cm, difS, Dhm, ...
                       'VariableNames', {'DPtl', 'Cm', 'difS', 'Dhm'});

    % Eliminar las filas pares
    esPar = mod(1:height(resultados), 2) == 0;
    resultados(esPar, :) = [];

    % Mostrar la tabla de resultados
    disp(resultados);

end

