.model small

.stack 100

.data
	figures db "..#...#..##....."; J
	I       db "..#...#...#...#."; I
	L       db ".#...#...##....."; L
	O       db ".....##..##....."; O
	S       db ".#...##...#....."; S
	T       db ".....###..#....."; T
	Z       db "....##...##....."; Z


	spawnArea db "#..........#"
	spawnAre2 db "#..........#"
	spawnAre3 db "#..........#"
	spawnAre4 db "#..........#"
	mapBuffer db "#..........#"; FIRSTROW
	SECONDROW db "#..........#"; SECONDROW 
	THIRDROW  db "#..........#"; THIRDROW  
	FOURTHROW db "#..........#"; FOURTHROW 
	FIFTHROW  db "#..........#"; FIFTHROW  
	SIXTHROW  db "#..........#"; SIXTHROW  
	SEVENTROW db "#..........#"; SEVENTROW 
	EIGTHROW  db "#..........#"; EIGTHROW  
	NINTHROW  db "#..........#"; NINTHROW  
	TENTHROW  db "#..........#"; TENTHROW  
	ELEVENROW db "#..........#"; ELEVENROW 
	TWELWTROW db "#..........#"; TWELWTROW 
	THIRTEROW db "#..........#"; THIRTEROW 
	FOURTEROW db "#..........#"; FOURTEROW 
	FIFTINROW db "#..........#"; FIFTINROW 
	SIXTEEROW db "#..........#"; SIXTEEROW 
	SEVENTEER db "#..........#"; SEVENTEEROW
	SEVENTEOW db "#..........#"; SEVENTEOW 
	EIGHTEROW db "############"; EIGHTEROW
 
	drawBuff   db "#..........#"
	drawBuff2  db "#..........#"
	drawBuff3  db "#..........#"
	drawBuff4  db "#..........#"
	drawBuff5  db "#..........#"
	drawBuff6  db "#..........#"
	drawBuff7  db "#..........#"
	drawBuff8  db "#..........#"
	drawBuff9  db "#..........#"
	drawBuff10 db "#..........#"
	drawBuff11 db "#..........#"
	drawBuff12 db "#..........#"
	drawBuff13 db "#..........#"
	drawBuff14 db "#..........#"
	drawBuff15 db "#..........#"
	drawBuff16 db "#..........#"
	drawBuff17 db "#..........#"
	drawBuff18 db "#..........#"
	drawBuff19 db "############"

;strings
	couldntOpen db "Couldn't open save.txt file,", 10, "default saves will be loaded"
	newLine1 db  13, 10, "$"
	couldntOpen2 db "Couldn't write to save.txt", 10,  "file, saves will be discarded"
	newLine2 db  13, 10, "$"
	askForName db "Please enter your name(3 chars): "
	newline3 db 13, 10, "$"
	hiScores db "High Scores"
	newLine4 db  13, 10, "$"
	twoZeros db "00$"
	youLost db "You lost, final score $"
	helpAnswer db "Tetris, sukure Denisas Sav, islieta daug valandu ir nervu, mazohizmas$"
	;string used to output to screen
	;                name score
	writingString db "DEF 65535$"
	numberBufferString db "00000"
	convertedNumber dw 0

	userNameBuffer db 4, ?, "    "
;save data
	saveFileName db "SAVE.TXT", 0

	firstName db "DEF $"
	firstScore dw 0h
	secondName db "DEF $"
	secondScore dw 0h
	thirdName db "DEF $"
	thirdScore dw 0h
	playerName db "DEF $"
	playerScore dw 0h


;highscores
	isPlayerDrawn db 0

;figure variables
	shapeIndex db 1
	shapeColor db 'R'
	shapeX dw 0
	shapeY dw 3
	shapeRotation db 2
	shapeIth dw 0
	shapeJth dw 0


;random Num
	randomNum db 0
	ranRemainder db 0
	lastSalt dw 0

;input
	inputKeyCode db 0
	inputBufferNotEmpty db 0

;logic
	rowCheckIndex dw 0
	isRowFull dw 0

;logicMoving
	numberOfIterationsToFall dw 0
	shapeCanFit dw 0

;logicFitting
	offsetShapeRotation dw 0
	offsetShapeX dw 0
	offsetShapeY dw 0

