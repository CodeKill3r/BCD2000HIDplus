; File Name   :	tusb_8051_raw.bin
; Format      :	Binary file
; Base Address:	0000h Range: 0000h - 0C16h Loaded length: 0C16h

; Processor	  : 8032 [RAM=256 ROM=0	EPROM=0	EEPROM=0]
; Target assembler: 8051 Cross-Assembler by MetaLink Corporation
; Byte sex	  : Big	endian

; ===========================================================================

; Segment type:	Pure code
		;.segment code
		CSEG

; =============== S U B	R O U T	I N E =======================================

; RESET
; Attributes: thunk

		; public RESET
org RESET
		ljmp	RESET_0
; End of function RESET


; =============== S U B	R O U T	I N E =======================================


		; public IE0
org EXTI0
		ljmp	IE0_0
; End of function IE0


; =============== S U B	R O U T	I N E =======================================


usbPrepResp:				; CODE XREF: usbreqgetstat+1Cp
					; usbreqgetstat+32p ...
		setb	C
		mov	A, R5		; desc_len_L
		subb	A, wLenRamL
		mov	A, R4		; desc_len_H
		subb	A, wLenRamH
		jnc	desctoolong	; desc len >= req len
		mov	usbRespLenH, R4
		mov	usbRespLenL, R5
		sjmp	code_1B
; ---------------------------------------------------------------------------

desctoolong:				; CODE XREF: usbPrepResp+7j
		mov	usbRespLenH, wLenRamH ;	if descriptor too long,	only reply the requested length
		mov	usbRespLenL, wLenRamL

		; public code_1B
code_1B:				; CODE XREF: usbPrepResp+Dj
		mov	usbRespCfg, R3
		mov	usbRespH, R2
		mov	usbRespL, R1
		ret
; End of function usbPrepResp


; =============== S U B	R O U T	I N E =======================================


nullsub_1:				; CODE XREF: RESET_0-32Ap
		ret
; End of function nullsub_1


; =============== S U B	R O U T	I N E =======================================

; Serial port interrupt
; Attributes: thunk

		; public RI_TI
RI_TI:
		ljmp	RI_TI_0		; Serial IO handler
; End of function RI_TI			;
					; Serial_in -> MIDI-OUT
					; MIDI-IN -> Serial_out

; =============== S U B	R O U T	I N E =======================================


serBtoUsbMidOut:			; CODE XREF: RESET_0-306p
		clr	GlobStat.6	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	RAM_13,	#1	; ext RAM
		mov	RAM_14,	#0F8h ;	'ř' ; usbMidiOutBufH
		mov	RAM_15,	#50h ; 'P' ; usbMidiOutBufL
		jnb	GlobSt2t.4, code_7A ; 4: setup long response
					; 5: debug response
		mov	R3, RAM_13
		mov	R2, RAM_14
		mov	R1, RAM_15	; 0 byte -- 0
		clr	A		; clr @(usbMidiOutBuf)
		lcall	writeAToBuff	; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		mov	R3, RAM_13
		mov	R2, RAM_14
		mov	R1, RAM_15	; 8 byte -- 0
		mov	DPTR, #8	; clr @(usbMidiOutBuf+8)
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		mov	DPTR, #10h	; 0x10 byte -- 0xFF
		mov	A, #0FFh	; @(usbMidiOutBuf+0x10)= 0xFF
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		mov	DPTR, #11h	; 0x11 byte -- 0xFF
		mov	A, #0FFh	; @(usbMidiOutBuf+0x11)= 0xFF
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		mov	DPTR, #13h	; 0x13 byte -- 0
		clr	A
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		mov	DPTR, #14h	; 0x14 byte -- 0 = no debug
		clr	A
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		clr	GlobSt2t.4	; 4: setup long	response
					; 5: debug response
		mov	DPTR, #16h
		mov	A, #1
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		mov	DPTR, #17h	; 0x17 byte -- 3
		mov	A, #3
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write

code_7A:				; CODE XREF: serBtoUsbMidOut+Bj
		jnb	GlobStat.3, code_C5 ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	GlobStat.3	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		lcall	getRxBuf_size
		mov	RAM_12,	R7
		mov	A, RAM_12
		jz	code_C5		; rx buffer size = 0
		setb	GlobStat.6	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	A
		mov	RAM_11,	A

midiOutCpLoop:				; CODE XREF: serBtoUsbMidOut+92j
		mov	A, RAM_11
		clr	C
		subb	A, RAM_12
		jnc	code_BA		; jmp if RAM_11	(buff_ptr) > RAM_12 (buff_length)
		mov	A, RAM_11
		clr	C
		subb	A, #7
		jnc	code_BA		; jmp if RAM_11	(buff_ptr) > 7
		lcall	readMidiOutBuf	; read a MIDI_OUT_BUF byte to R7
					;    inc SerMidiOutPtr
					; 0xFF if empty
		mov	R3, RAM_13
		mov	A, RAM_15	; ptrL
		add	A, #1
		mov	R1, A
		clr	A
		addc	A, RAM_14	; ptrH
		mov	R2, A		; R2:R1=RAM_14:RAM_15+1
		mov	A, RAM_11
		mov	R4, #0
		add	A, R1
		mov	R1, A
		mov	A, R4
		addc	A, R2
		mov	R2, A		; R2:R1+=RAM_11	(buff_ptr)
		mov	A, R7
		lcall	writeAToBuff	; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		inc	RAM_11
		sjmp	midiOutCpLoop
; ---------------------------------------------------------------------------

code_BA:				; CODE XREF: serBtoUsbMidOut+6Cj
					; serBtoUsbMidOut+73j
		mov	R3, RAM_13
		mov	R2, RAM_14
		mov	R1, RAM_15
		mov	A, RAM_11	; 0 byte -- response MIDI length (1-8)
		lcall	writeAToBuff	; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write

code_C5:				; CODE XREF: serBtoUsbMidOut:code_7Aj
					; serBtoUsbMidOut+60j
		jnb	GlobSt2t.5, code_DA ; 4: setup long response
					; 5: debug response
		clr	GlobSt2t.5	; 4: setup long	response
					; 5: debug response
		mov	R3, RAM_13
		mov	R2, RAM_14
		mov	R1, RAM_15
		mov	DPTR, #14h	; 0x14 byte -- 0xF3 = debug response
		mov	A, #0F3h ; 'ó'
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		setb	GlobStat.6	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter

code_DA:				; CODE XREF: serBtoUsbMidOut:code_C5j
		jnb	GlobStat.6, code_F6 ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	R7, RAM_1C
		inc	RAM_1C
		mov	R3, RAM_13
		mov	R2, RAM_14
		mov	R1, RAM_15
		mov	DPTR, #12h	; 0x12 byte -- debug counter
		mov	A, R7		; rolling counter @ 0x12
		lcall	writeAToBuDPTR	; Write	A to (R2:R1)+DPTR or R1+DPL
					; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- write	RAM (R1)
					;  0x01	- write	ext RAM	(R2:R1)
					;  0xFE	- write	ext RAM	(R1)
					;  other - no write
		setb	GlobSt2t.4	; 4: setup long	response
					; 5: debug response
		mov	DPTR, #IEPDCNTX1 ; In endpoint 1 - X buffer data count byte
		mov	A, #3Ch	; '<'   ; data counter = 0x3C
					; no NACK
		movx	@DPTR, A

code_F6:				; CODE XREF: serBtoUsbMidOut:code_DAj
		ret
; End of function serBtoUsbMidOut


; =============== S U B	R O U T	I N E =======================================


usb_in_ep0:				; CODE XREF: code_507p
		mov	A, RAM_4B

code_F9:
		jz	code_107
		clr	A
		mov	RAM_4B,	A

code_FE:
		mov	A, RAM_47
		xrl	A, #3
		jz	code_107

code_104:
		ljmp	code_1B1
; ---------------------------------------------------------------------------

code_107:				; CODE XREF: usb_in_ep0:code_F9j
					; usb_in_ep0+Bj
		mov	A, RAM_47
		xrl	A, #1
		jnz	code_110
		ljmp	code_1B1
; ---------------------------------------------------------------------------

code_110:				; CODE XREF: usb_in_ep0+14j
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		jnb	ACC.3, code_11A	; Accumulator
		ljmp	code_1B1
; ---------------------------------------------------------------------------

code_11A:				; CODE XREF: usb_in_ep0+1Dj
		mov	A, RAM_4E
		xrl	A, #1
		jnz	code_14A
		mov	A, RAM_47
		xrl	A, #3
		jnz	code_146
		lcall	usbTxResp_iep0	; Input	Endpoint 0 response copy to USB	Buffer
					; in chunks of 8 bytes
					;
					; return status	in R7
					;  1 = Tx ended
					;  0 = Tx pending
		mov	A, R7
		xrl	A, #1
		jnz	code_192
		mov	RAM_47,	#7
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8		; in endp 0 Stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		anl	A, #0F7h ; '÷'  ; out endp 0 Not Stall
		movx	@DPTR, A
		mov	DPTR, #OEPDCNTX0 ; Out endpoint	0 - X buffer data count	byte
		clr	A		; out endp 0 buff clear
		movx	@DPTR, A
		sjmp	code_192
; ---------------------------------------------------------------------------

code_146:				; CODE XREF: usb_in_ep0+2Dj
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_192
; ---------------------------------------------------------------------------

code_14A:				; CODE XREF: usb_in_ep0+27j
		mov	A, RAM_4E
		xrl	A, #2
		jnz	code_190
		mov	A, RAM_47
		cjne	A, #6, code_16B
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8		; in endp 0 Stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #8		; out endp 0 Stall
		movx	@DPTR, A
		sjmp	code_192
; ---------------------------------------------------------------------------

code_16B:				; CODE XREF: usb_in_ep0+5Bj
		mov	A, RAM_47
		cjne	A, #8, code_18C
		mov	DPTR, #USBFADR	; USB function address register
		mov	A, wValRamL
		movx	@DPTR, A
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8		; in endp 0 Stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #8		; out endp 0 Stall
		movx	@DPTR, A
		sjmp	code_192
; ---------------------------------------------------------------------------

code_18C:				; CODE XREF: usb_in_ep0+76j
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_192
; ---------------------------------------------------------------------------

code_190:				; CODE XREF: usb_in_ep0+57j
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter

code_192:				; CODE XREF: usb_in_ep0+35j
					; usb_in_ep0+4Dj ...
		jnb	GlobStat.2, code_1B1 ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		clr	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		mov	A, #80h	; '€'
		movx	@DPTR, A	; NACK -- X buff empty
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8		; in endp 0 Stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #8		; out endp 0 Stall
		movx	@DPTR, A

code_1B1:				; CODE XREF: usb_in_ep0:code_104j
					; usb_in_ep0+16j ...
		ret
; End of function usb_in_ep0


; =============== S U B	R O U T	I N E =======================================


usbMidiInToSerB:			; CODE XREF: RESET_0-310p
		mov	DPTR, #OEPDCNTX1 ; Out endpoint	1 - X buffer data count	byte
		movx	A, @DPTR
		mov	RAM_11,	A
		mov	A, RAM_11
		jb	ACC.7, oep1_nack ; jump	if NACK	set
		ljmp	subret
; ---------------------------------------------------------------------------

oep1_nack:				; CODE XREF: usbMidiInToSerB+8j
		anl	RAM_11,	#7Fh ; '' ; X buff count
		mov	DPTR, #usbBufMidiIn ; @(OEPBBAX1) -- message type:
					; 3 -- MIDI message
					; 7 -- usb response debug enable ?
					; 9 -- set mic en/dis
					; 0x23 -- fw update
					; A or any other -- dummy data/empty
		movx	A, @DPTR
		mov	RAM_14,	A
		mov	A, RAM_11
		setb	C
		subb	A, #10h
		jnc	code_1D3	; jump if X buff cnt > 0x10
		ljmp	clrBuff
; ---------------------------------------------------------------------------

code_1D3:				; CODE XREF: usbMidiInToSerB+1Cj
		mov	A, RAM_14
		xrl	A, #3
		jnz	usbBmidiNot3	; @(usbBufMidiIn) != 0x03    (possible HID mode?)
					; 9==set mic mode -- @(usbBufMidiIn+2)>0 == mic	enabled
					; A==dummy data/empty
					; 0x23==fw update
		mov	DPTR, #usbMidiLen ; @(usbBufMidiIn+2) -- midi message length
		movx	A, @DPTR
		mov	RAM_11,	A
		clr	A
		mov	RAM_12,	A

midiInCpLoop:				; CODE XREF: usbMidiInToSerB+74j
		mov	A, RAM_12
		clr	C
		subb	A, RAM_11
		jnc	clrBuff		; jump if RAM_12 >= @(usbBufMidiIn+2)
		mov	A, #13h
		add	A, RAM_12
		mov	DPL, A		; Data Pointer,	Low Byte
		clr	A
		addc	A, #0F8h ; 'ř'
		mov	DPH, A		; Data Pointer,	High Byte
		movx	A, @DPTR	; usbBufMidiIn+3 + RAM_12
		mov	RAM_13,	A
		jnb	ACC.7, code_207	; Midi data byte
		cjne	A, #0C0h, code_201 ; 'Ŕ' ; jmp if not MIDI ch0 Program change message
		mov	R7, #1
		sjmp	code_203
