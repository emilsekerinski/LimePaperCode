align 4
segment .data
segment .bss
segment .text
extern  switch_to_sched
extern  runqput
extern  malloc
extern Pong_pong 
; global methods declare
; global Ping_methods
global Ping_ping 
global Ping_init 
; global methods declare

Ping_init:
Ping_init_realloc:
    PUSH DWORD 4096
    CALL malloc
    ADD  ESP, 4
    CMP  DWORD EAX, 0
    JE   Ping_init_realloc
    MOV  DWORD [EAX + 4096 - 1*4], 0    ; other 
    MOV  DWORD [EAX + 4096 - 2*4], 0    ; bounces 
    MOV  DWORD [EAX + 4096 - 24 + 12], 0    ; system_next
    MOV  DWORD [EAX + 4096 - 24 + 8], 0     ; lock
    LEA  ECX,  [EAX + 4096 - 24 - 4]
    MOV  DWORD [EAX + 4096 - 24 + 4], ECX   ; Pre ESP
    LEA  ECX,  [EAX + 4096 - 24]
    MOV  DWORD [EAX + 4096 - 24], ECX       ; Pre EBP
    LEA  ECX,  [Ping_doactions]
    MOV  DWORD [EAX + 4096 - 24 - 4], ECX   ; Ping_doactions
    ADD  DWORD EAX, 4096 - 24
    PUSH DWORD EBP
    PUSH DWORD EAX
    CALL runqput
    POP  DWORD EAX
    POP  DWORD EBP
    ; init code goes here

    ; Ping_init_code

    MOV DWORD ECX, [ESP + 4]
    MOV DWORD [EAX + 16], ECX
    MOV DWORD ECX, [ESP + 8]
    MOV DWORD [EAX + 20], ECX
 
    ; init code ends here
    RET
Ping_doactions:
Ping_doactions_start:
    PUSH DWORD EBP
    ; CALL Ping_action
    CALL Ping_pong
    POP  EBP
    CALL switch_to_sched
    JMP  Ping_doactions_start
    RET  ; never be here

;define method Ping_ping
Ping_ping:
Ping_ping_start:
    MOV  DWORD ECX, [ESP + 4 + 4*1]   ; + 4 * num(para)
Ping_ping_checklock:
    MOV  DWORD EAX, 1           ;lock
    XCHG EAX, [ECX + 8]
    CMP  DWORD EAX, 0
    JNE  Ping_ping_suspend
Ping_ping_checkguard:
    ; method guard starts here
	JMP Ping_ping_succeed
    ; method guard ends here
Ping_ping_checkguard_fail:
    MOV  DWORD [ECX + 8], 0     ; unlock
Ping_ping_suspend:
    PUSH DWORD EBP
    CALL runqput
    POP  EBP
    CALL switch_to_sched
    JMP  Ping_ping_start
Ping_ping_succeed:
    ; method body starts here
    	;_startproc
; %bb.0:
	push	esi
	;_def_cfa_offset 8
	sub	esp, 16
	;_def_cfa_offset 24
	;_offset esi, -8
	mov	eax, dword   [esp + 32]
	mov	ecx, dword   [esp + 28]
	mov	edx, dword   [esp + 24]
	mov	dword   [esp + 8], ecx
	mov	ecx, dword   [esp + 24]
	mov	esi, dword   [esp + 8]
	mov	dword   [esi + 20], ecx
	mov	dword   [esp + 4], eax ; 4-byte Spill
	mov	dword   [esp], edx    ; 4-byte Spill
	add	esp, 16
	pop	esi
	;ret
.Lfunc_end0:
	;.size	Ping_ping, .Lfunc_end0-Ping_ping

    ; method body ends here
Ping_ping_unlock:
    MOV  DWORD ECX, [ESP + 4 + 4*1]   ; + 4 * num(para)
    PUSH DWORD EAX              ; for the return val
    PUSH DWORD EBP
    PUSH DWORD ECX
    CALL runqput
    POP  DWORD ECX
    POP  DWORD EBP
    POP  DWORD EAX              ; for the return val
    ; unlock
    MOV DWORD [ECX + 8], 0
Ping_ping_ret:
    RET
 
; define action
; Ping: pong 
Ping_pong:
Ping_pong_start:
    MOV  DWORD ECX, [ESP + 4]
    ; action guard start
    MOV DWORD EDX, [ECX + 20]
    CMP EDX, 0
    JG Ping_pong_succeed

    ; action guard end
Ping_pong_checkguard_fail:
	RET
Ping_pong_succeed:
    ; action body start
    	;_startproc
; %bb.0:
	push	edi
	;_def_cfa_offset 8
	push	esi
	;_def_cfa_offset 12
	sub	esp, 36
	;_def_cfa_offset 48
	;_offset esi, -12
	;_offset edi, -8
	mov	eax, dword   [esp + 52]
	mov	ecx, dword   [esp + 48]
	mov	dword   [esp + 32], eax
	mov	eax, dword   [esp + 48]
	mov	edx, dword   [esp + 48]
	mov	edx, dword   [edx + 20]
	sub	edx, 1
	mov	esi, dword   [esp + 48]
	mov	esi, dword   [esi + 16]
	mov	edi, dword   [esp + 32]
	mov	dword   [esp], eax
	mov	dword   [esp + 4], edx
	mov	dword   [esp + 8], esi
	mov	dword   [esp + 12], edi
	mov	dword   [esp + 28], ecx ; 4-byte Spill
	call	Pong_pong
	mov	eax, dword   [esp + 48]
	mov	dword   [eax + 20], 0
	add	esp, 36
	pop	esi
	pop	edi
	;ret
.Lfunc_end1:
	;.size	Ping_pong, .Lfunc_end1-Ping_pong

    ; action body end
    RET