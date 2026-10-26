%% CONTROLADOR SIGE - SIMULACIÓN DE 24 HORAS
clc; clear; close all;

%% 1. CONFIGURACIÓN INICIAL
% Vectores de 24 posiciones (kWh) -> REEMPLAZAR por los del Reto 2
E_solar  = [0 0 0 0 0 5 15 30 45 60 70 75 75 70 60 45 30 15 5 0 0 0 0 0];
E_eolica = [10 12 11 9 8 10 12 15 14 12 10 9 8 10 12 14 15 13 12 11 10 9 10 11];
E_dem    = [35 33 32 32 34 40 45 50 52 55 55 56 55 54 52 50 52 58 60 62 55 45 40 37];

SOC = 50;          % Estado de carga inicial de la batería (%)
Cap_bat = 100;     % Capacidad total de la batería (kWh)

%% 2. BUCLE DE SIMULACIÓN
fprintf('=== REPORTE HORARIO DEL CONTROLADOR SIGE ===\n');
for h = 1:24                              % Recorre las 24 horas
    E_gen = E_solar(h) + E_eolica(h);     % Generación híbrida total (kWh)
    balance = E_gen - E_dem(h);           % Balance energético (kWh)

    % Estado nominal de los servicios al inicio de cada hora
    escuela = "ACTIVO"; bombeo = "ACTIVO"; alumbrado = "ACTIVO";

    %% 3. LÓGICA DE DECISIÓN AUTOMATIZADA
    if E_gen >= E_dem(h)                  % ESCENARIO DE SUPERÁVIT
        excedente = E_gen - E_dem(h);     % Energía sobrante (kWh)
        SOC = SOC + (excedente / Cap_bat) * 100;  % Carga de batería
        if SOC > 100
            SOC = 100;                    % Límite máximo de seguridad
        end
        % Todos los servicios permanecen activos
    else                                  % ESCENARIO DE DÉFICIT
        faltante = E_dem(h) - E_gen;      % Energía faltante (kWh)
        SOC = SOC - (faltante / Cap_bat) * 100;   % Descarga de batería
        if SOC < 0
            SOC = 0;                      % Límite mínimo absoluto
        end

        % Load shedding según el nuevo SOC
        if SOC > 40                       % Ruta Segura
            % Todos activos
        elseif SOC > 20                   % Ruta de Alerta (20 < SOC <= 40)
            alumbrado = "SUSPENDIDO";
        else                              % Ruta de Emergencia (SOC <= 20)
            alumbrado = "SUSPENDIDO";
            bombeo = "SUSPENDIDO";
        end
    end

    %% 4. REPORTE POR CONSOLA
    fprintf('Hora %02d | Gen: %6.2f kWh | Dem: %6.2f kWh | Balance: %+7.2f kWh | SOC: %6.2f %%\n', ...
            h, E_gen, E_dem(h), balance, SOC);
    fprintf('         Escuela: %s | Bombeo: %s | Alumbrado: %s\n\n', escuela, bombeo, alumbrado);
end