; ---------------------------------------------------------------------------

code_201:				; CODE XREF: usbMidiInToSerB+48j
		mov	R7, #0

code_203:				; CODE XREF: usbMidiInToSerB+4Dj
		mov	pgmchng, R7	; store	for later if it	was a Pgm chng or not
		sjmp	nopgmchg
; ---------------------------------------------------------------------------

code_207:				; CODE XREF: usbMidiInToSerB+45j
		mov	A, RAM_13
		clr	C
		subb	A, #2
		jnc	nopgmchg	; jmp if RAM_13>1
		mov	A, pgmchng
		jz	nopgmchg	; jmp if there was no Midi ch0 Pgm chng	message
		mov	A, RAM_13
		setb	C
		subb	A, #0
		jc	code_21C
		setb	C		; mic enabled
		sjmp	code_21D
; ---------------------------------------------------------------------------

code_21C:				; CODE XREF: usbMidiInToSerB+65j
		clr	C		; mic disabled

code_21D:				; CODE XREF: usbMidiInToSerB+68j
		mov	P1.1, C		; set mic mode

nopgmchg:				; CODE XREF: usbMidiInToSerB+53j
					; usbMidiInToSerB+5Aj ...
		mov	R7, RAM_13
		lcall	writeMidiInBuf	; write	R7 to MIDI_IN_BUF
					;    inc SerMidiInPtr
		inc	RAM_12
		sjmp	midiInCpLoop
; ---------------------------------------------------------------------------

usbBmidiNot3:				; CODE XREF: usbMidiInToSerB+25j
		mov	A, RAM_14
		cjne	A, #7, micmode
		setb	GlobSt2t.5	; usb response debug enable ?
		sjmp	clrBuff
; ---------------------------------------------------------------------------

micmode:				; CODE XREF: usbMidiInToSerB+78j
		mov	A, RAM_14
		cjne	A, #9, usbBmidiNot9
		mov	DPTR, #0F812h
		movx	A, @DPTR
		jnz	micenable	; jmp if @(usbBuffMidi+2) > 0
		clr	P1.1		; mic disabled
		sjmp	clrBuff
; ---------------------------------------------------------------------------

micenable:				; CODE XREF: usbMidiInToSerB+88j
		setb	P1.1		; mic enabled
		sjmp	clrBuff
; ---------------------------------------------------------------------------

usbBmidiNot9:				; CODE XREF: usbMidiInToSerB+81j
		mov	A, RAM_14
		xrl	A, #0Ah
		jz	clrBuff
		mov	A, RAM_14
		cjne	A, #23h, clrBuff ; '#'
		lcall	fwUpdate

clrBuff:				; CODE XREF: usbMidiInToSerB+1Ej
					; usbMidiInToSerB+35j ...
		mov	DPTR, #OEPDCNTX1 ; Out endpoint	1 - X buffer data count	byte
		clr	A
		movx	@DPTR, A

subret:					; CODE XREF: usbMidiInToSerB+Bj
		ret
; End of function usbMidiInToSerB


; =============== S U B	R O U T	I N E =======================================


usb_setup_st:				; CODE XREF: code_510p
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		anl	A, #0F7h ; '÷'  ; not stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		anl	A, #0F7h ; '÷'  ; not stall
		movx	@DPTR, A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #20h	; ' '   ; set toggle (?)
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #20h	; ' '   ; set toggle (?)
		movx	@DPTR, A
		mov	DPTR, #OEPDCNTX0 ; Out endpoint	0 - X buffer data count	byte
		clr	A		; X buff empty
		movx	@DPTR, A
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		mov	A, #80h	; '€'   ; NACK -- X buff empty
		movx	@DPTR, A
		clr	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	A
		mov	RAM_4C,	A
		mov	DPTR, #bmRequestType ; identifies the characteristics of the request
		movx	A, @DPTR
		mov	bmReqRam, A
		inc	DPTR		; bRequest
		movx	A, @DPTR
		mov	bReqRam, A
		inc	DPTR		; wValue
		movx	A, @DPTR
		mov	wValRamL, A
		inc	DPTR		; wValue
		movx	A, @DPTR
		mov	wValRamH, A
		inc	DPTR		; wIndex
		movx	A, @DPTR
		mov	wIdxRamL, A
		inc	DPTR		; wIndex
		movx	A, @DPTR
		mov	wIdxRamH, A
		inc	DPTR		; wLength
		movx	A, @DPTR
		mov	wLenRamL, A
		inc	DPTR		; wLength
		movx	A, @DPTR
		mov	wLenRamH, A
		mov	A, RAM_47
		xrl	A, #7
		jz	code_2B1
		mov	A, RAM_47
		cjne	A, #3, code_2B4

code_2B1:				; CODE XREF: usb_setup_st+52j
		mov	RAM_46,	#1

code_2B4:				; CODE XREF: usb_setup_st+56j
		mov	A, RAM_47
		xrl	A, #6
		jz	code_2BF
		mov	A, RAM_47
		cjne	A, #4, code_2C2

code_2BF:				; CODE XREF: usb_setup_st+60j
		mov	RAM_4B,	#1

code_2C2:				; CODE XREF: usb_setup_st+64j
		mov	A, bmReqRam
		jnb	ACC.7, code_2D9	; Accumulator
		mov	RAM_47,	#5
		mov	RAM_4E,	#1
		lcall	usbrequest
		mov	A, RAM_47
		cjne	A, #3, code_2F8
		lcall	usbTxResp_iep0	; Input	Endpoint 0 response copy to USB	Buffer
					; in chunks of 8 bytes
					;
					; return status	in R7
					;  1 = Tx ended
					;  0 = Tx pending
		ret
; ---------------------------------------------------------------------------

code_2D9:				; CODE XREF: usb_setup_st+6Cj
		mov	A, wLenRamL
		orl	A, wLenRamH
		jnz	code_2E9
		mov	RAM_47,	#4
		mov	RAM_4E,	#2
		lcall	usbrequest
		ret
; ---------------------------------------------------------------------------

code_2E9:				; CODE XREF: usb_setup_st+85j
		mov	RAM_47,	#2
		mov	RAM_4E,	#2
		mov	usbRespLenH, wLenRamH
		mov	usbRespLenL, wLenRamL
		clr	A
		mov	RAM_4C,	A

code_2F8:				; CODE XREF: usb_setup_st+7Aj
		ret
; End of function usb_setup_st


; =============== S U B	R O U T	I N E =======================================


usb_out_ep0:				; CODE XREF: code_502p
		mov	A, RAM_46
		jz	code_309
		clr	A
		mov	RAM_46,	A
		mov	A, RAM_47
		xrl	A, #2
		jz	code_309
		ljmp	usboe0_ret
; ---------------------------------------------------------------------------

code_309:				; CODE XREF: usb_out_ep0+2j
					; usb_out_ep0+Bj
		mov	A, RAM_47
		xrl	A, #1
		jnz	code_312
		ljmp	usboe0_ret
; ---------------------------------------------------------------------------

code_312:				; CODE XREF: usb_out_ep0+14j
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		mov	R7, A
		jb	ACC.3, usboe0_ret ; Accumulator
		mov	A, RAM_4E
		xrl	A, #1
		jnz	code_345
		mov	A, RAM_47
		xrl	A, #7
		jz	code_32B
		mov	A, RAM_47
		cjne	A, #3, code_341

code_32B:				; CODE XREF: usb_out_ep0+2Bj
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		mov	A, R7
		orl	A, #8
		movx	@DPTR, A
		sjmp	code_36B
; ---------------------------------------------------------------------------

code_341:				; CODE XREF: usb_out_ep0+2Fj
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_36B
; ---------------------------------------------------------------------------

code_345:				; CODE XREF: usb_out_ep0+25j
		mov	A, RAM_4E
		xrl	A, #2
		jnz	code_369
		mov	A, RAM_47
		cjne	A, #2, code_365
		lcall	code_949
		mov	A, R7
		jnz	code_35A
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_36B
; ---------------------------------------------------------------------------

code_35A:				; CODE XREF: usb_out_ep0+5Bj
		cjne	R7, #1,	code_36B
		mov	RAM_47,	#4
		lcall	usbrequest
		sjmp	code_36B
; ---------------------------------------------------------------------------

code_365:				; CODE XREF: usb_out_ep0+54j
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_36B
; ---------------------------------------------------------------------------

code_369:				; CODE XREF: usb_out_ep0+50j
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter

code_36B:				; CODE XREF: usb_out_ep0+46j
					; usb_out_ep0+4Aj ...
		jnb	GlobStat.2, usboe0_ret ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		mov	A, #80h	; '€'
		movx	@DPTR, A
		mov	DPTR, #OEPDCNTX0 ; Out endpoint	0 - X buffer data count	byte
		clr	A
		movx	@DPTR, A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #8
		movx	@DPTR, A

usboe0_ret:				; CODE XREF: usb_out_ep0+Dj
					; usb_out_ep0+16j ...
		ret
; End of function usb_out_ep0


; =============== S U B	R O U T	I N E =======================================


setCodecDma:				; CODE XREF: usbreqsetcnf+3p
		mov	DPTR, #CPTCTL	; CODEC	port interface control and status register
		mov	A, #1		; CODEC	reset
		movx	@DPTR, A
		mov	DPTR, #OEPCNF2	; Out endpoint 2 - configuration byte
		mov	A, #0C7h ; 'Ç'  ; endp2 enable -- isocho -- 8bytes/sample
		movx	@DPTR, A
		inc	DPTR		; OEPBBAX2
		mov	A, #20h	; ' '   ; X buffer @ 0x100
		movx	@DPTR, A
		inc	DPTR		; OEPBSIZ2
		mov	A, #30h	; '0'   ; buff size=48*8 =384 bytes (0x180)
		movx	@DPTR, A
		inc	DPTR		; OEPDCNTX2
		clr	A		; no NACK -- X buff empty
		movx	@DPTR, A
		mov	DPTR, #OEPBBAY2	; Out endpoint 2 - Y buffer base address byte
		mov	A, #50h	; 'P'   ; Y buffer @ 0x280
		movx	@DPTR, A
		mov	DPTR, #OEPDCNTY2 ; Out endpoint	2 - Y buffer data count	byte
		clr	A
		movx	@DPTR, A	; no NACK -- Y buff empty
		mov	DPTR, #IEPCNF3	; In endpoint 3	- configuration	byte
		mov	A, #0C7h ; 'Ç'  ; endp2 enable -- isocho -- 8bytes/sample
		movx	@DPTR, A
		inc	DPTR		; IEPBBAX3
		mov	A, #80h	; '€'   ; X buffer @ 0x400
		movx	@DPTR, A
		inc	DPTR		; IEPBSIZ3
		mov	A, #30h	; '0'   ; buff size=48*8 =384 bytes (0x180)
		movx	@DPTR, A
		inc	DPTR		; IEPDCNTX3
		mov	A, #80h	; '€'   ; NACK -- X buff empty
		movx	@DPTR, A
		mov	DPTR, #IEPBBAY3	; In endpoint 3	- Y buffer base	address	byte
		mov	A, #0B0h ; '°'  ; Y buffer & 0x580
		movx	@DPTR, A
		mov	DPTR, #IEPDCNTY3 ; In endpoint 3 - Y buffer data count byte
		mov	A, #80h	; '€'   ; NACK -- Y buff empty
		movx	@DPTR, A
		mov	DPTR, #GLOBCTL	; Global control register
		movx	A, @DPTR
		anl	A, #0FEh ; 'ţ'  ; disable CODEC port
		movx	@DPTR, A
		mov	DPTR, #CPTCNF1	; CODEC	port interface configuration register 1
		mov	A, #0Dh		; 2 time slot/frame -- i2s mode	- 2 ser	out & 2	in (mode5)
		movx	@DPTR, A
		mov	DPTR, #CPTCNF2	; CODEC	port interface configuration register 2
		mov	A, #0CDh ; 'Í'  ; 32 CSCLK cycles for time slot 0 -- 16bits/time slot
					;	32 CSCLK cycles	per time slot
		movx	@DPTR, A
		mov	DPTR, #CPTCNF3	; CODEC	port interface configuration register 3
		mov	A, #0BCh ; 'Ľ'  ; 1 CSCLK cyc delay from CSYNC -- no padding if audio frame invalid
					;      CSCLK on	negative edge -- CSYNC active high
					;      CSYNC length=time slot0 -- byte order flip by DMA
					;      CSCLK & CSYNC ==	output (from tusb)
		movx	@DPTR, A
		mov	DPTR, #CPTCNF4	; CODEC	port interface configuration register 4
		mov	A, #3		; CLK source from divM -- CSCLK	div = div by 4
		movx	@DPTR, A
		mov	DPTR, #DMATSH0	; DMA channel 0	time slot assignment register (high byte)
		mov	A, #40h	; '@'   ; 2 bytes per slot
		movx	@DPTR, A
		inc	DPTR		; DMATSL0
		mov	A, #33h	; '3'   ; time slots 5-4 & 1-0 are supported
		movx	@DPTR, A
		mov	DPTR, #DMACTL0	; DMA channel 0	control	register
		mov	A, #82h	; '‚'   ; DMA enabled -- no wrap -- USB in -- endp 2
		movx	@DPTR, A
		mov	DPTR, #DMATSH1	; DMA channel 1	time slot assignment register (high byte)
		mov	A, #40h	; '@'   ; 2 bytes per slot
		movx	@DPTR, A
		inc	DPTR		; DMATSL1
		mov	A, #33h	; '3'
		movx	@DPTR, A	; time slots 5-4 & 1-0 are supported
		mov	DPTR, #DMACTL1	; DMA channel 1	control	register
		mov	A, #8Bh	; '‹'   ; DMA enabled -- no wrap -- USB out -- endp 3
		movx	@DPTR, A
		mov	DPTR, #DMACTL2	; DMA channel 2	control	register
		clr	A		; clear	DMA2 & 3
		movx	@DPTR, A
		inc	DPTR
		movx	@DPTR, A
		inc	DPTR
		movx	@DPTR, A
		inc	DPTR
		movx	@DPTR, A
		inc	DPTR
		movx	@DPTR, A
		inc	DPTR
		movx	@DPTR, A
		mov	DPTR, #GLOBCTL	; Global control register
		movx	A, @DPTR
		orl	A, #1		; enable CODEC port
		movx	@DPTR, A
		ret