;rotate
	isShape db 0

;drawing variables
	numberToConvert dw 0
	drawNumBuffer db "00000$"

	xIter dw 0
	yIter dw 0

	x dw 0
	prevX dw 0
	y dw 0

	color db 0;now used color

	drawX dw 0
	drawY dw 0

	spalvosKodai db 11, 1, 6, 14, 2, 5, 4, 0, 15
	spalvuVardai db 'C', 'B', 'O', 'Y', 'G', 'P', 'R', '.', '#'

.code

start:

	MOV AX, @data
	MOV DS, AX


	call checkForHelp
	
	; video mode
	MOV AH, 00h 
	MOV AL, 13h 
	INT 10h 
	
	;call writeDataToFile
	;call exit

	call openFileReadData
	;call writeDataToFile
	;call exit
	call askUserForName
	call clearScreen
    call generateNewShape

gameLoop:

	call getLastPressedButtonKeyCode
	;call getInputKeyCode
	call handleInput


	INC numberOfIterationsToFall
	CMP numberOfIterationsToFall, 10
	JNE skipShapeFalling
	MOV numberOfIterationsToFall, 0
	call handleShapeFalling
	skipShapeFalling:

	call clearFullRows
	call drawGridToBuffer
	call drawShapeToBuffer
	call drawBuffer
	call drawScores
	

JMP gameLoop

	call exit


;TODO FINISH WRITING THIS PIECE OF &^*%$ CODE
checkForHelp:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, 80H

	skipSpaces:
	INC BX
	MOV AL, ES:[BX]
	CMP AL, ' '
	JE skipSpaces	

	MOV AX, ES:[BX]
	CMP AX, "?/"
	JNE endCheckForHelp
	INC BX
	MOV AX, ES:[BX]
	CMP AH, 13
	JNE endCheckForHelp

	MOV DX, offset helpAnswer
	MOV AH, 09h
	INT 21h

	call exitNoClear

	endCheckForHelp:
	POP DX
	POP CX
	POP BX
	POP AX
	ret

writeDataToFile:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	;deleting prev save file
	MOV DX, offset saveFileName
	MOV AH, 41H
	INT 21H

	;create file
	XOR CX, CX
	MOV AH, 3Ch
	INT 21h

	;file handle to bx
	MOV BX, AX
	MOV DI, offset firstName
	MOV isPlayerDrawn, 0
	JC couldntCreateFile

	XOR CX, CX
	drawScoresToFile:
	CMP isPlayerDrawn, 1
	JE skipPlayerToFile
	MOV DX, [DI + 5]
	CMP DX, playerScore
	JAE skipPlayerToFile
	MOV isPlayerDrawn, 1
;
	MOV DX, offset playerName
	MOV AH, 40h
	PUSH CX
	MOV CX, 4
	INT 21h
	POP CX

	MOV AX, playerScore
	MOV numberToConvert, AX
	call convertNumToString

	MOV DX, offset drawNumBuffer
	MOV AH, 40h
	PUSH CX
	MOV CX, 5
	INT 21h

	MOV DX, offset newLine1
	MOV AH, 40h
	MOV CX, 2
	INT 21h
	POP CX


	JMP drawLoopEnding
	skipPlayerToFile:
	MOV DX, DI
	MOV AH, 40h
	PUSH CX
	MOV CX, 4
	INT 21h


	MOV AX, [DI + 5]
	MOV numberToConvert, AX
	call convertNumToString

	MOV DX, offset drawNumBuffer
	MOV AH, 40h
	MOV CX, 5
	INT 21h

	MOV DX, offset newLine1
	MOV AH, 40h
	MOV CX, 2
	INT 21h
	POP CX
	
	ADD DI, 7
    drawLoopEnding:
	INC CX
	CMP CX, 3
	JB drawScoresToFile
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
		;close file
	MOV AH, 3Eh
	INT 21h

	JMP fileWritten
	couldntCreateFile:
	MOV DX, offset couldntOpen2
	MOV AH, 09h
	INT 21h

	fileWritten:
	POP DX
	POP CX
	POP BX
	POP AX
	ret

sleepFunction:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV  CX, 016H
	MOV  DX, 0F240H
	MOV  AH, 86H
	INT  15H
	
	POP DX
	POP CX
	POP BX
	POP AX
	ret

