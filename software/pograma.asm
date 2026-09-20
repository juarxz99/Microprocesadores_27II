; Autor: Israel Juárez Contreras (Adaptado para Actividad I)
; Programa para solicitar nombre, validar caracteres y contar letras sin espacios.

    .org 0000h
    
    ; Inicialización del PPI 8255 (Configuración de puertos)
    ld a, 89h         ; Configuración de modos para los puertos
    out (CW), a
    
    ; Inicializar el Stack Pointer
    ld SP, 0ffffh
    
    ; 1. Mostrar mensaje inicial para solicitar el nombre
    ld hl, text_ingrese
    call desp_text

    ; Inicializar registros para el conteo de letras
    ld b, 0           ; B funcionará como nuestro contador de letras

main_loop:
    ; 2. Leer tecla o carácter del puerto de entrada
    call lee_KEYB
    
    ; Verificar si es tecla de Enter/Fin (código 0Dh)
    cp 0Dh            
    jp z, mostrar_resultado
    
    ; 3. Validar si es un ESPACIO (Código ASCII 20h)
    cp 20h
    jp z, es_espacio

    ; Validar si es una LETRA MAYÚSCULA (de 'A' [41h] a 'Z' [5Ah])
    cp 41h
    jp c, error_caracter    ; Si es menor que '41h', no es letra válida
    cp 5Bh
    jp c, guardar_letra     ; Si está entre 41h y 5Ah, es válida

    ; Validar si es una LETRA MINÚSCULA (de 'a' [61h] a 'z' [7Ah])
    cp 61h
    jp c, error_caracter    ; Si está entre Z y a, no es válido
    cp 7Bh
    jp c, guardar_letra     ; Si está entre 61h y 7Ah, es válida

    ; Si llega aquí, significa que tecleó un número o símbolo no permitido
    jp error_caracter

es_espacio:
    ; Si es espacio, lo guardamos en la SRAM pero NO sumamos al contador de letras
    call almacenar_en_sram
    jp main_loop

guardar_letra:
    ; Es una letra válida: la guardamos en SRAM y SÍ incrementamos el contador
    call almacenar_en_sram
    inc b             ; Incrementamos el contador de letras
    jp main_loop

error_caracter:
    ; 4. Enviar mensaje de error si se teclea algo diferente a letras o espacios
    ld hl, text_error
    call desp_text
    jp main_loop

mostrar_resultado:
    ; 5. Mostrar texto final y la cantidad de letras contabilizadas
    ld hl, text_resultado
    call desp_text
    halt

; Subrutina para desplegar texto en pantalla
desp_text:
    ld a, (hl)
    cp '&'
    ret z
    out (LCD), a
    inc hl
    jp desp_text

; Subrutina para leer del teclado
lee_KEYB:
    in a, (KEYB)
    ret

; Subrutina para almacenar los datos ingresados en la SRAM a partir de F800h
almacenar_en_sram:
    ret

; ==========================================
; Segmento de Datos (Ubicado en la SRAM)
; ==========================================
    .org 0f800h
text_ingrese:   .db "Ingrese nombre y apellidos:Israel Juarez Contreras &"
text_error:     .db " Error: Solo letras y espacios &"
text_resultado: .db " Total de letras (sin espacios): &"

; Constantes de puertos mapeados a partir de 40h
LCD:    .equ 40h
KEYB:   .equ 42h
CW:     .equ 43h

    .end