; End of function setCodecDma


; =============== S U B	R O U T	I N E =======================================


usb_init:				; CODE XREF: RESET_0-333p
		mov	DPTR, #ACGFRQ2	; Adaptive clock generator frequency register (byte 2)
		mov	A, #6Ah	; 'j'
		movx	@DPTR, A
		inc	DPTR		; ACGFRQ1
		mov	A, #4Bh	; 'K'
		movx	@DPTR, A
		inc	DPTR		; ACGFRQ0  --  26.5734MHz
		mov	A, #20h	; ' '
		movx	@DPTR, A
		mov	DPTR, #ACGDCTL	; Adaptive clock generator divider control register
		mov	A, #10h		; MCLKO	/2   --- MCLKI /1 (no div)
		movx	@DPTR, A
		mov	DPTR, #ACGCTL	; Adaptive clock generator control register
		mov	A, #44h	; 'D'   ; MCLKO enable -- MCLK_cpt=MCLKO -- MCLK_inp=MCLKI -- divider_en
		movx	@DPTR, A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		mov	A, #84h	; '„'   ; endp enable -- not isocho -- interrupt enable
		movx	@DPTR, A
		inc	DPTR		; IEPBBAX0
		mov	A, #1		; X buff addr= 0x08
		movx	@DPTR, A
		inc	DPTR		; IEPBSIZ0
		movx	@DPTR, A	; X & Y	buff size=8 bytes
		inc	DPTR		; IEPDCNTX0
		mov	A, #80h	; '€'   ; NACK -- X buff empty
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		mov	A, #84h	; '„'   ; endp enable -- not isocho -- interrupt enable
		movx	@DPTR, A
		inc	DPTR		; OEPBBAX0
		clr	A		; X buff addr= 0x00
		movx	@DPTR, A
		inc	DPTR		; OEPBSIZ0
		inc	A		; X & Y	buff size=8 bytes
		movx	@DPTR, A
		inc	DPTR		; OEPDCNTX0
		clr	A		; no NACK -- X buff empty
		movx	@DPTR, A
		mov	DPTR, #IEPCNF1	; In endpoint 1	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #IEPCNF2	; In endpoint 0	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #IEPCNF3	; In endpoint 3	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #IEPCNF4	; In endpoint 4	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #IEPCNF5	; In endpoint 5	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #IEPCNF6	; In endpoint 6	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #IEPCNF7	; In endpoint 7	- configuration	byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF1	; Out endpoint 1 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF2	; Out endpoint 2 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF3	; Out endpoint 3 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF4	; Out endpoint 4 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF5	; Out endpoint 5 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF6	; Out endpoint 6 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #OEPCNF7	; Out endpoint 7 - configuration byte
		movx	@DPTR, A	; endp disabled
		mov	DPTR, #USBFADR	; USB function address register
		movx	@DPTR, A	; USB func addr	reset to 0x00
		mov	DPTR, #USBIMSK	; USB interrupt	mask register
		mov	A, #0F5h ; 'ő'  ; eanble USB interrupts except pseudo start-of-frame
		movx	@DPTR, A
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		clr	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	RAM_4B,	A
		mov	RAM_46,	A
		clr	IE.7
		clr	TCON.0		; Timer	0/1 Control Register
		setb	IE.0
		setb	IE.7
		mov	DPTR, #USBCTL	; USB control register
		mov	A, #0D0h ; 'Đ'  ; USB connect -- function enable -- function reset enable
		movx	@DPTR, A
		ret
; End of function usb_init


; =============== S U B	R O U T	I N E =======================================


IE0_0:					; CODE XREF: IE0j
		push	ACC		; Accumulator
		push	B		; B Register
		push	DPH		; Data Pointer,	High Byte
		push	DPL		; Data Pointer,	Low Byte
		push	PSW		; Program Status Word Register
		mov	PSW, #0		; Program Status Word Register
		push	RAM_0
		push	RAM_1
		push	RAM_2
		push	RAM_3
		push	RAM_4
		push	RAM_5
		push	RAM_6
		push	RAM_7
		clr	IE.7
		mov	DPTR, #VECINT	; interrupt vector register
		movx	A, @DPTR	; save interrupt type to A
		mov	R7, A		; copy A to R7
		lcall	find_inth_addr	; starting from	DPTR find int_type
; End of function IE0_0			;
					; if ((DPTR*) or ((DPTR+1)*))
					;    if	((DPTR+2)* == int_type)
					;	jmp ( (DPTR*)<<8 || ((DPTR+1)*)	)
					;    else
					;	DPTR+=3
					; else
					;    DPTR+=2
					;    jmp ( (DPTR*)<<8 || ((DPTR+1)*) )
					;
					; interrupt table items
					;  0xHH	-- handler address high
					;  0xLL	-- handler address low
					;  0xtt	-- intterrupt type
					;
					; if there is a	0x0000 address word in the table
					; then jump to the next	address	word
; ---------------------------------------------------------------------------
int_vect_table:	dw code_502
		db    0			; USB out endpoint 0
		dw code_50C
		db 1			; USB out endpoint 1
		dw code_507
		db    8			; USB in endpoint 0
		dw code_510
		db  12h			; USB setup stage transaction
		dw code_52C
		db  13h			; USB pseudo start-of-frame
		dw code_52C
		db  14h			; USB start-of-frame
		dw code_527
		db  15h			; USB function resume
		dw code_522
		db  16h			; USB function suspended
		dw usb_rst
		db  17h			; USB function reset
		db    0			; end_of table
		db    0
		dw cleanup_n_reti	; default handler

; =============== S U B	R O U T	I N E =======================================


code_502:				; DATA XREF: code:int_vect_tableo
		lcall	usb_out_ep0
		sjmp	cleanup_n_reti
; End of function code_502


; =============== S U B	R O U T	I N E =======================================


code_507:				; DATA XREF: code:000004E9o
		lcall	usb_in_ep0
		sjmp	cleanup_n_reti
; End of function code_507


; =============== S U B	R O U T	I N E =======================================


code_50C:				; DATA XREF: code:000004E6o
		inc	usb_out_ep1
		sjmp	cleanup_n_reti
; End of function code_50C


; =============== S U B	R O U T	I N E =======================================


code_510:				; DATA XREF: code:000004ECo
		lcall	usb_setup_st
		sjmp	cleanup_n_reti
; End of function code_510


; =============== S U B	R O U T	I N E =======================================


usb_rst:				; DATA XREF: code:000004FBo
		jnb	GlobStat.0, code_51E ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	GlobSt2t.7	; 4: setup long	response
					; 5: debug response
		clr	GlobStat.0	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	cleanup_n_reti
; ---------------------------------------------------------------------------

code_51E:				; CODE XREF: usb_rstj
		setb	GlobStat.0	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	cleanup_n_reti
; End of function usb_rst


; =============== S U B	R O U T	I N E =======================================


code_522:				; DATA XREF: code:000004F8o
		lcall	usb_fnc_sus
		sjmp	cleanup_n_reti
; End of function code_522


; =============== S U B	R O U T	I N E =======================================


code_527:				; DATA XREF: code:000004F5o
		lcall	usb_fnc_rsm
		sjmp	cleanup_n_reti
; End of function code_527


; =============== S U B	R O U T	I N E =======================================


code_52C:				; DATA XREF: code:000004EFo
					; code:000004F2o
		inc	RAM_4D
		clr	GlobSt2t.7	; 4: setup long	response
					; 5: debug response

cleanup_n_reti:				; CODE XREF: code_502+3j code_507+3j ...
		mov	DPTR, #VECINT	; interrupt vector register
		clr	A
		movx	@DPTR, A
		setb	IE.7
		pop	RAM_7
		pop	RAM_6
		pop	RAM_5
		pop	RAM_4
		pop	RAM_3
		pop	RAM_2
		pop	RAM_1
		pop	RAM_0
		pop	PSW		; Program Status Word Register
		pop	DPL		; Data Pointer,	Low Byte
		pop	DPH		; Data Pointer,	High Byte
		pop	B		; B Register
		pop	ACC		; Accumulator
		reti
; End of function code_52C


; =============== S U B	R O U T	I N E =======================================


fwUpdate:				; CODE XREF: usbMidiInToSerB+9Dp
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		clr	A
		movx	@DPTR, A
		mov	R7, A

code_558:				; CODE XREF: fwUpdate+7j
		inc	R7
		cjne	R7, #14h, code_558
		mov	DPTR, #I2CADR	; I2c interface	address	register
		mov	A, #0A0h ; ' '  ; write to EEPROM
		movx	@DPTR, A
		clr	A
		mov	R7, A

code_564:				; CODE XREF: fwUpdate+13j
		inc	R7
		cjne	R7, #14h, code_564
		mov	DPTR, #usbMidiLen ; EEPROM address high
		movx	A, @DPTR
		mov	DPTR, #I2CDATO	; I2C interface	Transmit data register
		movx	@DPTR, A

i2cWforTxAH:				; CODE XREF: fwUpdate+24j
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		movx	A, @DPTR
		anl	A, #28h	; '('
		jz	i2cWforTxAH
		clr	A
		mov	R7, A

code_57A:				; CODE XREF: fwUpdate+29j
		inc	R7
		cjne	R7, #14h, code_57A
		mov	DPTR, #usbMidiDatStrt ;	EEPROM address low
		movx	A, @DPTR

code_582:				; I2C interface	Transmit data register
		mov	DPTR, #I2CDATO
		movx	@DPTR, A

i2cWforTxAL:				; CODE XREF: fwUpdate+3Aj
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		movx	A, @DPTR
		anl	A, #28h	; '('
		jz	i2cWforTxAL
		clr	A
		mov	R7, A

code_590:				; CODE XREF: fwUpdate+3Fj
		inc	R7
		cjne	R7, #14h, code_590
		clr	A
		mov	R6, A

i2cWrLoop:				; CODE XREF: fwUpdate+62j
		mov	A, #14h		; Send 0x0F (0x00-0x0E)	bytes of data to EEPROM
		add	A, R6
		mov	DPL, A		; Data Pointer,	Low Byte
		clr	A
		addc	A, #0F8h ; 'ř'
		mov	DPH, A		; Data Pointer,	High Byte
		movx	A, @DPTR
		mov	DPTR, #I2CDATO	; I2C interface	Transmit data register
		movx	@DPTR, A

code_5A5:				; CODE XREF: fwUpdate+59j
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		movx	A, @DPTR
		anl	A, #28h	; '('
		jz	code_5A5
		clr	A
		mov	R7, A

code_5AF:				; CODE XREF: fwUpdate+5Ej
		inc	R7
		cjne	R7, #14h, code_5AF
		inc	R6
		cjne	R6, #0Fh, i2cWrLoop
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		mov	A, #1		; stop write transaction after the next	byte
		movx	@DPTR, A
		clr	A
		mov	R7, A

code_5BF:				; CODE XREF: fwUpdate+6Ej
		inc	R7
		cjne	R7, #14h, code_5BF
		mov	DPTR, #fwUpdLastByte ; last byte (0x0F)	of data	to EEPROM
		movx	A, @DPTR
		mov	DPTR, #I2CDATO	; I2C interface	Transmit data register
		movx	@DPTR, A

code_5CB:				; CODE XREF: fwUpdate+7Fj
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		movx	A, @DPTR
		anl	A, #28h	; '('
		jz	code_5CB
		clr	A
		mov	R7, A

code_5D5:				; CODE XREF: fwUpdate+84j
		inc	R7
		cjne	R7, #14h, code_5D5
		mov	DPTR, #I2CCTL	; I2C interface	control	and status register
		clr	A
		movx	@DPTR, A
		ret
; End of function fwUpdate

; ---------------------------------------------------------------------------
dev_descr:	db 12h			; DATA XREF: usbreqgetdescr+18o
					; usbreqgetdescr+1Bo ...
		db    1
		db    0
		db    1
		db    0
		db    0
		db    0
		db    8
		db  97h	; —
		db  13h
		db 0BDh	; ˝
		db    0
		db    0
		db    0
		db    1
		db    2
		db    0
		db    1
conf_descr:	db    9			; DATA XREF: usbreqgetdescr+18o
					; usbreqgetdescr+1Bo ...
		db    2
		db  2Eh	; .
		db    0
		db    1
		db    1
		db    0
		db  80h	; €
		db  32h	; 2