handleLoss:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	call clearScreen

	MOV AH, 02H
	MOV DH, 3
	MOV DL, 5
	INT 10H

	MOV DX, offset youLost
	MOV AH, 09h
	INT 21h

	MOV AX, playerScore
	MOV numberToConvert, AX
	CALL convertNumToString
	CALL removeTrailingZeros
	MOV DX, offset drawNumBuffer
	MOV AH, 09h
	INT 21h
	MOV DX, offset twoZeros
	MOV AH, 09h
	INT 21h

	MOV DX, offset newLine1
	MOV AH, 09h
	INT 21h
	MOV DX, offset newLine1
	MOV AH, 09h
	INT 21h

	call writeDataToFile
	
	call sleepFunction

	call exit

	POP DX
	POP CX
	POP BX
	POP AX
	ret
removeTrailingZeros:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, offset drawNumBuffer

	MOV CX, 0
	removingZeros:
	MOV AL, [BX]
	CMP AL, '0'
	JNE endNotZero
	MOV AL, ' '
	MOV [BX], AL
	INC BX
	INC CX
	CMP CX, 4
	JB removingZeros
	endNotZero:

	POP DX
	POP CX
	POP BX
	POP AX
	ret

convertNumToString:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, offset drawNumBuffer + 4
	MOV AX, numberToConvert
	MOV CX, 10

	convertingNumToString:
	XOR DX, DX
	DIV CX
	ADD DL, '0'
	MOV [BX], DL
	DEC BX
	CMP BX, offset drawNumBuffer
	JAE convertingNumToString

	POP DX
	POP CX
	POP BX
	POP AX
	ret

drawScores:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV AH, 02H
	MOV DH, 3
	MOV DL, 24
	INT 10H
	MOV DX, offset hiScores
	MOV AH, 09h
	INT 21h

	MOV isPlayerDrawn, 0

	MOV BX, offset firstName

	MOV CX, 0
	drawScoresToScreen:

	PUSH BX
	MOV AH, 02H
	MOV DH, 4
	ADD DH, CL
	MOV DL, 24
	MOV BH, 0
	INT 10H
	POP BX

	CMP isPlayerDrawn, 1
	JE skipPlayerDraw
	MOV DX, [BX + 5]
	CMP DX, playerScore
	JAE skipPlayerDraw
	MOV isPlayerDrawn, 1

	MOV DX, offset playerName
	MOV AH, 09h
	INT 21h
	MOV AX, playerScore
	MOV numberToConvert, AX
	call drawScoreToScreen

	JMP hiScoreLoopEnd
	skipPlayerDraw:

	MOV DX, BX
	MOV AH, 09h
	INT 21h
	MOV AX, [BX + 5]
	MOV numberToConvert, AX
	call drawScoreToScreen
	ADD BX, 7

	hiScoreLoopEnd:
	INC CX
	CMP CX, 3
	JB drawScoresToScreen

	MOV AH, 02H
	MOV DH, 7
	MOV DL, 24
	MOV BH, 0
	INT 10H

	CMP isPlayerDrawn, 0
	JE playerWasntDrawn

	MOV DX, offset thirdName
	MOV AH, 09h
	INT 21h
	MOV AX, thirdScore
	MOV numberToConvert, AX
	call drawScoreToScreen

	JMP drawingScoresEnd
	playerWasntDrawn:
	
	
	MOV DX, offset playerName
	MOV AH, 09h
	INT 21h

	MOV AX, playerScore
	MOV numberToConvert, AX
	call drawScoreToScreen

	drawingScoresEnd:
	POP DX
	POP CX
	POP BX
	POP AX
	ret

drawScoreToScreen:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	CALL convertNumToString
	CALL removeTrailingZeros
	MOV DX, offset drawNumBuffer
	MOV AH, 09h
	INT 21h
	MOV DX, offset twoZeros
	MOV AH, 09h
	INT 21h

	POP DX
	POP CX
	POP BX
	POP AX
	ret

