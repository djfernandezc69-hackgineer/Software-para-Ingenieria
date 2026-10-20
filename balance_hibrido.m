%% 
%  RETO 2 - Modelado del balance híbrido
%  Proyecto: Sistema Inteligente de Gestión Energética (SIGE)
%  Curso: Software para ingeniería (203036) - UNAD
% =====================================================================
%  Este script modela, mediante vectores fila de 24 posiciones (una por
%  cada hora del día), el comportamiento energético de una micro-red
%  híbrida (solar + eólica) frente a la demanda de una comunidad.
% 

clear; clc; close all;   % Limpia variables, consola y figuras previas

%% 1. Vector de tiempo (24 horas del día)
hora = 1:24;   % Vector fila de 24 elementos: hora 1 a hora 24

%% 2. Generación Solar (kW)
% Perfil en forma de campana: 0 kW durante la noche (horas 1-6 y 18-24),
% y una curva ascendente/descendente durante el día que alcanza su pico
% máximo (P_max_solar = 25 kW) exactamente al mediodía (hora 12).
% Se construye analíticamente con una función seno definida solo en el
% tramo diurno (horas 7 a 17).
P_max_solar = 25;                 % Potencia pico de los paneles solares (kW)
P_solar = zeros(1,24);             % Inicializa el vector en 0 (24 posiciones)
horas_dia = 7:17;                  % Horas con producción solar
% Fórmula: sin(pi*(h-6)/12) genera una campana simétrica que vale 0 en
% h=6 y h=18, y vale 1 (pico) en h=12.
P_solar(horas_dia) = P_max_solar * sin(pi*(horas_dia-6)/12);
P_solar = round(P_solar,2);        % Redondeo a 2 decimales para claridad

%% 3. Generación Eólica - Aerogeneradores (kW)
% A diferencia de la solar, fluctúa de forma irregular durante las 24
% horas (según la velocidad del viento) pero nunca supera la potencia
% máxima nominal de diseño (P_max_eolica = 15 kW).
P_max_eolica = 15;   % Potencia máxima nominal de los aerogeneradores (kW)
P_eolica = [2 2 1 2 3 4 5 9 12 7 10 6 13 8 11 9 4 8 10 7 9 2 1 3];
% Verificación automática de que ningún valor supere el límite de diseño
assert(all(P_eolica <= P_max_eolica), 'Error: la generación eólica supera P_max_eolica');

%% 4. Generación Híbrida Total (kW)
% Suma elemento a elemento (operación vectorial) de solar + eólica.
P_total = P_solar + P_eolica;

%% 5. Demanda de la Comunidad (kW)
% Perfil de consumo construido por tramos horarios según los parámetros
% de la guía:
%  - Horas 1-5 y 22-24 (consumo mínimo nocturno): 2 a 4 kW
%  - Horas 6-17 (consumo diurno, escuela y bombeo agrícola): 6 a 10 kW
%  - Horas 18-21 (pico máximo, alumbrado + retorno doméstico): hasta
%    P_max_demanda = 15 kW
P_max_demanda = 15;
P_demanda = [4 3 4 3 4 6 7 8 9 10 9 8 7 8 9 10 7 12 14 15 13 4 3 4];
assert(length(P_demanda)==24, 'El vector de demanda debe tener 24 posiciones');

%% 6. Visualización gráfica comparativa
figure('Name','Balance Energético SIGE','Color','w');
plot(hora, P_total, '-o', 'Color', [0.85 0.33 0.10], 'LineWidth', 2, ...
     'MarkerFaceColor', [0.85 0.33 0.10]);     % Curva de Generación Total
hold on;                                        % Mantiene la gráfica activa
plot(hora, P_demanda, '-s', 'Color', [0.00 0.45 0.74], 'LineWidth', 2, ...
     'MarkerFaceColor', [0.00 0.45 0.74]);      % Curva de Demanda
grid on;                                        % Cuadrícula de fondo (grid on)
title('Balance Energético de la Micro-Red Híbrida - Proyecto SIGE');
xlabel('Tiempo en horas');                      % Etiqueta eje X
ylabel('Potencia en Kilovatios');               % Etiqueta eje Y
legend('Generación Híbrida Total (Solar + Eólica)', 'Demanda de la Comunidad', ...
       'Location', 'northwest');
xlim([1 24]);
xticks(1:24);
hold off;

%% 7. Identificación de superávit y déficit (apoyo para el análisis funcional)
% Función local que clasifica cada hora como superávit o déficit
[horas_superavit, horas_deficit] = clasificar_balance(P_total, P_demanda, hora);

fprintf('Horas con SUPERÁVIT de energía (generación > demanda): %s\n', ...
        mat2str(horas_superavit));
fprintf('Horas con DÉFICIT de energía (demanda > generación, uso de baterías): %s\n', ...
        mat2str(horas_deficit));

%% =====================================================================
%  Función local: clasifica cada hora en superávit o déficit energético
% =====================================================================
function [superavit, deficit] = clasificar_balance(generacion, demanda, horas)
    % Compara elemento a elemento generación vs demanda
    balance = generacion - demanda;      % Vector de diferencia hora a hora
    superavit = horas(balance > 0);      % Horas donde la generación excede la demanda
    deficit   = horas(balance <= 0);     % Horas donde la demanda iguala o excede la generación
end