intf_descr:	db    9
		db    4
		db    0
		db    0
		db    4
		db 0FFh
		db    0
		db    0
		db    0
ep_descr_01_ito:db    7
		db    5
		db    1
		db    3
		db  40h	; @
		db    0
		db    1
ep_descr_81_iti:db    7
		db    5
		db  81h	; 
		db    3
		db  40h	; @
		db    0
		db    1
ep_descr_02_iso:db    7
		db    5
		db    2
		db    1
		db  80h	; €
		db    1
		db    1
ep_descr_83_isi:db    7
		db    5
		db  83h	; 
		db    1
		db  80h	; €
		db    1
		db    1
string_descr:	db    4			; DATA XREF: usbreqgetdescr:usbgetconfo
					; usbreqgetdescr+3Ao ...
					; bLength
		db    3			; bDescriptorType = String
		db    9			; LangID_lo
		db    4			; LangID_hi
strBehringer:	db  24h	; $		; DATA XREF: usbstrdesc+12o
					; usbstrdesc+14o ...
					; bLength
		db    3			; bDescriptorType
aBehringer:	db 'B',0,'e',0,'h',0,'r',0,'i',0,'n',0,'g',0,'e',0,'r',0,' ',0,' ',0,' ',0,' ',0,' '
		db 0,' ',0,' ',0,' ',0
strBcd2000:	db  1Ah			; DATA XREF: usbstrdesc+25o
					; usbstrdesc+27o ...
					; bLength
		db    3			; bDescriptorType
aBcd2000:	db 'B',0,'C',0,'D',0,'2',0,'0',0,'0',0,'0',0,' ',0,' ',0,' ',0,' ',0,' ',0

; =============== S U B	R O U T	I N E =======================================


usbreqclose:				; CODE XREF: usbreqgetstat+21p
					; usbreqgetstat+37p ...
		mov	A, RAM_4E
		xrl	A, #1
		jnz	code_68B
		mov	A, RAM_47
		xrl	A, #5
		jnz	code_687
		mov	A, R7
		jnz	code_683
		mov	RAM_47,	#3
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		anl	A, #0F7h	; not stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		anl	A, #0F7h	; not stall
		movx	@DPTR, A
		sjmp	code_6B3
; ---------------------------------------------------------------------------

code_683:				; CODE XREF: usbreqclose+Dj
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_6B3
; ---------------------------------------------------------------------------

code_687:				; CODE XREF: usbreqclose+Aj
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_6B3
; ---------------------------------------------------------------------------

code_68B:				; CODE XREF: usbreqclose+4j
		mov	A, RAM_4E
		xrl	A, #2
		jnz	code_6B1
		mov	A, RAM_47
		cjne	A, #4, code_6AD
		mov	A, R7
		jnz	code_6A9
		mov	RAM_47,	#6
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #8		; stall
		movx	@DPTR, A
		sjmp	code_6B3
; ---------------------------------------------------------------------------

code_6A9:				; CODE XREF: usbreqclose+36j
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_6B3
; ---------------------------------------------------------------------------

code_6AD:				; CODE XREF: usbreqclose+32j
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		sjmp	code_6B3
; ---------------------------------------------------------------------------

code_6B1:				; CODE XREF: usbreqclose+2Ej
		setb	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter

code_6B3:				; CODE XREF: usbreqclose+20j
					; usbreqclose+24j ...
		jnb	GlobStat.2, code_6D6 ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	GlobStat.2	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	RAM_47,	#1
		clr	A
		mov	RAM_4E,	A
		mov	DPTR, #OEPDCNTX0 ; Out endpoint	0 - X buffer data count	byte
		movx	@DPTR, A	; X buff empty
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		mov	A, #80h	; '€'   ; NACK  -- X buff empty
		movx	@DPTR, A
		mov	DPTR, #IEPCNF0	; In endpoint 0	- configuration	byte
		movx	A, @DPTR
		orl	A, #8		; stall
		movx	@DPTR, A
		mov	DPTR, #OEPCNF0	; Out endpoint 0 - configuration byte
		movx	A, @DPTR
		orl	A, #8		; stall
		movx	@DPTR, A

code_6D6:				; CODE XREF: usbreqclose:code_6B3j
		ret
; End of function usbreqclose


; =============== S U B	R O U T	I N E =======================================


usbreqgetstat:				; CODE XREF: usbreqhndlr:usbrgetstatp
		mov	A, bmReqRam
		anl	A, #1Fh
		dec	A
		jz	code_6FC
		dec	A
		jz	code_712
		add	A, #2
		jnz	code_745
		mov	RAM_2A,	RAM_4F
		clr	A
		mov	RAM_2B,	A
		mov	R3, A
		mov	R2, #0
		mov	R1, #2Ah ; '*'
		mov	R5, #2
		mov	R4, A
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_6FC:				; CODE XREF: usbreqgetstat+5j
		clr	A
		mov	RAM_2A,	A
		mov	RAM_2B,	A
		mov	R3, A
		mov	R2, #0
		mov	R1, #2Ah ; '*'
		mov	R5, #2
		mov	R4, A
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_712:				; CODE XREF: usbreqgetstat+8j
		mov	R7, wIdxRamL
		lcall	code_BCE
		mov	A, R7
		jnz	code_720
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_720:				; CODE XREF: usbreqgetstat+41j
		mov	R7, wIdxRamL
		sjmp	code_724
; ---------------------------------------------------------------------------

code_724:				; CODE XREF: usbreqgetstat+4Bj
		mov	A, RAM_2A
		jnb	ACC.0, code_72E	; Accumulator
		mov	RAM_2A,	#1
		sjmp	code_731
; ---------------------------------------------------------------------------

code_72E:				; CODE XREF: usbreqgetstat+4Fj
		clr	A
		mov	RAM_2A,	A

code_731:				; CODE XREF: usbreqgetstat+55j
		clr	A
		mov	RAM_2B,	A
		mov	R3, A
		mov	R2, #0
		mov	R1, #2Ah ; '*'
		mov	R5, #2
		mov	R4, A
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_745:				; CODE XREF: usbreqgetstat+Cj
		mov	R7, #1
		lcall	usbreqclose
		ret
; End of function usbreqgetstat


; =============== S U B	R O U T	I N E =======================================

; R2 ptrH
; R1 ptrL
; R3 mode select:
;  0x00	- read RAM (R1)
;  0x01	- read ext RAM (R2:R1)
;  0xFE	- read ext RAM (R1)
;  other - read	Code ROM (R2:R1)

readBuffToA:				; CODE XREF: usbTxResp_iep0+1Fp
		cjne	R3, #1,	readNotBigXRam
		mov	DPL, R1		; Data Pointer,	Low Byte
		mov	DPH, R2		; Data Pointer,	High Byte
		movx	A, @DPTR
		ret
; ---------------------------------------------------------------------------

readNotBigXRam:				; CODE XREF: readBuffToAj
		jnc	readnotIntRam
		mov	A, @R1
		ret
; ---------------------------------------------------------------------------

readnotIntRam:				; CODE XREF: readBuffToA:readNotBigXRamj
		cjne	R3, #0FEh, readCodeRom ; 'ţ'
		movx	A, @R1
		ret
; ---------------------------------------------------------------------------

readCodeRom:				; CODE XREF: readBuffToA:readnotIntRamj
		mov	DPL, R1		; Data Pointer,	Low Byte
		mov	DPH, R2		; Data Pointer,	High Byte
		clr	A
		movc	A, @A+DPTR
		ret
; End of function readBuffToA


; =============== S U B	R O U T	I N E =======================================

; R2 ptrH
; R1 ptrL
; R3 mode select:
;  0x00	- write	RAM (R1)
;  0x01	- write	ext RAM	(R2:R1)
;  0xFE	- write	ext RAM	(R1)
;  other - no write

writeAToBuff:				; CODE XREF: serBtoUsbMidOut+15p
					; serBtoUsbMidOut+8Dp ...
		cjne	R3, #1,	writeNotBigXRam
		mov	DPL, R1		; Data Pointer,	Low Byte
		mov	DPH, R2		; Data Pointer,	High Byte
		movx	@DPTR, A
		ret
; ---------------------------------------------------------------------------

writeNotBigXRam:			; CODE XREF: writeAToBuffj
		jnc	writeNotIntRam
		mov	@R1, A
		ret
; ---------------------------------------------------------------------------

writeNotIntRam:				; CODE XREF: writeAToBuff:writeNotBigXRamj
		cjne	R3, #0FEh, noWrite ; 'ţ'
		movx	@R1, A

noWrite:				; CODE XREF: writeAToBuff:writeNotIntRamj
		ret
; End of function writeAToBuff


; =============== S U B	R O U T	I N E =======================================

; Write	A to (R2:R1)+DPTR or R1+DPL
; R2 ptrH
; R1 ptrL
; R3 mode select:
;  0x00	- write	RAM (R1)
;  0x01	- write	ext RAM	(R2:R1)
;  0xFE	- write	ext RAM	(R1)
;  other - no write

writeAToBuDPTR:				; CODE XREF: serBtoUsbMidOut+21p
					; serBtoUsbMidOut+29p ...
		mov	R0, A
		cjne	R3, #1,	writ2NotBigXRam
		mov	A, DPL		; Data Pointer,	Low Byte
		add	A, R1
		mov	DPL, A		; Data Pointer,	Low Byte
		mov	A, DPH		; Data Pointer,	High Byte
		addc	A, R2
		mov	DPH, A		; Data Pointer,	High Byte
		mov	A, R0
		movx	@DPTR, A
		ret
; ---------------------------------------------------------------------------

writ2NotBigXRam:			; CODE XREF: writeAToBuDPTR+1j
		jnc	writ2NotIntRam
		mov	A, R1
		add	A, DPL		; Data Pointer,	Low Byte
		xch	A, R0
		mov	@R0, A
		ret
; ---------------------------------------------------------------------------

writ2NotIntRam:				; CODE XREF: writeAToBuDPTR:writ2NotBigXRamj
		cjne	R3, #0FEh, noWrit2 ; 'ţ'
		mov	A, R1
		add	A, DPL		; Data Pointer,	Low Byte
		xch	A, R0
		movx	@R0, A

noWrit2:				; CODE XREF: writeAToBuDPTR:writ2NotIntRamj
		ret
; End of function writeAToBuDPTR


; =============== S U B	R O U T	I N E =======================================

; starting from	DPTR find int_type
;
; if ((DPTR*) or ((DPTR+1)*))
;    if	((DPTR+2)* == int_type)
;	jmp ( (DPTR*)<<8 || ((DPTR+1)*)	)
;    else
;	DPTR+=3
; else
;    DPTR+=2
;    jmp ( (DPTR*)<<8 || ((DPTR+1)*) )
;
; interrupt table items
;  0xHH	-- handler address high
;  0xLL	-- handler address low
;  0xtt	-- intterrupt type
;
; if there is a	0x0000 address word in the table
; then jump to the next	address	word

find_inth_addr:				; CODE XREF: IE0_0+24p
		pop	DPH		; Data Pointer,	High Byte
		pop	DPL		; pop int_vect_table to	DPTR
		mov	R0, A		; copy interrupt type to R0

code_79D:				; CODE XREF: find_inth_addr+24j
		clr	A
		movc	A, @A+DPTR	; read int_vect_table for int type
		jnz	intvectt_notz	; have handler
		mov	A, #1
		movc	A, @A+DPTR	; read int_vect_table+1
		jnz	intvectt_notz
		inc	DPTR
		inc	DPTR		; int_vect_table+=2

jmp_adr_at_dptr:			; CODE XREF: find_inth_addr+1Fj
		movc	A, @A+DPTR	; *read	addr from DPTR and jump	to there
					; read int_vect_table
		mov	R0, A		; prepare jump addr hi
		mov	A, #1
		movc	A, @A+DPTR	; read int_vect_table+1
		mov	DPL, A		; Data Pointer,	Low Byte
		mov	DPH, R0		; Data Pointer,	High Byte
		clr	A
		jmp	@A+DPTR
; ---------------------------------------------------------------------------

intvectt_notz:				; CODE XREF: find_inth_addr+7j
					; find_inth_addr+Cj
		mov	A, #2
		movc	A, @A+DPTR	; read int_vect_table+2
		xrl	A, R0		; xor read with	int type
		jz	jmp_adr_at_dptr	; match	type
		inc	DPTR
		inc	DPTR
		inc	DPTR
		sjmp	code_79D	; int_vect_table+=3
; End of function find_inth_addr


; =============== S U B	R O U T	I N E =======================================


usbreqgetdescr:				; CODE XREF: usbreqhndlr:usbrgetdescrp
		clr	A
		mov	desc_len_H, A
		mov	desc_len_L, A
		mov	RAM_E, wValRamH
		mov	RAM_F, wValRamL
		mov	A, wValRamH
		add	A, #-2
		jz	usbgetconf
		dec	A
		jz	usbgetstring
		add	A, #2
		jnz	code_828
		mov	desc_len_H, #(high((conf_descr	- dev_descr)))
		mov	desc_len_L, #(low((conf_descr - dev_descr)))
		mov	R3, #0FFh
		mov	R2, #high(dev_descr)
		mov	R1, #low(dev_descr) ; dev_descr
		mov	RAM_B, R3
		mov	desc_H,	R2
		mov	desc_L,	R1
		mov	R5, desc_len_L
		mov	R4, desc_len_H
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

