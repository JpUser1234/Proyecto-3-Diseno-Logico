**Instituto Tecnológico de Costa Rica** 

Escuela de Electrónica  

Prueba git

**Proyecto 2**

Diseño lógico

**Elaborado por**
  
Gloriana Carrillo Cabezas 

Gabriel Chaves Esquivel

Jean Paúl Sequeira Salazar  

# Introduccion

El presente proyecto corresponde al Proyecto Corto II del curso EL-3307 Diseño Lógico, y consiste en el diseño e implementación de un sistema digital sincrónico completo utilizando SystemVerilog como lenguaje de descripción de hardware (HDL), desplegado sobre una FPGA TangNano 9K. El sistema funciona como una calculadora de suma: permite al usuario ingresar dos números decimales de hasta tres dígitos mediante un teclado hexadecimal mecánico, y muestra tanto los números ingresados como el resultado de su suma en cuatro displays de 7 segmentos. Todo el diseño sigue los principios fundamentales del diseño digital sincrónico, operando con un único reloj de 27 MHz, e incorpora técnicas de sincronización de señales asíncronas y eliminación de rebote mecánico. El desarrollo del proyecto abarcó desde el diseño de cada módulo y su verificación mediante simulaciones RTL, hasta la implementación física en protoboard y la programación de la FPGA.

# Problema

Se requiere diseñar un dispositivo capaz de funcionar como una calculadora básica que reciba entradas asincrónicas (teclado mecánico), las procese de forma sincrónica a 27 MHz y visualice la información en hardware externo.  

# Objetivos

* Implementar un algoritmo de captura y eliminación de rebote (debouncing) para un teclado hexadecimal.
* Desarrollar un sistema de control de visualización para displays de 7 segmentos con multiplexado.
* Validar el diseño mediante simulaciones RTL y post-síntesis.

# Especificaciones

* Frecuencia de Reloj: 27 MHz.
* Entrada: Teclado hexadecimal 4x4.
* Salida: 4 displays de 7 segmentos
* Capacidad: Dos números positivos de hasta 3 dígitos cada uno (0-999).

# Funcionamiento general del circuito

El sistema implementado es una calculadora de suma de dos números decimales de hasta tres dígitos, operando completamente de forma sincrónica con un reloj único de 27 MHz proveniente de la TangNano 9K. El usuario ingresa los números mediante un teclado hexadecimal mecánico, los visualiza en tiempo real en cuatro displays de 7 segmentos mientras los digita, y obtiene el resultado de la suma al confirmar ambas entradas. El circuito se divide en tres subsistemas principales interconectados.

# Diagrama de bloques de subsistemas


## Lectura del teclado

Este subsistema se encarga de capturar de forma confiable las pulsaciones del teclado mecánico y traducirlas en dígitos decimales válidos para el resto del sistema. Está compuesto por seis módulos internos:

__Divisor de frecuencia:__ Genera un pulso de un ciclo de duración denominado tick_out, contando N ciclos del reloj de 27 MHz. Este pulso es la base de tiempo que utilizan los demás módulos para saber cuándo actualizar su estado.

__Sincronizador de señales:__ Las señales provenientes del teclado son asíncronas respecto al reloj de la FPGA, lo que puede causar metaestabilidad en los flip-flops. Para resolverlo, se encadenan dos flip-flops tipo D que retardan la señal dos ciclos de reloj, asegurando una señal limpia y estable a la salida.

__Debounce (eliminación de rebote):__ Implementa una FSM de cuatro estados (Inactivo, Contando, Activo, Rebotando) que requiere que la señal se mantenga estable durante un tiempo equivalente a DEBOUNCE_TICKS pulsos del tick antes de considerarla válida. Si la señal baja antes de ese tiempo, se trata como un rebote mecánico y se ignora.

__Scanner del teclado (contador de anillo):__ Activa cíclicamente una columna del teclado a la vez mediante el patrón 0001 → 0010 → 0100 → 1000 → 0001 → .... Cuando una fila detecta un 1, se conoce exactamente qué columna estaba activa en ese instante, identificando así la tecla presionada por su par fila-columna.

__Decodificador fila-columna:__ Recibe la fila y la columna activa y devuelve el valor numérico de la tecla presionada. Las teclas especiales tienen funciones asignadas: # confirma el primer número, A confirma el segundo número, y * limpia el sistema (reset).

__FSM de control de ingreso:__ Es el módulo central del subsistema. Acumula los dígitos ingresados desplazando el registro BCD hacia la izquierda con cada nuevo dígito, de manera análoga a una calculadora tradicional. Los números se almacenan en codificación BCD (Binary Coded Decimal) con 10 bits cada uno (3 dígitos × 4 bits, con 2 bits extra como aproximación). 


## Suma Aritmetica

Este subsistema recibe los dos números almacenados en BCD y calcula su suma. Los datos de entrada pasan primero por registros sincronizados al reloj (Reg. num1 y Reg. num2, de 10 bits BCD cada uno) antes de entrar al sumador, garantizando el comportamiento sincrónico. El sumador opera directamente en BCD, soportando hasta 4 dígitos en el resultado (máximo 999 + 999 = 1998). El resultado queda almacenado en un registro de salida también sincronizado al reloj, desde donde lo recibe el subsistema de despliegue.

