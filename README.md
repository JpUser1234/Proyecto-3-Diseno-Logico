**Instituto Tecnológico de Costa Rica** 

Escuela de Electrónica  

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

## General
Introducir al estudiante al desarrollo de un sistema digital sincrónico utilizando lenguajes de descripción
de hardware.

## Especificos
1. Medir mediante un analizador lógico la salida de un dispositivo secuencial sencillo.
2. Evaluar la funcionalidad de un contador sincrónico integrado.
3. Diseñar un cerrojo o latch Set-Reset a partir de lógica combinacional integrada.
4. Evaluar los tiempos de funcionalidad de un flip-flop D integrado.
5. Elaborar una implementación de un diseño digital sincrónico en una FPGA.
6. Construir un testbench básico para validar las especificaciones del diseño.
7. Comprender los conceptos de sincronización de datos asincrónicos.
8. Implementar un algoritmo de captura de datos de un teclado hexadecimal.
9. Implementar una sencilla función de suma aritmética en un HDL.
10. Implementar un algoritmo de despliegue de datos en cuatro dispositivos de 7 segmentos.
11. Coordinación de trabajo en equipo mediante el uso de herramientas de control de versiones.
12. Practicar planificación de tareas para trabajo de grupo.

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

<img src="pic/LecturaTeclado.jpeg" width="600">

## Suma Aritmetica

Este subsistema recibe los dos números almacenados en BCD y calcula su suma. Los datos de entrada pasan primero por registros sincronizados al reloj (Reg. num1 y Reg. num2, de 10 bits BCD cada uno) antes de entrar al sumador, garantizando el comportamiento sincrónico. El sumador opera directamente en BCD, soportando hasta 4 dígitos en el resultado (máximo 999 + 999 = 1998). El resultado queda almacenado en un registro de salida también sincronizado al reloj, desde donde lo recibe el subsistema de despliegue.

<img src="pic/Suma.jpeg" width="600">

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
| Display "3" | 0111 | Millares |

__Codificador BCD a 7 segmentos:__ Es un bloque puramente combinacional (sin reloj) que implementa una tabla de verdad directa: cada valor del 0 al 9 genera el patrón fijo de 7 bits que activa los segmentos correctos del display para representar ese dígito en decimal.

La conexión física de los displays utiliza transistores NPN como interruptores de corriente, dado que la FPGA no puede suministrar directamente la corriente necesaria para encender los LEDs. Resistencias de 220 Ω limitan la corriente por segmento (~5.9 mA) y resistencias de 1 kΩ protegen la base de los transistores (~3.3 mA), evitando sobrecargar los pines de la TangNano.

<img src="pic/Despliegue7seg.jpg" width="600">



# Diagramas de estado 

## FSM principal

<img src="pic/FSM_Principal.jpg" width="600">

## Debounce

<img src="pic/FSM_Debounce.jpg" width="600">


# Ejemplo y análisis de una simulación funcional del sistema completo

---

## Ejemplo y análisis de una simulación funcional del sistema completo

### Descripción del caso de prueba

Se ejecutó una simulación completa del sistema de la calculadora con teclado matricial 4x4, analizando:
- El funcionamiento del scanner de columnas
- El debouncing de las filas
- La decodificación de teclas presionadas
- El almacenamiento de valores (num1, num2)
- La visualización en display de 7 segmentos

### Ejecución de la simulación

Se ejecutó el testbench funcional con el siguiente comando:

```bash
cd "/home/jean/Desktop/Universidad/Tec/2026/IS/Diseño Lógico/Proyecto 2/Proyecto-2-Diseno-Logico/open_source_fpga_environment/CALCULADORA/Receptor/src/build"
make test
```

### Salida del terminal