usbgetconf:				; CODE XREF: usbreqgetdescr+Fj
		mov	desc_len_H, #(high((string_descr - conf_descr)))
		mov	desc_len_L, #(low((string_descr - conf_descr)))
		mov	R3, #0FFh
		mov	R2, #high(conf_descr)
		mov	R1, #low(conf_descr) ;	conf_descr
		mov	RAM_B, R3
		mov	desc_H,	R2
		mov	desc_L,	R1
		mov	A, R1
		orl	A, R2
		jnz	confdscntempty	; config descriptor present
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

confdscntempty:				; CODE XREF: usbreqgetdescr+4Bj
		mov	R3, RAM_B
		mov	R2, desc_H
		mov	R1, desc_L
		mov	R5, desc_len_L
		mov	R4, desc_len_H
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

usbgetstring:				; CODE XREF: usbreqgetdescr+12j
		lcall	usbstrdesc
		ret
; ---------------------------------------------------------------------------

code_828:				; CODE XREF: usbreqgetdescr+16j
		mov	R7, #1
		lcall	usbreqclose
		ret
; End of function usbreqgetdescr


; =============== S U B	R O U T	I N E =======================================


usbreqhndlr:				; CODE XREF: usbrequest+9p
		mov	A, bmReqRam
		jnb	ACC.7, usbreqtout ; if bit7 != 1 (==0) USB req type output (host to dev)
		mov	A, bReqRam	; USB req type input (dev to host)
		jz	usbrgetstat	; USB_REQ_GET_STATUS
		add	A, #-006
		jz	usbrgetdescr	; USB_REQ_GET_DESCRIPTOR
		add	A, #-4
		jz	usbrgetintfc	; USB_REQ_GET_INTERFAC
		add	A, #2
		jnz	usbrgetdef	; Not (	USB_REQ_GET_CONFIGURATION )
		lcall	usbreqgetconf	; USB_REQ_GET_CONFIGURATION
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrgetstat:				; CODE XREF: usbreqhndlr+7j
		lcall	usbreqgetstat
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrgetdescr:				; CODE XREF: usbreqhndlr+Bj
		lcall	usbreqgetdescr
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrgetintfc:				; CODE XREF: usbreqhndlr+Fj
		lcall	usbreqgetintfc
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrgetdef:				; CODE XREF: usbreqhndlr+13j
		mov	R7, #1
		lcall	usbreqclose
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbreqtout:				; CODE XREF: usbreqhndlr+2j
		mov	A, bReqRam	; --- USB req type output
		add	A, #-3
		jz	usbrsetftr	; USB_REQ_SET_FEATURE
		add	A, #-2
		jz	usbrsetadr	; USB_REQ_SET_ADDRESS
		add	A, #-4
		jz	usbrsetcnf	; USB_REQ_SET_CONFIGURATION
		add	A, #-2
		jz	usbrsetifc	; USB_REQ_SET_INTERFACE
		add	A, #0Ah
		jnz	usbrsetdef
		lcall	usbreqclrftr	; USB_REQ_CLEAR_FEATURE
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrsetftr:				; CODE XREF: usbreqhndlr+34j
		lcall	usbreqsetftr
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrsetadr:				; CODE XREF: usbreqhndlr+38j
		lcall	usbreqsetadr
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrsetcnf:				; CODE XREF: usbreqhndlr+3Cj
		lcall	usbreqsetcnf
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrsetifc:				; CODE XREF: usbreqhndlr+40j
		lcall	usbreqsetifc
		sjmp	usbreqhend
; ---------------------------------------------------------------------------

usbrsetdef:				; CODE XREF: usbreqhndlr+44j
		mov	R7, #1
		lcall	usbreqclose

usbreqhend:				; CODE XREF: usbreqhndlr+18j
					; usbreqhndlr+1Dj ...
		mov	R7, #0
		ret
; End of function usbreqhndlr

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR RESET_0

RESET_1:				; CODE XREF: RESET_0+9j
		clr	A
		mov	R7, A
		mov	R6, A
		mov	RAM_10,	A
		mov	DPTR, #GLOBCTL	; Global control register
		mov	A, #84h	; '„'   ; MCUCLK=24MHz -- no ext int -- no pull up dis
					; no low power mode -- CODEC disabled
		movx	@DPTR, A
		clr	P1.0		; codec	reset
		clr	P1.1		; mic disabled
		clr	A
		mov	RAM_1E,	A
		mov	usb_out_ep1, A
		clr	GlobSt2t.0	; 4: setup long	response
					; 5: debug response
		setb	GlobSt2t.4	; 4: setup long	response
					; 5: debug response
		mov	DPTR, #CPTCNF1	; CODEC	port interface configuration register 1
		mov	A, #0Dh		; 2 time slots/frame --	I2S mode 2 out & 2 in (mode5)
		movx	@DPTR, A
		clr	A

cdcResDly:				; CODE XREF: RESET_0-338j
		clr	A
		mov	R6, A

dly2:					; CODE XREF: RESET_0-33Cj
		inc	R6
		cjne	R6, #64h, dly2 ; 'd'
		inc	R7
		cjne	R7, #64h, cdcResDly ; 'd'
		setb	P1.0		; codec	normal (end of reset)
		lcall	usb_init
		lcall	usbsetup_ep1
		lcall	ser_init	; init serial io port and baud rate
		lcall	nullsub_1

		; public main_loop
main_loop:				; CODE XREF: RESET_0-309j RESET_0-303j
		lcall	code_B01
		jnb	GlobStat.1, code_8DA ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		setb	GlobSt2t.0	; 4: setup long	response
					; 5: debug response
		mov	PCON, #9	; Power	Control	Register
		lcall	code_B01

code_8DA:				; CODE XREF: RESET_0-324j
		mov	A, usb_out_ep1
		xrl	A, RAM_1E
		jz	code_8E6
		mov	RAM_1E,	usb_out_ep1
		lcall	usbMidiInToSerB

code_8E6:				; CODE XREF: RESET_0-315j
		mov	DPTR, #IEPDCNTX1 ; In endpoint 1 - X buffer data count byte
		movx	A, @DPTR
		jnb	ACC.7, main_loop ; jump	if no NACK
		lcall	serBtoUsbMidOut
		sjmp	main_loop
; END OF FUNCTION CHUNK	FOR RESET_0

; =============== S U B	R O U T	I N E =======================================


nullsub_2:
		ret
; End of function nullsub_2


; =============== S U B	R O U T	I N E =======================================

; Input	Endpoint 0 response copy to USB	Buffer
; in chunks of 8 bytes
;
; return status	in R7
;  1 = Tx ended
;  0 = Tx pending

usbTxResp_iep0:				; CODE XREF: usb_in_ep0+2Fp
					; usb_setup_st+7Dp
		mov	A, usbRespLenL
		orl	A, usbRespLenH
		jnz	cpyRespToUsbBuf
		mov	A, usbDatCnt
		clr	C
		subb	A, #8
		jnc	cpyRespToUsbBuf	; after	last full buffer there is a dummy tx
		mov	R7, #1
		ret
; ---------------------------------------------------------------------------

cpyRespToUsbBuf:			; CODE XREF: usbTxResp_iep0+4j
					; usbTxResp_iep0+Bj
		clr	A
		mov	usbDatCnt, A

code_906:				; CODE XREF: usbTxResp_iep0+47j
		mov	A, usbRespLenL
		orl	A, usbRespLenH
		jz	usbRespTxOut
		mov	R3, usbRespCfg
		mov	R2, usbRespH
		mov	R1, usbRespL
		lcall	readBuffToA	; R2 ptrH
					; R1 ptrL
					; R3 mode select:
					;  0x00	- read RAM (R1)
					;  0x01	- read ext RAM (R2:R1)
					;  0xFE	- read ext RAM (R1)
					;  other - read	Code ROM (R2:R1)
		mov	R7, A
		mov	A, #8
		add	A, usbDatCnt
		mov	DPL, A		; Data Pointer,	Low Byte
		clr	A
		addc	A, #0F8h ; 'ř'  ; USB base buffer high
		mov	DPH, A		; Data Pointer,	High Byte
		mov	A, R7
		movx	@DPTR, A
		mov	A, #1
		add	A, usbRespL
		mov	usbRespL, A
		clr	A
		addc	A, usbRespH
		mov	usbRespH, A
		mov	A, usbRespLenL
		dec	usbRespLenL
		jnz	code_936
		dec	usbRespLenH

code_936:				; CODE XREF: usbTxResp_iep0+3Fj
		inc	usbDatCnt
		mov	A, usbDatCnt
		cjne	A, #8, code_906	; only send 8 bytes in one pass

usbRespTxOut:				; CODE XREF: usbTxResp_iep0+17j
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		mov	A, #80h	; '€'   ; NACK -- X buff empty
		movx	@DPTR, A
		mov	A, usbDatCnt	; X buff has usbDatCnt bytes
		movx	@DPTR, A
		mov	R7, #0
		ret
; End of function usbTxResp_iep0


; =============== S U B	R O U T	I N E =======================================


code_949:				; CODE XREF: usb_out_ep0+57p
		mov	DPTR, #OEPDCNTX0 ; Out endpoint	0 - X buffer data count	byte
		movx	A, @DPTR
		anl	A, #7Fh
		mov	R7, A
		clr	C
		subb	A, #8
		jnc	code_960
		mov	A, usbRespLenL
		xrl	A, R7
		jz	code_960
		mov	A, R7
		mov	usbRespLenH, #0
		mov	usbRespLenL, A

code_960:				; CODE XREF: code_949+Aj code_949+Fj
		clr	A
		mov	R7, A

code_962:				; CODE XREF: code_949+3Cj
		mov	A, usbRespLenL
		orl	A, usbRespLenH
		jz	code_988
		clr	A
		add	A, R7
		mov	DPL, A		; Data Pointer,	Low Byte
		clr	A
		addc	A, #0F8h ; 'ř'
		mov	DPH, A		; Data Pointer,	High Byte
		movx	A, @DPTR
		mov	R6, A
		mov	A, #2Ah	; '*'
		add	A, RAM_4C
		mov	R0, A
		mov	@R0, RAM_6
		inc	RAM_4C
		mov	A, usbRespLenL
		dec	usbRespLenL
		jnz	code_984
		dec	usbRespLenH

code_984:				; CODE XREF: code_949+37j
		inc	R7
		cjne	R7, #8,	code_962

code_988:				; CODE XREF: code_949+1Dj
		mov	DPTR, #OEPDCNTX0 ; Out endpoint	0 - X buffer data count	byte
		clr	A
		movx	@DPTR, A
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		movx	@DPTR, A
		mov	A, usbRespLenL
		orl	A, usbRespLenH
		jnz	code_99A
		mov	R7, #1
		ret
; ---------------------------------------------------------------------------

code_99A:				; CODE XREF: code_949+4Cj
		mov	R7, #2
		ret
; End of function code_949


; =============== S U B	R O U T	I N E =======================================

; Serial IO handler
;
; Serial_in -> MIDI-OUT
; MIDI-IN -> Serial_out

RI_TI_0:				; CODE XREF: RI_TIj
		push	ACC		; Accumulator
		push	PSW		; Program Status Word Register
		mov	PSW, #0		; Program Status Word Register
		push	RAM_0
		push	RAM_7
		clr	IE.7
		jnb	SCON.0,	not_rxed ; no byte received
		clr	SCON.0		; Serial Channel Control Register
		mov	R7, SBUF	; Read SERIAL Data
		clr	C
		mov	A, SerInMidiPtr
		subb	A, SerMidiOutPtr ; A=RAM16-RAM17
		anl	A, #0F8h
		jnz	rxBuf_full	; (RAM_16-RAM_17 & 0xF8) > 0 ==	|RAM_16-RAM_17|	> 7
		mov	A, SerInMidiPtr
		anl	A, #7		; A= (RAM_16 & 0x07)
		add	A, #MIDI_OUT_BUF
		mov	R0, A
		mov	@R0, RAM_7
		inc	SerInMidiPtr

rxBuf_full:				; CODE XREF: RI_TI_0+1Bj
		setb	GlobStat.3	; serial data in MIDI OUT buffer

not_rxed:				; CODE XREF: RI_TI_0+Dj
		jnb	SCON.1,	seri_end ; no byte sent
		clr	SCON.1		; Serial Channel Control Register
		mov	A, SerMidiInPtr
		xrl	A, SerOutMidiPtr
		jz	txBuff_empty
		mov	A, SerOutMidiPtr
		anl	A, #7		; limit	size to	0-7
		add	A, #MIDI_IN_BUF
		mov	R0, A
		mov	A, @R0
		mov	SBUF, A		; Write	SERIAL Data
		inc	SerOutMidiPtr
		clr	GlobStat.4	; serial tx buffer not empty
		sjmp	seri_end
; ---------------------------------------------------------------------------

txBuff_empty:				; CODE XREF: RI_TI_0+33j
		setb	GlobStat.4	; serial tx buffer empty