clearScreen:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV color, 0
	MOV y, 0
	MOV x, 0
	MOV CX, 0
	clearingY:
	MOV y, CX
	PUSH CX
		MOV CX, 0
		clearingX:
		MOV x, CX
		call drawSquare
		INC CX
		CMP CX, 32
		JB clearingX
	POP CX
	INC CX
	CMP CX, 20
	JB clearingY

	MOV y, 0
	MOV x, 0

	POP DX
	POP CX
	POP BX
	POP AX
	ret

askUserForName:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV DX, offset askForName
	MOV AH, 09h
	INT 21h

	MOV DX, offset userNameBuffer
	MOV AH, 0Ah
	INT 21h

	MOV BX, offset userNameBuffer + 2
	MOV CX, 0
	MOV DI, offset playerName
	convertingBufferToUserName:
	MOV AL, [BX]
	;compare Big Letters
	CMP AL, 'A'
	JB checkSmallLetters
	CMP AL, 'Z'
	JA checkSmallLetters
	JMP sanitized
	;compare Small Letters
	checkSmallLetters:
	CMP AL, 'a'
	JB unindentifiedSymbol
	CMP AL, 'z'
	JA unindentifiedSymbol
	SUB AL, 32
	JMP sanitized
	unindentifiedSymbol:
	MOV AL, '?'
	sanitized:
	MOV [DI], AL
	INC BX
	INC DI
	INC CX;
	CMP CX, 3
	JB convertingBufferToUserName

	POP DX
	POP CX
	POP BX
	POP AX
	ret

openFileReadData:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV AL, 0;reading file
	MOV AH, 3DH;interrupt name
	MOV DX, offset saveFileName
	INT 21h;interrupt call
	JC openFileReadDataError
	MOV BX, AX;file handle
	MOV DX, offset firstName
;
	XOR CX, CX
	readingSaveData:
	PUSH CX
	    
	    MOV AH, 3Fh
		MOV CX, 4
		INT 21h

		PUSH DX
		MOV AH, 3Fh
		MOV DX, offset numberBufferString
		MOV CX, 5
		INT 21h
		POP DX

		call convertBufferToNumber
		MOV DI, DX
		MOV AX, convertedNumber
		MOV [DI + 5], AX
		MOV firstScore, AX

		PUSH DX
		MOV DX, offset numberBufferString
		MOV AH, 3Fh
		MOV CX, 2
		INT 21h
		POP DX
	POP CX
	INC CX
	ADD DX, 7
	CMP CX, 1
	JB readingSaveData
	;;close file
	MOV AH, 3Eh
	INT 21h


	JMP readFileEnd
	openFileReadDataError:
	MOV AH, 09H
	MOV DX, offset couldntOpen
	INT 21h
	readFileEnd:
	
	POP DX
	POP CX
	POP BX
	POP AX
	ret

convertBufferToNumber:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, offset numberBufferString
	XOR CX, CX
	XOR AX, AX
	convertingSymbolsToNum:
	MOV DX, 10
	MUL DX
	;
	MOV DL, [BX]
	SUB DL, '0'
	XOR DH, DH
	;;;;;;;;;;;;;;;;;KAS PER NESAMONE
	ADD AX, DX
;
	INC BX
	INC CX
	CMP CX, 5
	JB convertingSymbolsToNum
;	

	;;;WTF
	MOV convertedNumber, AX

	POP DX
	POP CX
	POP BX
	POP AX
	ret

;w = 11
;a = 1E
;s = 1F
;d = 20
handleInput:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	;ESC 01H
	CMP inputKeyCode, 01H
	JNE skipESC
	call clearScreen
	call exit
	skipESC:

	;A 1EH
	CMP inputKeyCode, 1EH
	JNE skipA
	SUB shapeX, 1
	call checkCanShapeFit
	CMP shapeCanFit, 1
	JE shapeFitA
	ADD shapeX, 1
	shapeFitA:
	skipA:

	;D
	CMP inputKeyCode, 20H
	JNE skipD
	ADD shapeX, 1
	call checkCanShapeFit
	CMP shapeCanFit, 1
	JE shapeFitD
	SUB shapeX, 1
	shapeFitD:
	skipD:

	;W
	CMP inputKeyCode, 11H
	JNE skipW
	ADD shapeRotation, 1
	CMP shapeRotation, 4
	JB shapeRotationW
	SUB shapeRotation, 4
	shapeRotationW:
	call checkCanShapeFit
	CMP shapeCanFit, 1
	JE shapeFitW
	SUB shapeRotation, 1
	CMP shapeRotation, -1
	JNE dontAddFour
	ADD shapeRotation, 4
	dontAddFour:
	shapeFitW:
	skipW:

	;S
	CMP inputKeyCode, 1FH
	JNE skipS
	ADD shapeY, 1
	call checkCanShapeFit
	CMP shapeCanFit, 1
	JE shapeFitS
	SUB shapeY, 1
	shapeFitS:
	skipS:

	MOV inputKeyCode, 0

	POP DX
	POP CX
	POP BX
	POP AX
	ret