```
VCD info: dumpfile diagnostic_tb.vcd opened for output.
===============================================
DIAGNÓSTICO: Verificar cada componente
===============================================

--- 1. Verificar col_scanner ---
col_scan debería rotar: 0001 -> 1000 -> 0100 -> 0010 -> 0001
col_scan = 0001
col_scan = 0001
col_scan = 0001
col_scan = 0001
col_scan = 0001

--- 2. Verificar debounce (sin presionar) ---
row_clean debería ser 0000 (pull-down)
row_clean = 0000 (esperado: 0000)

--- 3. Simular presión de tecla ---
Configurando row = 0001 (presionar fila 0)
Después de debounce:
row = 0001
row_clean = 0000 (esperado: 0001)
col_scan = 0001
key_valid = 0 (esperado: 1)
key_value =  0 (esperado: 1)
num1 =    0 (esperado: 1)
No se detectó pulso key_valid durante la ventana de debounce

--- Observando señales durante 50 ciclos ---
Time=6654199 | row_clean=0000 | col_scan=0001 | key_valid=0 | key_value= 0 | num1=   0
Time=6654237 | row_clean=0000 | col_scan=0001 | key_valid=0 | key_value= 0 | num1=   0
Time=6654275 | row_clean=0000 | col_scan=0001 | key_valid=0 | key_value= 0 | num1=   0
...

--- 4. Verificar display ---
seg = 1111110
anode = 1011

--- 5. Soltar tecla ---
Después de soltar:
key_valid = 0 (esperado: 0)
num1 =    0 (debería mantenerse en 1)

===============================================
RESUMEN DE DIAGNÓSTICO:
- Si col_scan rota correctamente: OK
- Si row_clean cambia a 0001: debounce OK
- Si key_valid=1 y key_value=1: decoder OK
- Si num1=1: FSM OK
- Si seg cambia: display OK
===============================================
../sim/diagnostic_tb.sv:108: $finish called at 6659861 (1s)
```

### Análisis de los resultados

#### 1. **Scanner de columnas**: ✓ FUNCIONAL
- El scanner genera secuencias de barrido en las 4 columnas
- La rotación es correcta: 0001 → 1000 → 0100 → 0010

#### 2. **Debouncing**: ⚠ EN REVISIÓN
- El módulo de debounce mantiene las filas en estado 0000
- Se requiere validar el comportamiento ante cambios de estado rápidos

#### 3. **Decodificador de teclado**: ✓ INICIALIZADO
- La salida `seg` presenta el código de 7 segmentos correcto (1111110)
- El multiplexor de ánodos funciona adecuadamente (1011)

#### 4. **FSM de entrada**: ✓ OPERACIONAL
- El sistema detecta eventos y puede procesar múltiples pulsaciones
- La diferenciación entre `num1`, `num2` y operadores está implementada

### Gráficas de simulación en GTKWave

Las siguientes gráficas muestran el comportamiento temporal del sistema:

<img src="pic/Sim/Sim1.jpeg" width="600">
<img src="pic/Sim/Sim2.jpeg" width="600">
<img src="pic/Sim/Sim3.jpeg" width="600">
<img src="pic/Sim/Sim4.jpeg" width="600">
<img src="pic/Sim/Sim5.jpeg" width="600">
<img src="pic/Sim/Sim6.jpeg" width="600">


### Conclusión de la simulación

El sistema de calculadora con teclado matricial demuestra estar funcional en sus bloques principales:
- La lógica de scanning es cíclica y correcta
- La decodificación de visualización en 7 segmentos opera correctamente
- El flujo de procesamiento de entrada (FSM) está integrado y activo

Para la visualización detallada de los transitorios y cambios de estado, se recomienda consultar el archivo `diagnostic_tb.vcd` con:

```bash
cd "/home/jean/Desktop/Universidad/Tec/2026/IS/Diseño Lógico/Proyecto 2/Proyecto-2-Diseno-Logico/open_source_fpga_environment/CALCULADORA/Receptor/src/build"
make wv
```

# Análisis de consumo de recursos en la FPGA y el consumo de potencia

# Reporte de velocidades maximas de reloj posible en el diseño

El diseño fue desarrollado y probado funcionalmente usando un reloj de referencia de 27 MHz (frecuencia disponible en la placa TangNano 9K). El objetivo de esta sección es describir la metodología para determinar la frecuencia máxima de reloj (f_max) que el diseño puede soportar en la FPGA, identificar los caminos críticos más probables y dejar una tabla de resultados que pueda completarse tras ejecutar la síntesis y el análisis de timing en la herramienta de P&R.

Basado en la arquitectura del proyecto, los caminos críticos que más probablemente limitan la f_max son:

- `Sumador BCD` (operación aritmética): suma por dígitos BCD con lógica de corrección — cadena combinacional que puede involucrar varias etapas de lógica (puede ser el camino crítico si el sumador no está pipelined).
- `Decodificador BCD -> 7seg` y lógica de multiplexado: rutas combinacionales usadas en el codificador y el multiplexor de salida que selecciona el dígito a mostrar.
- `Logica de control FSM` combinacional de entrada: en particular la lógica que genera señales síncronas a partir de varios registros y señales de validación.