seri_end:				; CODE XREF: RI_TI_0:not_rxedj
					; RI_TI_0+43j
		setb	IE.7
		pop	RAM_7
		pop	RAM_0
		pop	PSW		; Program Status Word Register
		pop	ACC		; Accumulator
		reti
; End of function RI_TI_0


; =============== S U B	R O U T	I N E =======================================


usbreqclrftr:				; CODE XREF: usbreqhndlr+46p
		mov	A, bmReqRam
		add	A, #0FEh ; 'ţ'
		jz	code_A1A
		add	A, #2
		jnz	code_A37
		mov	A, wValRamL
		xrl	A, #1
		orl	A, wValRamH
		jnz	code_A14
		clr	GlobStat.5	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		jnb	GlobStat.5, code_A0B ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		orl	RAM_4F,	#2
		sjmp	code_A0E
; ---------------------------------------------------------------------------

code_A0B:				; CODE XREF: usbreqclrftr+14j
		anl	RAM_4F,	#0FDh

code_A0E:				; CODE XREF: usbreqclrftr+1Aj
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_A14:				; CODE XREF: usbreqclrftr+10j
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_A1A:				; CODE XREF: usbreqclrftr+4j
		mov	R7, wIdxRamL
		lcall	code_BCE
		mov	A, R7
		jnz	code_A28
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_A28:				; CODE XREF: usbreqclrftr+31j
		mov	A, wValRamL
		jnz	code_A31
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_A31:				; CODE XREF: usbreqclrftr+3Bj
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_A37:				; CODE XREF: usbreqclrftr+8j
		mov	R7, #1
		lcall	usbreqclose
		ret
; End of function usbreqclrftr


; =============== S U B	R O U T	I N E =======================================


usbstrdesc:				; CODE XREF: usbreqgetdescr:usbgetstringp
		mov	A, wValRamL
		dec	A
		jz	usbstr1		; string1
		dec	A
		jz	usbstr2		; string2
		add	A, #2
		jnz	usbstunk	; not main string descriptor
		mov	R3, #0FFh
		mov	R2, #high(string_descr)
		mov	R1, #low(string_descr)	; string_descr
		mov	R5, #(low((strBehringer - string_descr)))
		mov	R4, #(high((strBehringer - string_descr)))
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

usbstr1:				; CODE XREF: usbstrdesc+3j
		mov	R3, #0FFh
		mov	R2, #high(strBehringer)
		mov	R1, #low(strBehringer)	; strBehringer
		mov	R5, #(low((strBcd2000 - strBehringer))) ; str len
		mov	R4, #(high((strBcd2000	- strBehringer)))
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

usbstr2:				; CODE XREF: usbstrdesc+6j
		mov	R3, #0FFh
		mov	R2, #high(strBcd2000)
		mov	R1, #low(strBcd2000) ;	strBcd2000
		mov	R5, #(low((usbreqclose	- strBcd2000)))	; str len
		mov	R4, #(high((usbreqclose - strBcd2000)))
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

usbstunk:				; CODE XREF: usbstrdesc+Aj
		mov	R7, #1
		lcall	usbreqclose
		ret
; End of function usbstrdesc


; =============== S U B	R O U T	I N E =======================================


usbreqsetftr:				; CODE XREF: usbreqhndlr:usbrsetftrp
		mov	A, bmReqRam
		add	A, #0FEh ; 'ţ'
		jz	code_AB0
		add	A, #2
		jnz	code_ACD
		mov	A, wValRamL
		cjne	A, #1, code_AAA
		setb	GlobStat.5	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		jnb	GlobStat.5, code_AA1 ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		orl	RAM_4F,	#2
		sjmp	code_AA4
; ---------------------------------------------------------------------------

code_AA1:				; CODE XREF: usbreqsetftr+11j
		anl	RAM_4F,	#0FDh

code_AA4:				; CODE XREF: usbreqsetftr+17j
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_AAA:				; CODE XREF: usbreqsetftr+Cj
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_AB0:				; CODE XREF: usbreqsetftr+4j
		mov	R7, wIdxRamL
		lcall	code_BCE
		mov	A, R7
		jnz	code_ABE
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_ABE:				; CODE XREF: usbreqsetftr+2Ej
		mov	A, wValRamL
		jnz	code_AC7
		mov	R7, A
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_AC7:				; CODE XREF: usbreqsetftr+38j
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_ACD:				; CODE XREF: usbreqsetftr+8j
		mov	R7, #1
		lcall	usbreqclose
		ret
; End of function usbreqsetftr


; =============== S U B	R O U T	I N E =======================================


usbsetup_ep1:				; CODE XREF: RESET_0-330p
		mov	RAM_4F,	#1
		clr	A
		mov	RAM_42,	A
		clr	GlobSt2t.7	; 4: setup long	response
					; 5: debug response
		clr	GlobStat.0	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	DPTR, #OEPCNF1	; Out endpoint 1 - configuration byte
		mov	A, #84h	; '„'   ; endp enable -- not isocho -- interrupt enable
		movx	@DPTR, A
		inc	DPTR		; OEPBBAX1
		mov	A, #2		; X buff addr= 0x10
		movx	@DPTR, A
		inc	DPTR		; OEPBSIZ1
		mov	A, #8		; X & Y	buff size= 64 (0x40)
		movx	@DPTR, A
		inc	DPTR		; OEPDCNTX1
		clr	A		; X buff empty
		movx	@DPTR, A
		mov	DPTR, #IEPCNF1	; In endpoint 1	- configuration	byte
		mov	A, #80h	; '€'   ; endp enable -- not isocho
		movx	@DPTR, A
		inc	DPTR		; IEPBBAX1
		mov	A, #0Ah		; X buff addr= 0x50 (80)
		movx	@DPTR, A
		inc	DPTR		; IEPBSIZ1
		mov	A, #8		; X & Y	buff size= 64 (0x40)
		movx	@DPTR, A
		inc	DPTR		; IEPBCNTX1
		mov	A, #80h	; '€'   ; NACK -- X buff empty
		movx	@DPTR, A
		ret
; End of function usbsetup_ep1


; =============== S U B	R O U T	I N E =======================================


code_B01:				; CODE XREF: RESET_0:main_loopp
					; RESET_0-31Cp
		jnb	GlobStat.0, code_B2A ; 3: rx buff
					; 4: tx	buff empty
					; 6: enable response counter
		mov	DPTR, #USBIMSK	; USB interrupt	mask register
		movx	A, @DPTR
		orl	A, #10h		; start-of-frame
		movx	@DPTR, A
		setb	GlobSt2t.7	; 4: setup long	response
					; 5: debug response
		clr	A
		mov	RAM_4D,	A

waitloop:				; CODE XREF: code_B01+14j
		mov	A, RAM_4D
		clr	C
		subb	A, #2
		jc	waitloop
		jnb	GlobSt2t.7, code_B26 ; interrupt can cause jump
		mov	DPTR, #USBFADR	; USB function address register
		clr	A		; set def addr 0x00
		movx	@DPTR, A
		jnb	GlobSt2t.0, code_B26 ; 4: setup	long response
					; 5: debug response
		clr	GlobSt2t.0	; 4: setup long	response
					; 5: debug response
		clr	GlobStat.1	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter

code_B26:				; CODE XREF: code_B01+16j code_B01+1Ej
		clr	GlobSt2t.7	; 4: setup long	response
					; 5: debug response
		clr	GlobStat.0	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter

code_B2A:				; CODE XREF: code_B01j
		ret
; End of function code_B01


; =============== S U B	R O U T	I N E =======================================

; init serial io port and baud rate

ser_init:				; CODE XREF: RESET_0-32Dp
		clr	GlobStat.3	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		setb	GlobStat.4	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	A
		mov	SerMidiOutPtr, A
		mov	SerInMidiPtr, A
		mov	SerOutMidiPtr, A
		mov	SerMidiInPtr, A
		mov	SCON, #50h ; 'P' ; mode1 8bit uart w/ timer2 baud
		mov	T2CON, #34h ; '4' ; Timer 2 Control Register
		mov	RC2H, #0FFh	; Timer	2 Reload/Capture Register, High	Byte
		mov	RC2L, #0E8h ; 'č' ; Timer 2 Reload/Capture Register, Low Byte
		setb	SCON.4		; Serial Channel Control Register
		setb	IE.4		; enable serial	port interrupt
		ret
; End of function ser_init


; =============== S U B	R O U T	I N E =======================================


usbreqgetintfc:				; CODE XREF: usbreqhndlr:usbrgetintfcp
		mov	R7, wIdxRamL
		sjmp	code_B4D
; ---------------------------------------------------------------------------

code_B4D:				; CODE XREF: usbreqgetintfc+2j
		clr	A
		mov	RAM_2A,	A
		mov	R3, #0
		mov	R2, #0
		mov	R1, #2Ah ; '*'
		mov	R5, #1
		mov	R4, #0
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; End of function usbreqgetintfc


; =============== S U B	R O U T	I N E =======================================


usbrequest:				; CODE XREF: usb_setup_st+75p
					; usb_setup_st+8Dp ...
		clr	A
		mov	RAM_8, A
		mov	A, bmReqRam
		anl	A, #60h
		jnz	usbrclassvend	; class	or vendor specific request
		lcall	usbreqhndlr	; standard USB request
		mov	RAM_8, R7
		ret
; ---------------------------------------------------------------------------

usbrclassvend:				; CODE XREF: usbrequest+7j
		mov	RAM_8, #1
		mov	R7, RAM_8
		lcall	usbreqclose
		ret
; End of function usbrequest


; =============== S U B	R O U T	I N E =======================================


usbreqgetconf:				; CODE XREF: usbreqhndlr+15p
		mov	RAM_2A,	RAM_42
		mov	R3, #0
		mov	R2, #0
		mov	R1, #2Ah ; '*'
		mov	R5, #1
		mov	R4, #0
		lcall	usbPrepResp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; End of function usbreqgetconf


; =============== S U B	R O U T	I N E =======================================

; write	R7 to MIDI_IN_BUF
;    inc SerMidiInPtr

writeMidiInBuf:				; CODE XREF: usbMidiInToSerB+6Fp
		mov	A, SerMidiInPtr
		anl	A, #7
		add	A, #MIDI_IN_BUF
		mov	R0, A
		mov	@R0, RAM_7
		inc	SerMidiInPtr
		jnb	GlobStat.4, txbufnotempty ; tx buffer not empty, no need to manage bits
		clr	GlobStat.4	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		setb	SCON.1		; Serial Channel Control Register

txbufnotempty:				; CODE XREF: writeMidiInBuf+Bj
		mov	R7, #0
		ret
; End of function writeMidiInBuf


; =============== S U B	R O U T	I N E =======================================


usbreqsetadr:				; CODE XREF: usbreqhndlr:usbrsetadrp
		mov	A, wValRamL
		cjne	A, #0FFh, code_BB1
		mov	R7, #1
		lcall	usbreqclose
		ret
; ---------------------------------------------------------------------------

code_BB1:				; CODE XREF: usbreqsetadr+2j
		mov	DPTR, #IEPDCNTX0 ; In endpoint 0 - X buffer data count byte
		clr	A
		movx	@DPTR, A
		mov	RAM_47,	#8
		ret
; End of function usbreqsetadr


; =============== S U B	R O U T	I N E =======================================

; read a MIDI_OUT_BUF byte to R7
;    inc SerMidiOutPtr
; 0xFF if empty

readMidiOutBuf:				; CODE XREF: serBtoUsbMidOut+75p
		mov	A, SerInMidiPtr
		cjne	A, SerMidiOutPtr, rdMidiOutBuf
		mov	R7, #0FFh	; buffer empty - return	0xFF
		ret
; ---------------------------------------------------------------------------

rdMidiOutBuf:				; CODE XREF: readMidiOutBuf+2j
		mov	A, SerMidiOutPtr
		anl	A, #7
		add	A, #MIDI_OUT_BUF
		mov	R0, A
		mov	A, @R0
		mov	R7, A
		inc	SerMidiOutPtr
		ret
; End of function readMidiOutBuf


; =============== S U B	R O U T	I N E =======================================


code_BCE:				; CODE XREF: usbreqgetstat+3Dp
					; usbreqclrftr+2Dp ...
		mov	A, R7
		add	A, #0FCh ; 'ü'
		jnc	code_BD5
		sjmp	code_BD8
; ---------------------------------------------------------------------------

code_BD5:				; CODE XREF: code_BCE+3j
		mov	R7, #1
		ret
; ---------------------------------------------------------------------------

code_BD8:				; CODE XREF: code_BCE+5j
		mov	R7, #0
		ret
; End of function code_BCE

; ---------------------------------------------------------------------------
aBcd2000u13:	db '*BCD2000U13*'

; =============== S U B	R O U T	I N E =======================================


usbreqsetcnf:				; CODE XREF: usbreqhndlr:usbrsetcnfp
		mov	RAM_42,	wValRamL
		lcall	setCodecDma
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; End of function usbreqsetcnf


; =============== S U B	R O U T	I N E =======================================


RESET_0:				; CODE XREF: RESETj

; FUNCTION CHUNK AT 00000895 SIZE 0000005D BYTES

		mov	R0, #7Fh ; ''
		clr	A

clrRam:					; CODE XREF: RESET_0+4j
		mov	@R0, A
		djnz	R0, clrRam
		mov	SP, #STACK	; Stack	Pointer
		ljmp	RESET_1