checkIfInputBufferEmpty:
	PUSH AX
	MOV inputBufferNotEmpty, 0
	mov ah, 01h
 	int 16h
	JNZ inputBufferCheckedEmpty
	MOV inputBufferNotEmpty, 1
	inputBufferCheckedEmpty:
	POP AX
	ret

getInputKeyCode:
	PUSH AX
	XOR AH, AH
	INT 16h
	MOV inputKeyCode, AH
	POP AX
	ret


getLastPressedButtonKeyCode:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	loopClearInputBuffer:
	call checkIfInputBufferEmpty
	CMP inputBufferNotEmpty, 1
	JE noKeyWasPressed
	CALL getInputKeyCode
	JMP loopClearInputBuffer
	noKeyWasPressed:

	POP DX
	POP CX
	POP BX
	POP AX
	ret


fitShapeInGrid:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, 12
	MOV AX, shapeY
	MUL BL
	MOV BX, AX
	ADD BX, offset spawnArea
	ADD BX, shapeX

	MOV AL, shapeColor

	MOV DX, 0
	drawShapeToBufferYfit:
		MOV CX, 0
		MOV shapeJth, 0
		MOV SI, 0
		drawShapeToBufferXfit:
			call rotation
			CMP isShape, 0
			JE skipDrawingShapefit
			MOV [BX + SI], AL
			skipDrawingShapefit:
			INC shapeJth
			INC SI
		INC CX
		CMP CX, 4
		JB drawShapeToBufferXfit
		INC shapeIth
		ADD BX, 12
	INC DX
	CMP DX, 4
	JB drawShapeToBufferYfit

	MOV shapeIth, 0
	MOV shapeJth, 0

	POP DX
	POP CX
	POP BX
	POP AX
	ret

generateNewShape:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV shapeX, 4
	MOV shapeY, 0
	call genNum
	MOV DL, 7
	call numModulus
	MOV BH, 0
	MOV BL, ranRemainder
	MOV DL, [spalvuVardai + BX]
	MOV shapeColor, DL

	call genNum
	MOV DL, 7
	call numModulus
	MOV DL, ranRemainder
	MOV shapeIndex, DL

	call genNum
	MOV DL, 4
	call numModulus
	MOV DL, ranRemainder
	MOV shapeRotation, DL

	POP DX
	POP CX
	POP BX
	POP AX
	ret

;function broken
checkCanShapeFit:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX


    MOV shapeCanFit, 1

	MOV AX, 12
	MOV DX, shapeY
	MUL DL

	MOV BX, AX
	ADD BX, shapeX
	ADD BX, offset spawnArea

	MOV CX, 0
	loopYCheckCanFit:
		MOV shapeIth, CX

		PUSH CX
		MOV CX, 0
		loopXCheckCanFit:
		MOV shapeJth, CX

		CALL rotation
		CMP isShape,0
		JE skipCanFitCheck
		ADD BX, CX
		MOV AL, '.'
		CMP [BX], AL
		JE shapeCanFitHere
		MOV shapeCanFit, 0
		shapeCanFitHere:
		SUB BX, CX
		skipCanFitCheck:
		INC CX
		CMP CX, 4
		JNE loopXCheckCanFit
		POP CX
		ADD BX, 12
	INC CX
	CMP CX, 4
	JNE loopYCheckCanFit
	MOV shapeIth, 0
	MOV shapeJth, 0

	POP DX
	POP CX
	POP BX
	POP AX
	ret

