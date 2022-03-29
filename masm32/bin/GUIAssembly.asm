;GUI in assmebly using MASM

;Compiler Directives and includes

.386				;Full 80386 instruction set and mode
.model flat, stdcall		;All 32 bit and later apps are flat. Used to include "tiny, etc."
option casemap:none		;Preserve the case of system identifiers but not our own

;Include files - headers and libs that we need for calling the system dlls like user32, gdi32, kernel32 etc.

include <E:\data\BCIT\Term2\COMP2721\ass\masm32\include\windows.inc>	;Main windows header file
include <E:\data\BCIT\Term2\COMP2721\ass\masm32\include\user32.inc>	;Windows, controls, etc
include <E:\data\BCIT\Term2\COMP2721\ass\masm32\include\kernel32.inc>	;Handles, modules, paths, etc.
include <E:\data\BCIT\Term2\COMP2721\ass\masm32\include\gdi32.inc>	;Painting into a device context

;Libs -- information needed to link our library to the system dll calls

includelib <E:\data\BCIT\Term2\COMP2721\ass\masm32\lib\kernel32.lib>		; Kernel32.dll
includelib <E:\data\BCIT\Term2\COMP2721\ass\masm32\lib\user32.lib>		; User32.dll
includelib <E:\data\BCIT\Term2\COMP2721\ass\masm32\lib\gdi32.lib>		; GDI32.dll

;Forward declarations - Our main entry point will call forward to WinMain, so we need to define it here

WinMain proto :DWORD,	:DWORD,	:DWORD,	:DWORD	;Forward declarations for main entry

;Constatns and Data

WindowWidth equ 640			;Size of Window
WindowHeight equ 480			

.DATA

ClassName	db "MyLittleWidnow", 0	;The name of our Window class
AppName		db "Here's a resizable Window", 0	;The name of our main window

.DATA?		;Uninitalized data - Basically just reserves address space

hInstance HINSTANCE ?			;Process ID of our application
CommandLine LPSTR   ?			;Pointer to command line text we were launched with

.CODE


MainEntry proc

	LOCAL sui:STARTUPINFOA		;Reserve stock space so we can load and inspect the STARTUPINFO

	push	NULL			;Get the instance handle of our app (NULL --> US)
	call	GetModuleHandle		;GetModuleHandle will return instance handle in EAX
	mov hInstance, eax		;Cache it in our golbal variable
	
	call GetCommandLineA		;Get the command line text pointer in EAX to pass on to main
	mov CommandLine, eax

	;Call our WinMain and then exit the process with whatever comes back from it
	

	lea eax, sui		;Get the STARTUPINFO for this process
	push eax
	call GetStartupInfoA	;Find out if wShowWindow should be used
	test sui.dwFlags, STARTF_USESHOWWINDOW
	jz @1
	push sui.wShowWindow	;If the show window flag bit is non zero, we use wShowWindow
	jmp @2

@1:
	push SW_SHOWDEFAULT

@2:
	push CommandLine
	push NULL
	push hInstance
	call WinMain
	
	push eax
	call ExitProcess

MainEntry endp


;WinMain -- Traditional signature for the main entry point of windows programs

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD

	LOCAL wc:WNDCLASSEX		;Create these vars on the stack, hence LOCAL
	LOCAL msg:MSG
	LOCAL hwnd:HWND

	mov wc.cbSize, SIZEOF WNDCLASSEX	;Fill in the values in the members of our windows class
	mov wc.style, CS_HREDRAW or CS_VREDRAW	;Redraw if resized
	mov wc.lpfnWndProc, OFFSET WndProc	;Callback function to handle windows msgs
	mov wc.cbClsExtra, 0			;No extra class data
	mov wc.cbWndExtra, 0			;No extra window data

	mov eax, hInstance
	mov wc.hInstance, eax			;Our instance handle
	mov wc.hbrBackground, COLOR_3DSHADOW+1	;Default brush colors are colors plus one
	mov wc.lpszMenuName, NULL		;No app menu
	mov wc.lpszClassName, OFFSET ClassName	;Window's className
	
	push IDI_APPLICATION			;Default APP icon
	push NULL
	call LoadIcon
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	
	push IDC_ARROW
	push NULL
	call LoadCursor
	mov wc.hCursor, eax
	
	lea eax, wc
	push eax
	call RegisterClassEx			;Register the windows class
	
	push NULL				;no bonus data, therefore null
	push hInstance				;app instance handle
	push NULL				;Menu Handle
	push NULL				;Parent Window
	push WindowHeight			;Requested height
	push WindowWidth			;Requested width
	push CW_USEDEFAULT			;Y
	push CW_USEDEFAULT			;X
	push WS_OVERLAPPEDWINDOW + WS_VISIBLE	;Window Style
	push OFFSET AppName			;Window title
	push OFFSET ClassName			;Window class Name
	push 0					;Extended style bits
	call CreateWindowExA
	cmp eax, NULL
	je WinMainRet				;Fail and return on NULL handle returned
	mov hwnd, eax				;Window handle is the result, returned in eax
	
	push eax				;Force a paint of our window
	call UpdateWindow


MessageLoop:
	push 0
	push 0
	push NULL
	lea eax, msg
	push eax
	call GetMessage
	
	cmp eax, 0
	je DoneMessages
	
	lea eax, msg
	push eax
	call TranslateMessage

	lea eax, msg
	push eax
	call DispatchMessage

	jmp MessageLoop

DoneMessages:
	mov eax, msg.wParam			;Return wParam of last message processed

WinMainRet:
	ret

WinMain endp
;WndProc-Main window procedure-handles painting and eciting

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL ps:PAINTSTRUCT			;Local stack variables
	LOCAL rect:RECT
	LOCAL hdc:HDC

	cmp uMsg, WM_DESTROY
	jne NotWMDestroy

	push 0					;WM_DESTROY received, post our quit msg
	call PostQuitMessage			;Quit our application
	xor eax, eax				;Return 0 to indicate we handled it
	ret

NotWMDestroy:
	cmp uMsg, WM_PAINT
	jne NotWMPaint

	lea eax, ps				;WM_PAINT received
	push eax
	push hWnd
	call BeginPaint				;GEt a device context to paint into

	mov hdc, eax
	push TRANSPARENT
	push hdc
	call SetBkMode				;Make text have a transparent backgrounf
	
	lea eax, rect				;figure out how big the client area is so we can
						;center over it
	push eax
	push hWnd
	call GetClientRect

	push DT_SINGLELINE + DT_CENTER + DT_VCENTER
	lea eax, rect
	push eax
	push -1
	push OFFSET AppName
	push hdc
	call DrawText				;Draw text centered vertically and horizontally
	
	lea eax, ps
	push eax
	push hWnd
	call EndPaint				;Wrap up painting

	xor eax, eax				;Return 0 as no furhter processing is needed
	ret

NotWMPaint:
	push lParam
	push wParam
	push uMsg
	push hWnd
	call DefWindowProc			;Forward message on to default processing
	ret					;return whateveer it does

WndProc endp

END MainEntry					;Specify entry point, else _WinMainCRTStartup is assumed