; End of function RESET_0


; =============== S U B	R O U T	I N E =======================================


getRxBuf_size:				; CODE XREF: serBtoUsbMidOut+59p
		clr	C
		mov	A, SerInMidiPtr
		subb	A, SerMidiOutPtr
		anl	A, #7
		mov	R7, A
		ret
; End of function getRxBuf_size


; =============== S U B	R O U T	I N E =======================================


usbreqsetifc:				; CODE XREF: usbreqhndlr:usbrsetifcp
		clr	A
		mov	R7, A
		lcall	usbreqclose
		ret
; End of function usbreqsetifc


; =============== S U B	R O U T	I N E =======================================


usb_fnc_rsm:				; CODE XREF: code_527p
		clr	GlobStat.1	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		clr	GlobSt2t.0	; 4: setup long	response
					; 5: debug response
		ret
; End of function usb_fnc_rsm


; =============== S U B	R O U T	I N E =======================================


usb_fnc_sus:				; CODE XREF: code_522p
		setb	GlobStat.1	; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
		ret
; End of function usb_fnc_sus

; ---------------------------------------------------------------------------
		org 0f810h
usbBufMidiIn:	ds 1			; DATA XREF: usbMidiInToSerB+11o
		ds 1
usbMidiLen:	ds 1			; DATA XREF: usbMidiInToSerB+27o
					; fwUpdate+16o
usbMidiDatStrt:	ds 10h			; 0 ; DATA XREF: fwUpdate+2Co
fwUpdLastByte:	ds 1			; DATA XREF: fwUpdate+71o
		ds 704h			; 0
bmRequestType:	ds 1			; DATA XREF: usb_setup_st+2Co
					; identifies the characteristics of the	request
bRequest:	ds 1			; Specifies the	particular request
wValH:		ds 1			; Value	of a parameter specific	to the request
wValL:		ds 1
wIdxH:		ds 1			; Index	or offset value
wIdxL:		ds 1
wLenH:		ds 1			; Number of bytes to transfer in the data stage
wLenL:		ds 1
IEPCNF7:	ds 1			; DATA XREF: usb_init+51o
					; In endpoint 7	- configuration	byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
IEPCNF6:	ds 1			; DATA XREF: usb_init+4Do
					; In endpoint 6	- configuration	byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
IEPCNF5:	ds 1			; DATA XREF: usb_init+49o
					; In endpoint 5	- configuration	byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
IEPCNF4:	ds 1			; DATA XREF: usb_init+45o
					; In endpoint 4	- configuration	byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
IEPCNF3:	ds 1			; DATA XREF: setCodecDma+22o
					; usb_init+41o
					; In endpoint 3	- configuration	byte
IEPBBAX3:	ds 1			; In endpoint 3	- X buffer base	address	byte
IEPBSIZ3:	ds 1			; In endpoint 3	- X and	Y buffer byte
IEPDCNTX3:	ds 1			; In endpoint 3	- X buffer data	count byte
		ds 1
IEPBBAY3:	ds 1			; DATA XREF: setCodecDma+34o
					; In endpoint 3	- Y buffer base	address	byte
		ds 1
IEPDCNTY3:	ds 1			; DATA XREF: setCodecDma+3Ao
					; In endpoint 3	- Y buffer data	count byte
IEPCNF2:	ds 1			; DATA XREF: usb_init+3Do
					; In endpoint 0	- configuration	byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
IEPCNF1:	ds 1			; DATA XREF: usb_init+39o
					; usbsetup_ep1+1Bo
					; In endpoint 1	- configuration	byte
		ds 1
		ds 1
IEPDCNTX1:	ds 1			; DATA XREF: serBtoUsbMidOut+CAo
					; RESET_0:code_8E6o
					; In endpoint 1	- X buffer data	count byte
		ds 1
		ds 1
		ds 1
		ds 1
IEPCNF0:	ds 1			; DATA XREF: usb_in_ep0:code_110o
					; usb_in_ep0+3Ao ...
					; In endpoint 0	- configuration	byte
IEPBBAX0:	ds 1			; In endpoint 0	- X buffer base	address	byte
IEPBSIZ0:	ds 1			; In endpoint 0	- X and	Y buffer byte
IEPDCNTX0:	ds 1			; DATA XREF: usb_in_ep0+A6o
					; usb_setup_st+21o ...
					; In endpoint 0	- X buffer data	count byte
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF7:	ds 1			; DATA XREF: usb_init+6Do
					; Out endpoint 7 - configuration byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF6:	ds 1			; DATA XREF: usb_init+69o
					; Out endpoint 6 - configuration byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF5:	ds 1			; DATA XREF: usb_init+65o
					; Out endpoint 5 - configuration byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF4:	ds 1			; DATA XREF: usb_init+61o
					; Out endpoint 4 - configuration byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF3:	ds 1			; DATA XREF: usb_init+5Do
					; Out endpoint 3 - configuration byte
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF2:	ds 1			; DATA XREF: setCodecDma+6o
					; usb_init+59o
					; Out endpoint 2 - configuration byte
		ds 1
		ds 1
		ds 1
		ds 1
OEPBBAY2:	ds 1			; DATA XREF: setCodecDma+17o
					; Out endpoint 2 - Y buffer base address byte
		ds 1
OEPDCNTY2:	ds 1			; DATA XREF: setCodecDma+1Do
					; Out endpoint 2 - Y buffer data count byte
OEPCNF1:	ds 1			; DATA XREF: usb_init+55o
					; usbsetup_ep1+Ao
					; Out endpoint 1 - configuration byte
		ds 1
		ds 1
OEPDCNTX1:	ds 1			; DATA XREF: usbMidiInToSerBo
					; usbMidiInToSerB:clrBuffo
					; Out endpoint 1 - X buffer data count byte
		ds 1
		ds 1
		ds 1
		ds 1
OEPCNF0:	ds 1			; DATA XREF: usb_in_ep0+41o
					; usb_in_ep0+6Bo ...
					; Out endpoint 0 - configuration byte
OEPBBAX0:	ds 1			; Out endpoint 0 - X buffer base address byte
OEPBSIZ0:	ds 1			; Out endpoint 0 - X and Y buffer byte
OEPDCNTX0:	ds 1			; DATA XREF: usb_in_ep0+48o
					; usb_setup_st+1Co ...
					; Out endpoint 0 - X buffer data count byte
		ds 1
		ds 1
		ds 1
		ds 1
MEMCFG:		ds 1			; Memory configuration register
GLOBCTL:	ds 1			; DATA XREF: setCodecDma+40o
					; setCodecDma+8Eo ...
					; Global control register
VECINT:		ds 1			; DATA XREF: IE0_0+1Fo
					; code_52C:cleanup_n_retio
					; interrupt vector register
IEPINT:		ds 1			; USB in endpoint interrupt register
OEPINT:		ds 1			; USB out endpoint interrupt register
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
PWMWH:		ds 1			; PWM pulse width register (high byte)
PWMWL:		ds 1			; PWM pulse width register (low	byte)
PWMFRQ:		ds 1			; PWM frequency	register
I2CCTL:		ds 1			; DATA XREF: fwUpdateo
					; fwUpdate:i2cWforTxAHo ...
					; I2C interface	control	and status register
I2CDATO:	ds 1			; DATA XREF: fwUpdate+1Ao
					; fwUpdate:code_582o ...
					; I2C interface	Transmit data register
I2CDATI:	ds 1
I2CADR:		ds 1			; DATA XREF: fwUpdate+Ao
					; I2c interface	address	register
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
CPTVSLH:	ds 1			; CODEC	port interface valid slots register (high byte)
CPTVSLL:	ds 1			; CODEC	port interface valid slots register (low byte)
CPTDATH:	ds 1			; CODEC	port interface data register (high byte)
CPTDATL:	ds 1			; CODEC	port interface data register (low byte)
CPTADR:		ds 1			; CODEC	port interface address register
CPTCTL:		ds 1			; DATA XREF: setCodecDmao
					; CODEC	port interface control and status register
CPTCNF4:	ds 1			; DATA XREF: setCodecDma+59o
					; CODEC	port interface configuration register 4
CPTCNF3:	ds 1			; DATA XREF: setCodecDma+53o
					; CODEC	port interface configuration register 3
CPTCNF2:	ds 1			; DATA XREF: setCodecDma+4Do
					; CODEC	port interface configuration register 2
CPTCNF1:	ds 1			; DATA XREF: setCodecDma+47o
					; RESET_0-346o
					; CODEC	port interface configuration register 1
ACGCTL:		ds 1			; DATA XREF: usb_init+14o
					; Adaptive clock generator control register
ACGDCTL:	ds 1			; DATA XREF: usb_init+Eo
					; Adaptive clock generator divider control register
ACGCAPH:	ds 1			; Adaptive clock generator mclk	capture	register (high byte)
ACGCAPL:	ds 1			; Adaptive clock generator mclk	capture	register (low byte)
ACGFRQ2:	ds 1			; DATA XREF: usb_inito
					; Adaptive clock generator frequency register (byte 2)
ACGFRQ1:	ds 1			; Adaptive clock generator frequency register (byte 1)
ACGFRQ0:	ds 1			; Adaptive clock generator frequency register (byte 0)
DMACTL0:	ds 1			; DATA XREF: setCodecDma+69o
					; DMA channel 0	control	register
DMATSH0:	ds 1			; DATA XREF: setCodecDma+5Fo
					; DMA channel 0	time slot assignment register (high byte)
DMATSL0:	ds 1			; DMA channel 0	time slot assignment register (low byte)
		ds 1
		ds 1
		ds 1
DMACTL1:	ds 1			; DATA XREF: setCodecDma+79o
					; DMA channel 1	control	register
DMATSH1:	ds 1			; DATA XREF: setCodecDma+6Fo
					; DMA channel 1	time slot assignment register (high byte)
DMATSL1:	ds 1			; DMA channel 1	time slot assignment register (low byte)
		ds 1
		ds 1
		ds 1
DMACTL2:	ds 1			; DATA XREF: setCodecDma+7Fo
					; DMA channel 2	control	register
DMATSH2:	ds 1			; DMA channel 2	time slot assignment register (high byte)
DMATSL2:	ds 1			; DMA channel 2	time slot assignment register (low byte)
DMACTL3:	ds 1			; DMA channel 3	control	register
DMATSH3:	ds 1			; DMA channel 3	time slot assignment register (high byte)
DMATSL3:	ds 1			; DMA channel 3	time slot assignment register (low byte)
USBFNH:		ds 1			; USB frame number register (high byte)
USBFNL:		ds 1			; USB frame number register (low byte)
USBCTL:		ds 1			; DATA XREF: usb_init+8Fo
					; USB control register
USBIMSK:	ds 1			; DATA XREF: usb_init+75o code_B01+3o
					; USB interrupt	mask register
USBSTA:		ds 1			; USB status register
USBFADR:	ds 1			; DATA XREF: usb_in_ep0+79o
					; usb_init+71o	...
; end of 'code'                         ; USB function address register


; ===========================================================================

; Segment type:	Internal processor memory & SFR
		;.segment RAM
		DSEG
RAM_0 equ 0				; DATA XREF: IE0_0+Dr code_52C+19w ...
RAM_1 equ 1				; DATA XREF: IE0_0+Fr code_52C+17w
RAM_2 equ 2				; DATA XREF: IE0_0+11r	code_52C+15w
RAM_3 equ 3				; DATA XREF: IE0_0+13r	code_52C+13w
RAM_4 equ 4				; DATA XREF: IE0_0+15r	code_52C+11w
RAM_5 equ 5				; DATA XREF: IE0_0+17r	code_52C+Fw
RAM_6 equ 6				; DATA XREF: IE0_0+19r	code_52C+Dw ...
RAM_7 equ 7				; DATA XREF: IE0_0+1Br	code_52C+Bw ...
RAM_8 equ 8				; DATA XREF: usbrequest+1w
					; usbrequest+Cw ...
desc_len_H equ 9			; DATA XREF: usbreqgetdescr+1w
					; usbreqgetdescr+18w ...
desc_len_L equ 0Ah			; DATA XREF: usbreqgetdescr+3w
					; usbreqgetdescr+1Bw ...
RAM_B equ 0Bh				; DATA XREF: usbreqgetdescr+24w
					; usbreqgetdescr+43w ...
desc_H equ 0Ch				; DATA XREF: usbreqgetdescr+26w
					; usbreqgetdescr+45w ...
desc_L equ 0Dh				; DATA XREF: usbreqgetdescr+28w
					; usbreqgetdescr+47w ...
RAM_E equ 0Eh				; DATA XREF: usbreqgetdescr+5w
RAM_F equ 0Fh				; DATA XREF: usbreqgetdescr+8w
RAM_10 equ 10h				; DATA XREF: RESET_0-35Bw
RAM_11 equ 11h				; DATA XREF: serBtoUsbMidOut+65w
					; serBtoUsbMidOut:midiOutCpLoopr ...
RAM_12 equ 12h				; DATA XREF: serBtoUsbMidOut+5Cw
					; serBtoUsbMidOut+5Er ...
RAM_13 equ 13h				; DATA XREF: serBtoUsbMidOut+2w
					; serBtoUsbMidOut+Er ...