;testi is cia
handleShapeFalling:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	ADD shapeY, 1
	call checkCanShapeFit
	CMP shapeCanFit, 1
	JE shapeShouldntFall
	DEC shapeY
	call fitShapeInGrid
	call generateNewShape
	call checkCanShapeFit
	CMP shapeCanFit, 1
	JE shapeShouldntFall
	call handleLoss
	shapeShouldntFall:


	POP DX
	POP CX
	POP BX
	POP AX
	ret


;sugeneruoja 8 bitu numeri is laiko
genNum:
	MOV AH, 2Ch
	INT 21h
	XOR CX, DX
	XOR CX, lastSalt
	MOV lastSalt, CX
	MOV randomNum, CL
	ret

;istraukia 8 bitu liekana
numModulus:
	MOV AL, randomNum
	XOR AH, AH
	DIV DL
	MOV ranRemainder, AH
	RET


;funkcija kuri nukopijuoja eilute rowCheckIndex - 1 i rowCheckIndex
copyUpperRowToLower:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, offset spawnArea
	MOV AX, rowCheckIndex
	MOV DL, 12
	MUL DL
	ADD BX, AX
	INC BX

	MOV DL, 10
	loopingCopyingRow:
	MOV AL, DS:[BX - 12]
	MOV DS:[BX], AL
	INC BX
	DEC DL
	CMP DL, 0
	JA loopingCopyingRow

	POP DX
	POP CX
	POP BX
	POP AX
	ret

;funkcija kuri patikrina ar eilute indexuota su rowCheckIndex yra pilna
checkRow:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV AX, rowCheckIndex
	MOV DL, 12
	MUL DL
	INC AX

	MOV BX, AX
	ADD BX, offset spawnArea

	MOV isRowFull, 1
	MOV DL, '.'

	MOV AX, 10
	loopOverRow:
	CMP [BX], DL
	JNE rowCheckLoopEnding
	MOV isRowFull, 0
	rowCheckLoopEnding:
	INC BX
	DEC AX
	CMP AX, 0
	JNE loopOverRow

	POP DX
	POP CX
	POP BX
	POP AX
	ret

;isvalo pilnas eilutes ir nukelia likusias zemiau
clearFullRows:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV CX, 4
	checkingFullRowsLoop:
		MOV rowCheckIndex, CX
		call checkRow
		CMP isRowFull, 0
		JE skipRowsMoving
		MOV DX, CX
		rowsMovingLoop:
			MOV rowCheckIndex, DX
			call copyUpperRowToLower
			DEC DX
			CMP DX, 4
		JAE rowsMovingLoop
		INC playerScore
		skipRowsMoving:
	INC CX
	CMP CX, 22
	JNE checkingFullRowsLoop

	POP DX
	POP CX
	POP BX
	POP AX
	ret


;norint naudoti i shapeIth ikelti figuros y, i shapeJth ikelti figuros x
;funkcija kuri pasako ar tas shape'as pagal pasukima toje vietoje turi dali ar neturi,
rotation:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	;i BX ideda vieta nuo kurios prasideda figura
	XOR AX, AX
	MOV AL, shapeIndex
	MOV DL, 16
	MUL DL
	MOV BX, AX
	;pirma rotacija
	CMP shapeRotation, 0
	JNE notFirstRotation
	XOR AX, AX
	MOV AX, shapeIth
	MOV DL, 4
	MUL DL
	ADD BX, AX
	ADD BX, shapeJth
	ADD BX, offset figures
	notFirstRotation:
	;antra rotacija
	CMP shapeRotation, 1
	JNE notSecondRotation
	ADD BX, 12
	ADD BX, shapeIth
	MOV AX, shapeJth
	MOV DL, 4
	MUL DL
	SUB BX, AX
	notSecondRotation:
	;trecia rotacija
	CMP shapeRotation, 2
	JNE notThirdRotation
	ADD BX, 15
	SUB BX, shapeJth
	MOV AX, shapeIth
	MOV DL, 4
	MUL DL
	SUB BX, AX
	notThirdRotation:
	;ketvirta rotacija
	CMP shapeRotation, 3
	JNE notFourthRotation
	ADD BX, 3
	SUB BX, shapeIth
	MOV AX, shapeJth
	MOV DL, 4
	MUL DL
	ADD BX, AX
	notFourthRotation:

	MOV AL, [BX]
	MOV isShape, 0
	CMP AL, '.'
	JE thatPlaceIsEmpty
	MOV isShape, 1
	thatPlaceIsEmpty:


	POP DX
	POP CX
	POP BX
	POP AX
	ret