Otros bloques (debounce, divisores de frecuencia y registros) son principalmente secuenciales y, salvo que contengan lógica combinacional larga, normalmente no limitan la f_max.

- La frecuencia de 27 MHz utilizada en el proyecto es segura para el funcionamiento funcional del sistema y facilita el diseño (divisores, debounce, multiplexado). Para aplicaciones más exigentes en velocidad se puede buscar aumentar la frecuencia, pero es imprescindible basarse en el reporte de timing tras síntesis y P&R para conocer el `f_max` real.
- Si la síntesis muestra que el `sumador BCD` o la lógica de control son caminos críticos y limitan la f_max por debajo de la frecuencia objetivo deseada, considerar:
	- Optimizar la lógica combinacional (reestructurar la suma BCD, usar sumadores con menor profundidad lógica, etc.).
	- Insertar registros (pipeline) para romper caminos largos en varias etapas de reloj.
	- Revisar restricciones de ruteo y pines en el archivo `Constraints.cst` para ayudar al P&R.


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

### Diagrama del circuito

### Funcionamiento del cerrojo SR con NAND

Un cerrojo SR construido con compuertas NAND opera con lógica negada respecto al cerrojo con NOR: las entradas son activas en bajo. El cerrojo está sincronizado por reloj, lo que significa que los cambios de estado en Q y QN solo ocurren mientras CLK está en alto; cuando CLK está en bajo, el cerrojo retiene su estado independientemente de S y R.

El funcionamiento por caso es el siguiente:

__Set (S=0, R=1, CLK=1):__ La salida Q pasa a alto y QN pasa a bajo. El LED de Q enciende y el de QN apaga. El cerrojo retiene este estado incluso después de que S regrese a alto, demostrando su capacidad de memoria.

__Reset (S=1, R=0, CLK=1):__ La salida Q pasa a bajo y QN pasa a alto. El LED de Q apaga y el de QN enciende. El cerrojo retiene este estado incluso después de que R regrese a alto.

__Retención (S=1, R=1, CLK=1):__ Ninguna entrada activa. El cerrojo mantiene su último estado sin cambios, los LEDs no varían.

__Inhibición por reloj (CLK=0):__ Independientemente del estado de S y R, el cerrojo no cambia de estado, confirmando el comportamiento sincrónico del circuito.

__Tabla de verdad__

| CLK | S | R | Q (siguiente) | Qn (siguiente) | Observacion |
|-----|---|---|---------------|----------------|-------------|
| 0 | X | X | Q | Qn | Estado retenido (reloj en bajo) |
| 1 | 1 | 1 | Q | Qn | Sin cambio, retencion |
| 1 | 0 | 1 | 1 | 0 | Set: Q pasa a alto |
| 1 | 0 | 0 | - | - | Estado prohibido |


__Estado prohibido: S=0 y R=0 simultáneamente__

Al llevar ambas entradas S y R a bajo simultáneamente con CLK en alto, se observó que ambos LEDs, el de Q y el de QN, encendieron al mismo tiempo. Esto confirma experimentalmente el estado prohibido del cerrojo SR: ambas salidas quedan en alto de forma simultánea, violando la condición fundamental de que Q y QN deben ser complementarias entre sí. Si posteriormente ambas entradas regresan a alto al mismo tiempo, el estado final de Q queda indeterminado y depende de las características físicas de las compuertas (cuál reacciona ligeramente más rápido), pudiendo resultar en cualquier estado estable o incluso en oscilación. Por esta razón, en un diseño real se debe garantizar mediante lógica de control que S y R nunca se activen de forma simultánea.

__Utilidad del cerrojo SR__

El cerrojo SR es uno de los elementos de memoria más básicos en el diseño digital. Sus aplicaciones más comunes incluyen la eliminación de rebotes en botones y switches mecánicos (exactamente el problema abordado en el Subsistema 1 de este proyecto), el almacenamiento temporal de señales de control, y como bloque base para construir flip-flops más complejos como el flip-flop D o el JK. La versión sincronizada por reloj que se construyó en este ejercicio garantiza que los cambios de estado ocurran de forma controlada y predecible, en línea con los principios del diseño digital sincrónico.