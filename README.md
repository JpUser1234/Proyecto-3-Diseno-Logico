**Instituto Tecnológico de Costa Rica** 

Escuela de Electrónica  

**Proyecto 1**

Diseño lógico

**Elaborado por**
  
Gloriana Carrillo Cabezas 

Gabriel Chaves Esquivel

Jean Paúl Sequeira Salazar  

# Introduccion

El presente proyecto corresponde al Proyecto Corto II del curso EL-3307 Diseño Lógico, y consiste en el diseño e implementación de un sistema digital sincrónico completo utilizando SystemVerilog como lenguaje de descripción de hardware (HDL), desplegado sobre una FPGA TangNano 9K. El sistema funciona como una calculadora de suma: permite al usuario ingresar dos números decimales de hasta tres dígitos mediante un teclado hexadecimal mecánico, y muestra tanto los números ingresados como el resultado de su suma en cuatro displays de 7 segmentos. Todo el diseño sigue los principios fundamentales del diseño digital sincrónico, operando con un único reloj de 27 MHz, e incorpora técnicas de sincronización de señales asíncronas y eliminación de rebote mecánico. El desarrollo del proyecto abarcó desde el diseño de cada módulo y su verificación mediante simulaciones RTL, hasta la implementación física en protoboard y la programación de la FPGA.

# Problema

# Objetivos

# Funcionamiento general del circuito


# Diagrama de bloques de subsistemas


## Lectura del teclado
## Suma Aritmetica


<img src="LecturaVisualizacionT.jpg" width="500">

## Despliegue en 7 segmentos


<img src="HammingT.drawio.jpg" width="500">


# Diagramas de estado 

## FSM principal

## Debounce



# Ejemplo y análisis de una simulación funcional del sistema completo


# Análisis de consumo de recursos en la FPGA y el consumo de potencia

# Reporte de velocidades maximas de reloj posible en el diseño

# Principales problemas hallados durante el trabajo y soluciones aplicadas