;piesia shapea, kuris dabar naudojamas
drawShapeToBuffer:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, 12
	MOV AX, shapeY
	MUL BL
	MOV BX, AX
	ADD BX, offset drawBuff
	ADD BX, shapeX

	MOV DL, shapeColor
	call findColorCode
	MOV AL, color

	MOV DX, 0
	drawShapeToBufferY:
		MOV CX, 0
		MOV shapeJth, 0
		CMP BX, offset drawBuff + 48
		JB shouldDrawShapeRow
		MOV SI, 0
		drawShapeToBufferX:
			call rotation
			CMP isShape, 0
			JE skipDrawingShape
			SUB SI, 48
			MOV [BX + SI], AL
			ADD SI, 48
			skipDrawingShape:
			INC shapeJth
			INC SI
		INC CX
		CMP CX, 4
		JB drawShapeToBufferX
		shouldDrawShapeRow:
		INC shapeIth
		ADD BX, 12
	INC DX
	CMP DX, 4
	JB drawShapeToBufferY

	MOV shapeIth, 0
	MOV shapeJth, 0

	POP DX
	POP CX
	POP BX
	POP AX
	ret


;piesia tetrio lauka
drawGridToBuffer:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	
	MOV CX, 0;
	MOV SI, offset mapBuffer
	MOV BX, offset drawBuff
	rowDraw:
		PUSH CX 
		MOV CX, 0 ; lauko eilutes ilgis

		;loopins per eilutes elementus
		colDraw:
			MOV DL, [SI]
			call findColorCode
			MOV DL, color
			MOV [BX], DL
			INC SI
			INC BX

		INC CX
		CMP CX, 12
		JB colDraw

		POP CX
	INC CX
	CMP CX, 19
	JB rowDraw

	;nupiesia figura
	
	POP DX
	POP CX
	POP BX
	POP AX
	ret

;konvertuoja simbolius i spalvu kodus, dl
findColorCode:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV BX, 9
	ieskoSpalvos:
		DEC BX
		CMP DL, [spalvuVardai + BX]
		JE spalvaRasta
		CMP BX, 0
	JAE ieskoSpalvos
	spalvaRasta:
	MOV AL, [spalvosKodai + BX]
	MOV color, AL
	POP DX
	POP CX
	POP BX
	POP AX
	ret


drawBuffer:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV BX, offset drawBuff

	MOV y, 0
	drawingY:
		MOV x, 0
		drawingX:
			MOV DL, DS:[BX]
			MOV color, DL
			call drawSquare
			INC BX
		INC x
		CMP x, 12
		JB drawingX

	INC y
	CMP y, 19
	JB drawingY

	POP DX
	POP CX
	POP BX
	POP AX
	ret

;piesia kvadrata
drawSquare:
	;suranda y kordinate pixeliais
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	;i drawY ideda y koordinate padauginta is 10
	MOV AX, y
	MOV BX, 10
	MUL BX
	MOV drawY, AX

	;i drawX ideda x koordinate padauginta is 10
	MOV AX, x
	MOV BX, 10
	MUL BX
	MOV drawX, AX

	;i DX ideda drawY nes jis atsako uz pixelio Y koordinate
	MOV DX, drawY

	;ciklo pixeliu dydis
	MOV BX, 10
	DEC DX
	drawCubeRow:
		DEC BX
		PUSH BX
		;ciklo pixeliu dydis
		MOV BX, 10
		INC DX
		;i CX ideda X koordinate nes jis atsako uz X
		MOV CX, drawX
		DEC CX
		drawCubeCol:
			INC CX
			DEC BX
			MOV AL, color
			MOV AH, 0CH
			INT 10H
		CMP BX, 0
		JA drawCubeCol
		POP BX
	CMP BX, 0
	JA drawCubeRow
	POP DX
	POP CX
	POP BX
	POP AX
	ret

exit:
	MOV AH, 00H
	MOV AL, 02H
	INT 10H
exitNoClear:

	MOV AX, 4C00H
	INT 21H

end start