<img src="LecturaVisualizacionT.jpg" width="500">

## Despliegue en 7 segmentos

Este subsistema toma los números num1, num2 y el resultado de la suma, y los muestra de forma decimal en cuatro displays físicos de 7 segmentos con cátodo común. Está formado por cuatro módulos:

__Divisor de frecuencia:__ Reduce el reloj de 27 MHz a aproximadamente 1 kHz, que es la frecuencia de refresco de los displays. A esta velocidad el ojo humano percibe todos los dígitos encendidos simultáneamente aunque solo uno esté activo a la vez.

__Contador de dígito y multiplexor 4:1:__ Un contador sincrónico del 0 al 3 selecciona cíclicamente cuál de los cuatro displays está activo. El multiplexor escoge el dígito BCD correspondiente (unidades, decenas, centenas o millares) para enviarlo al codificador.

__Control de ánodos:__ Activa únicamente el ánodo del display seleccionado. Los ánodos son activos en bajo, por lo que un 0 enciende el display y un 1 lo apaga. Solo un display está encendido en cada instante.

| Display activo | Ánodo [3:0] | Dígito mostrado |
|----------------|-------------|-----------------|
| Display "0" | 1110 | Unidades |
| Display "1" | 1101 | Decenas |
| Display "2" | 1011 | Centenas |
| Display "3" | 0111 | MIllares |

__Codificador BCD a 7 segmentos:__ Es un bloque puramente combinacional (sin reloj) que implementa una tabla de verdad directa: cada valor del 0 al 9 genera el patrón fijo de 7 bits que activa los segmentos correctos del display para representar ese dígito en decimal.

La conexión física de los displays utiliza transistores NPN como interruptores de corriente, dado que la FPGA no puede suministrar directamente la corriente necesaria para encender los LEDs. Resistencias de 220 Ω limitan la corriente por segmento (~5.9 mA) y resistencias de 1 kΩ protegen la base de los transistores (~3.3 mA), evitando sobrecargar los pines de la TangNano.

<img src="HammingT.drawio.jpg" width="500">


# Diagramas de estado 

## FSM principal

## Debounce



# Ejemplo y análisis de una simulación funcional del sistema completo


# Análisis de consumo de recursos en la FPGA y el consumo de potencia

# Reporte de velocidades maximas de reloj posible en el diseño

# Principales problemas hallados durante el trabajo y soluciones aplicadas

Durante el desarrollo del proyecto se encontraron varios problemas tanto en el hardware físico como en la programación del sistema. A continuación se describen los más relevantes y las soluciones que se aplicaron.

__Identificación incorrecta de filas y columnas del teclado__

Al conectar inicialmente el teclado hexadecimal, el decodificador fila-columna producía valores incorrectos para varias teclas. El problema era que los pines físicos del conector del teclado no correspondían al orden esperado. Para resolverlo, se leyó y estudió detenidamente el datasheet del teclado específico utilizado, lo que permitió identificar correctamente cuáles pines correspondían a filas y cuáles a columnas, y reconfigurar las conexiones en la protoboard.

__Verificación del comportamiento eléctrico de filas y columnas__

Como parte del diagnóstico del problema anterior, se utilizó un multímetro para verificar que las filas pasaban de 0 V a aproximadamente 3.3 V al presionar la tecla respectiva, confirmando así el funcionamiento correcto de las resistencias pull-down. Para las columnas, se conectaron LEDs de prueba directamente para observar visualmente si el scanner las estaba activando en el orden correcto.

__Errores en el circuito de los transistores NPN__

Los transistores NPN encargados de controlar los ánodos de los displays no conducían correctamente en algunos casos. Para diagnosticar el problema, se conectó un LED directamente en la base de cada transistor para verificar si la señal de control de la FPGA llegaba correctamente. Esto permitió identificar conexiones incorrectas en la protoboard y corregirlas.

__Problema principal: errores en el código HDL__

El problema más significativo del proyecto fue la programación en SystemVerilog. Para resolverlo se recurrió a múltiples estrategias: se revisaron los videos tutoriales recomendados por el profesor, se consultaron distintos repositorios de código abierto para entender la lógica y los procedimientos utilizados en diseños similares, y se utilizó inteligencia artificial de manera responsable, enfocándose en localizar posibles errores en el código y comprender sus soluciones, sin sustituir el proceso de diseño propio del equipo.

__Ajuste del parámetro de debounce para simulación__

El contador de debounce está diseñado para esperar aproximadamente 20 ms antes de validar una tecla, lo que equivale a unos 540,000 ciclos de reloj a 27 MHz. Este tiempo hace inviable simular el sistema completo en un tiempo razonable. La solución fue parametrizar el módulo de debounce de manera que, en el testbench, se utilice una frecuencia simulada más alta, reduciendo el contador a solo 16 ciclos en vez de miles, sin modificar el comportamiento funcional del diseño real.

# Ejercicios

## Contadores sincrónicos

## Construcción de un cerrojo Set-Reset con compuertas NAND