RAM_14 equ 14h				; DATA XREF: serBtoUsbMidOut+5w
					; serBtoUsbMidOut+10r ...
RAM_15 equ 15h				; DATA XREF: serBtoUsbMidOut+8w
					; serBtoUsbMidOut+12r ...
SerInMidiPtr equ 16h			; DATA XREF: RI_TI_0+15r RI_TI_0+1Dr ...
SerMidiOutPtr equ 17h			; DATA XREF: RI_TI_0+17r ser_init+5w ...
SerMidiInPtr equ 18h			; DATA XREF: RI_TI_0+2Fr ser_init+Bw ...
SerOutMidiPtr equ 19h			; DATA XREF: RI_TI_0+31r RI_TI_0+35r ...
pgmchng	equ 1Ah				; DATA XREF: usbMidiInToSerB:code_203w
					; usbMidiInToSerB+5Cr

RAM_1C equ 1Ch				; DATA XREF: serBtoUsbMidOut+B7r
					; serBtoUsbMidOut+B9w

RAM_1E equ 1Eh				; DATA XREF: RESET_0-34Ew RESET_0-317r ...
usb_out_ep1 equ	1Fh			; DATA XREF: code_50Cw	RESET_0-34Cw ...
GlobSt2t equ 20h			; DATA XREF: serBtoUsbMidOut+Br
					; serBtoUsbMidOut+42w ...
					; 4: setup long	response
					; 5: debug response
GlobStat equ 21h			; DATA XREF: serBtoUsbMidOutw
					; serBtoUsbMidOut:code_7Ar ...
					; 3: rx	buff
					; 4: tx	buff empty
					; 6: enable response counter
bmReqRam equ 22h			; DATA XREF: usb_setup_st+30w
					; usb_setup_st:code_2C2r ...
bReqRam	equ 23h				; DATA XREF: usb_setup_st+34w
					; usbreqhndlr+5r ...
wValRamH equ 24h			; DATA XREF: usb_setup_st+3Cw
					; usbreqgetdescr+5r ...
wValRamL equ 25h			; DATA XREF: usb_in_ep0+7Cr
					; usb_setup_st+38w ...
wIdxRamH equ 26h			; DATA XREF: usb_setup_st+44w
wIdxRamL equ 27h			; DATA XREF: usb_setup_st+40w
					; usbreqgetstat:code_712r ...
wLenRamH equ 28h			; DATA XREF: usbPrepResp+5r
					; usbPrepResp:desctoolongr ...
wLenRamL equ 29h			; DATA XREF: usbPrepResp+2r
					; usbPrepResp+12r ...
RAM_2A equ 2Ah				; DATA XREF: usbreqgetstat+Ew
					; usbreqgetstat+26w ...
RAM_2B equ 2Bh				; DATA XREF: usbreqgetstat+12w
					; usbreqgetstat+28w ...






















RAM_42 equ 42h				; DATA XREF: usbsetup_ep1+4w
					; usbreqgetconfr ...
usbDatCnt equ 43h			; DATA XREF: usbTxResp_iep0+6r
					; usbTxResp_iep0+11w ...
usbRespLenH equ	44h			; DATA XREF: usbPrepResp+9w
					; usbPrepResp:desctoolongw ...
usbRespLenL equ	45h			; DATA XREF: usbPrepResp+Bw
					; usbPrepResp+12w ...
RAM_46 equ 46h				; DATA XREF: usb_setup_st:code_2B1w
					; usb_out_ep0r	...
RAM_47 equ 47h				; DATA XREF: usb_in_ep0:code_FEr
					; usb_in_ep0:code_107r	...
usbRespCfg equ 48h			; DATA XREF: usbPrepResp:code_1Bw
					; usbTxResp_iep0+19r
usbRespH equ 49h			; DATA XREF: usbPrepResp+17w
					; usbTxResp_iep0+1Br ...
usbRespL equ 4Ah			; DATA XREF: usbPrepResp+19w
					; usbTxResp_iep0+1Dr ...
RAM_4B equ 4Bh				; DATA XREF: usb_in_ep0r usb_in_ep0+5w ...
RAM_4C equ 4Ch				; DATA XREF: usb_setup_st+2Aw
					; usb_setup_st+9Ew ...
RAM_4D equ 4Dh				; DATA XREF: code_52Cw	code_B01+Dw ...
RAM_4E equ 4Eh				; DATA XREF: usb_in_ep0:code_11Ar
					; usb_in_ep0:code_14Ar	...
RAM_4F equ 4Fh				; DATA XREF: usbreqgetstat+Er
					; usbreqclrftr+17w ...
MIDI_OUT_BUF equ 50h			; DATA XREF: RI_TI_0+21o
					; readMidiOutBuf+Co

MIDI_IN_BUF equ	58h			; DATA XREF: RI_TI_0+39o
					; writeMidiInBuf+4o
STACK equ 5Fh				; DATA XREF: RESET_0+6o
































RAM_80 equ 80h
RAM_81 equ 81h






























































































































; end of 'RAM'

; ===========================================================================

; Segment type:	Internal processor memory & SFR
		;.segment FSR
		DSEG
; org 80h
;P0 equ 80h				; Port 0
;SP equ 81h				; DATA XREF: RESET_0+6w
					; Stack	Pointer
;DPL equ	82h				; DATA XREF: usbMidiInToSerB+3Bw
					; IE0_0+6r ...
					; Data Pointer,	Low Byte
;DPH equ	83h				; DATA XREF: usbMidiInToSerB+40w
					; IE0_0+4r ...
					; Data Pointer,	High Byte
RESERVED0084 equ 84h			; RESERVED
RESERVED0085 equ 85h			; RESERVED
RESERVED0086 equ 86h			; RESERVED
;PCON equ 87h				; DATA XREF: RESET_0-31Fw
					; Power	Control	Register
;TCON equ 88h				; DATA XREF: usb_init+89w
					; Timer	0/1 Control Register
;TMOD equ 89h				; Timer	Mode Register
;TL0 equ	8Ah				; Timer	0, Low Byte
;TL1 equ	8Bh				; Timer	1, Low Byte
;TH0 equ	8Ch				; Timer	0, High	Byte
;TH1 equ	8Dh				; Timer	1, High	Byte
RESERVED008E equ 8Eh			; RESERVED
RESERVED008F equ 8Fh			; RESERVED
;P1 equ 90h				; DATA XREF: usbMidiInToSerB:code_21Dw
					; usbMidiInToSerB+8Aw ...
					; Port 1
RESERVED0091 equ 91h			; RESERVED
RESERVED0092 equ 92h			; RESERVED
RESERVED0093 equ 93h			; RESERVED
RESERVED0094 equ 94h			; RESERVED
RESERVED0095 equ 95h			; RESERVED
RESERVED0096 equ 96h			; RESERVED
RESERVED0097 equ 97h			; RESERVED
;SCON equ 98h				; DATA XREF: RI_TI_0+Dr RI_TI_0+10w ...
					; Serial Channel Control Register
;SBUF equ 99h				; DATA XREF: RI_TI_0+12r RI_TI_0+3Dw
					; Serial Channel Buffer	Register
RESERVED009A equ 9Ah			; RESERVED
RESERVED009B equ 9Bh			; RESERVED
RESERVED009C equ 9Ch			; RESERVED
RESERVED009D equ 9Dh			; RESERVED
RESERVED009E equ 9Eh			; RESERVED
RESERVED009F equ 9Fh			; RESERVED
;P2 equ 0A0h				; Port 2
RESERVED00A1 equ 0A1h			; RESERVED
RESERVED00A2 equ 0A2h			; RESERVED
RESERVED00A3 equ 0A3h			; RESERVED
RESERVED00A4 equ 0A4h			; RESERVED
RESERVED00A5 equ 0A5h			; RESERVED
RESERVED00A6 equ 0A6h			; RESERVED
RESERVED00A7 equ 0A7h			; RESERVED
;IE equ 0A8h				; DATA XREF: usb_init+87w usb_init+8Bw ...
RESERVED00A9 equ 0A9h			; RESERVED
RESERVED00AA equ 0AAh			; RESERVED
RESERVED00AB equ 0ABh			; RESERVED
RESERVED00AC equ 0ACh			; RESERVED
RESERVED00AD equ 0ADh			; RESERVED
RESERVED00AE equ 0AEh			; RESERVED
RESERVED00AF equ 0AFh			; RESERVED
;P3 equ 0B0h				; Port 3
RESERVED00B1 equ 0B1h			; RESERVED
RESERVED00B2 equ 0B2h			; RESERVED
RESERVED00B3 equ 0B3h			; RESERVED
RESERVED00B4 equ 0B4h			; RESERVED
RESERVED00B5 equ 0B5h			; RESERVED
RESERVED00B6 equ 0B6h			; RESERVED
RESERVED00B7 equ 0B7h			; RESERVED
;IP equ 0B8h				; Interrupt Priority Register 0
RESERVED00B9 equ 0B9h			; RESERVED
RESERVED00BA equ 0BAh			; RESERVED
RESERVED00BB equ 0BBh			; RESERVED
RESERVED00BC equ 0BCh			; RESERVED
RESERVED00BD equ 0BDh			; RESERVED
RESERVED00BE equ 0BEh			; RESERVED
RESERVED00BF equ 0BFh			; RESERVED
RESERVED00C0 equ 0C0h			; RESERVED
RESERVED00C1 equ 0C1h			; RESERVED
RESERVED00C2 equ 0C2h			; RESERVED
RESERVED00C3 equ 0C3h			; RESERVED
RESERVED00C4 equ 0C4h			; RESERVED
RESERVED00C5 equ 0C5h			; RESERVED
RESERVED00C6 equ 0C6h			; RESERVED
RESERVED00C7 equ 0C7h			; RESERVED
T2CON equ 0C8h				; DATA XREF: ser_init+10w
					; Timer	2 Control Register
RESERVED00C9 equ 0C9h			; RESERVED
RC2L equ 0CAh				; DATA XREF: ser_init+16w
					; Timer	2 Reload/Capture Register, Low Byte
RC2H equ 0CBh				; DATA XREF: ser_init+13w
					; Timer	2 Reload/Capture Register, High	Byte
TL2 equ	0CCh				; Timer	2 Low Byte
TH2 equ	0CDh				; Timer	2 High Byte
RESERVED00CE equ 0CEh			; RESERVED
RESERVED00CF equ 0CFh			; RESERVED
;PSW equ	0D0h				; DATA XREF: IE0_0+8r IE0_0+Aw ...
					; Program Status Word Register
RESERVED00D1 equ 0D1h			; RESERVED
RESERVED00D2 equ 0D2h			; RESERVED
RESERVED00D3 equ 0D3h			; RESERVED
RESERVED00D4 equ 0D4h			; RESERVED
RESERVED00D5 equ 0D5h			; RESERVED
RESERVED00D6 equ 0D6h			; RESERVED
RESERVED00D7 equ 0D7h			; RESERVED
RESERVED00D8 equ 0D8h			; RESERVED
RESERVED00D9 equ 0D9h			; RESERVED
RESERVED00DA equ 0DAh			; RESERVED
RESERVED00DB equ 0DBh			; RESERVED
RESERVED00DC equ 0DCh			; RESERVED
RESERVED00DD equ 0DDh			; RESERVED
RESERVED00DE equ 0DEh			; RESERVED
RESERVED00DF equ 0DFh			; RESERVED
;ACC equ	0E0h				; DATA XREF: usb_in_ep0+1Dr
					; usbMidiInToSerB+8r ...
					; Accumulator
RESERVED00E1 equ 0E1h			; RESERVED
RESERVED00E2 equ 0E2h			; RESERVED
RESERVED00E3 equ 0E3h			; RESERVED
RESERVED00E4 equ 0E4h			; RESERVED
RESERVED00E5 equ 0E5h			; RESERVED
RESERVED00E6 equ 0E6h			; RESERVED
RESERVED00E7 equ 0E7h			; RESERVED
RESERVED00E8 equ 0E8h			; RESERVED
RESERVED00E9 equ 0E9h			; RESERVED
RESERVED00EA equ 0EAh			; RESERVED
RESERVED00EB equ 0EBh			; RESERVED
RESERVED00EC equ 0ECh			; RESERVED
RESERVED00ED equ 0EDh			; RESERVED
RESERVED00EE equ 0EEh			; RESERVED
RESERVED00EF equ 0EFh			; RESERVED
;B equ 0F0h				; DATA XREF: IE0_0+2r code_52C+21w
					; B Register
RESERVED00F1 equ 0F1h			; RESERVED
RESERVED00F2 equ 0F2h			; RESERVED
RESERVED00F3 equ 0F3h			; RESERVED
RESERVED00F4 equ 0F4h			; RESERVED
RESERVED00F5 equ 0F5h			; RESERVED
RESERVED00F6 equ 0F6h			; RESERVED
RESERVED00F7 equ 0F7h			; RESERVED
RESERVED00F8 equ 0F8h			; RESERVED
RESERVED00F9 equ 0F9h			; RESERVED
RESERVED00FA equ 0FAh			; RESERVED
RESERVED00FB equ 0FBh			; RESERVED
RESERVED00FC equ 0FCh			; RESERVED
RESERVED00FD equ 0FDh			; RESERVED

RESERVED00FF equ 0FFh			; RESERVED
; end of 'FSR'


		end ;RESET
