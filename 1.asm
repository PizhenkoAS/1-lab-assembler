%include "io64.inc"
section .data
N   dq  0   ; размер массива
s1  db  "Input size array : ", 0
s2  db  "Input   array : ", 0
s3  db  "Result  array : ", 0
ctr db  " ", 0 ; разделитель 
section .bss
arr: resd 100 ; память под массив

; печать массива
%macro PRINT_ARRAY 2    ; передаем 2 аргумента
    mov rcx, %1 ;  размер массива
    mov rsi, %2 ;  адрес массива
@print:  ; цикл вывода чисел            
    PRINT_DEC 8, [ESI] ; выводим число
    PRINT_STRING ctr   ; разделитель
    add esi, 8  ; смещаемся в массиве на 8 байт
    dec rcx     ; счетчик - 1
jnz @print      ; продолжать печать пока счетчик не 0
%endmacro

section .text
global main
main:
    mov rbp, rsp
    PRINT_STRING s1
    GET_UDEC 8, N    ; ввод числа
    PRINT_UDEC 8, N  ; выводим значение размера
    NEWLINE 
    
    ; ввод массива
    PRINT_STRING s2
    mov rcx, [N]    ; размер массива
    mov rsi, arr    ; адрес массива
input_array:   
    GET_DEC 8,[ESI] ; ввод числа
    PRINT_DEC 8, [ESI] ; печатаем его
    PRINT_STRING ctr    ; ставим разделитель
    add esi, 8  ; смещаемся на 8 байт
    dec rcx     ; счетчик -1
jnz input_array; продолжать пока не 0

; сортировка
    mov rax, 0  ; левый индекс
    mov rbx, [N]; правый индекс - 1
    dec ebx
    ; цикл сортировки
sort:
    ; если индекс левый больше правого
    cmp rax, rbx
    jae done   ; выйти из цикла
    
    ; цикл прохода слева направо
    mov rcx, rax
    right:
         ; берем значение
         mov rdx, [arr + 8*rcx]
         ; сравниваем со следующим
         cmp rdx, [arr + 8*rcx + 8]
         ; если он меньше или равен не делаем обмен
         jbe next_right 
            ; иначе меняем
            mov rdi, rcx
            sal rdi, 3
            add rdi, arr ; адрес элемента
            ; кладем в стек следующий
            push qword [rdi + 8]
            ; текущий меняем со следующим
            mov rdx, [rdi]
            mov [rdi + 8], rdx
            ; из стека пишем в текущий
            pop qword [rdi] 
         next_right:
         inc rcx    ; счетчик -1
         cmp rcx, rbx; если он меньше правого индекса
    jb right ; продолжить цикл
    dec rbx   ; правый индекс на 1 меньше
      
    ; проход справа налево
    mov rcx, rbx  
    left:
         ; берем значение
         mov rdx, [arr + 8*rcx - 8]
         ; сравниваем с текущим
         cmp rdx, [arr + 8*rcx]
         ; если он меньше, то не делаем обмен
         jb next_left 
            ; меняем местами текущий и перед ним
            ; аналогично в стек и меняем 
            mov rdi, rcx
            sal rdi, 3
            add rdi, arr
            push qword [rdi - 8]
            mov rdx, [rdi]
            mov [rdi - 8], rdx
            pop qword [rdi] 
         next_left: 
         ; счетчик -1
         dec rcx
         ; если индекс больше левой границы
         cmp rcx, rax
    ja left  ; продолжать цикл
    inc rax
    ; переход в начало цикла 
jmp sort

done: ; 
    NEWLINE
    PRINT_STRING s3
    PRINT_ARRAY [N], arr      
     
    xor rax, rax
    ret
