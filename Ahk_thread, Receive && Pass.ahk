;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe
#Requires AutoHotkey v2.0+





/**ahk_thread, Receive && Pass**\
Receives or Sends Data from or to another ahk script\ahk thread.
	ahk_threadReceive(GroupID, Callback:=false)
	ahk_threadPass(GroupID, StringToSend, TimeOut)
  

ahk_threadReceive  | GroupID |
Specify any string you want which hasn't been taken by another a windows title.
Random gabldy guck is the best. Example: "w23jK65FdQ"
I recomend using a string about 10 charactors long. Though it can be as long as short or you'd like.
The GroupID is like a scripts phone number, If you have a phone and number you can reveive calls.
-------------------

ahk_threadPass  | GroupID |
Specify the GroupID of your receiving script.
Example From above: "w23jK65FdQ"
The GroupID is like a scripts phone number, If you have a phone and know some ones phone number you can call the them.
-------------------

ahk_threadReceive  | Callback |
Specify a Function to call back when a message is received.
The function you use must have one call back pram, or have the rest of the prams optional.
If omitted and a Callback has already been specified with a GroupID, when calling only that GroupID with no Callback the GroupID will be deleted and nolonger call to its Callback. Sort of like smashing your phone so no one can call you.
-------------------

ahk_threadPass  | StringToSend |
Specify a String or var to send its contents.
If omitted a 1 (True) is sent. Keep in mind you can use these Pass\Receive just to trigger a function in one script because another script told it to nothing needs to be passed.
-------------------

ahk_threadPass  | TimeOut |
Specify a the number of Milliseconds to wait for another script to receive the call and return it. 2 is the lowest value if you set it lower it will default back to 2.
If omitted it will default to 10ms almost instant.
For good mesure omit this or specify nothing lower than 10ms because of the OS speed, I really have no Idea how fast an OS is at this stuff so don't take my word for it.
-------------------

ahk_threadReceive	Notes:
(1) A callback function can only be set Once per script iteration.
(2) A GroupID can only have 1 callback function.
(3) A GroupID can be deleted down nolonger calling its function Callback.
(4) A GroupID can be reinitalized by specifing the GroupID and the CallBack But only with the function it started with, Specifing another function will just reinitalize the old one.
(5) A Pass and Receive work exactly the same if you have them in the same script as if you have them in seperate scripts.
-----; This Function was based off of the OnMessage page in the AutoHotkey v2 Docs Example #4, Which only worked for uncompiled scripts and wasn't a simple function. I've modified, perfected and added to it.

ahk_threadPass	Notes:
(1) If an Integer is sent it will be converted to a string, Don't worry it still works as a true or false statment a String 0 is the same as a integer 0 for if statments.
(2) A Pass and Receive work exactly the same if you have them in the same script as if you have them in seperate scripts.
-------------------

ahk_threadPass	Return Value:
If a pass is sucessful with in the TimeOut it returns a 1 (True). Else a 0 (False).
-------------------

ahk_threadReceive	Return Value:
When creating a Callback to a GroupID if the GroupID happens to be the name of a window that already exists a 0 (False) is returned and nothing happens. Else a 1 (True) is returned.
When deleting a GroupID by specifing a GroupID but not specifing a Callback. If the GroupID exists it will return 1 (True) Else if it does not 0 (False) is returned.
-------------------


	Example:
;#1 passes "A String to pass" throught the telephone wire XD.

ahk_threadReceive("w23jK65FdQ", SomeFunc)

SomeFunc(Data)
{
Msgbox(Data)
}

ahk_threadPass("w23jK65FdQ", "A String to pass") ; The script can pass to its self not just other scripts
-------------------


;#2 Shows how closing the GroupID will stop a message from coming through.

ahk_threadReceive("w23jK65FdQ", SomeFunc) ; Opens a GroupID to Receive messages.
Msgbox("Receiving a message 1")
ahk_threadPass("w23jK65FdQ", "A String to pass") ; Passes a message to the open GroupID.
ahk_threadReceive("w23jK65FdQ") ; Closes the GroupID so no Pass can give it messages.
Msgbox("Receiving a message 2") 
ahk_threadPass("w23jK65FdQ", "A String to pass") ;Trys passing a message to the GroupID but fails returning 0 because the ID is Closed.
ahk_threadReceive("w23jK65FdQ", SomeFunc) ; Reinitalizes the GroupID.
Msgbox("Receiving a message 3")
ahk_threadPass("w23jK65FdQ", "A String to pass") ; Passes a message to the reopened GroupID.

SomeFunc(Data)
{
Msgbox(Data)
}
-------------------


;#3 Passes a message and returns the result. Try running the 2 normal and the changing the GroupID of one of them to see it show a different result.

ahk_threadReceive("w23jK65FdQ", SomeFunc)
SomeFunc(Message)
{
Msgbox(Message)
}
;Put these lines /\ in the a new script.

;-----; Note: you CAN have then in in the same script works all the same, Putting them in 2 seperate ones shows the main purpose of these functions.

;Put the rest \/ in another.

If(ahk_threadPass("w23jK65FdQ", "Hello World!")) {
Msgbox("The Script with a GroupID w23jK65FdQ has responed and told me it got my message")
} Else {
Msgbox("No one responded, Prehaps there not at the phone right now...")
}
-------------------
\*******************************/





ahk_threadReceive(GroupID, Callback:=false)
{
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows True
    SetTitleMatchMode 3
	
	If(WinExist(GroupID) and Callback = false) {
	WinClose(GroupID)
	DetectHiddenWindows Prev_DetectHiddenWindows
    SetTitleMatchMode Prev_TitleMatchMode
		Return 1
	} Else If(WinExist(GroupID) and Callback = true) {
	DetectHiddenWindows Prev_DetectHiddenWindows
    SetTitleMatchMode Prev_TitleMatchMode
		Return 0
	}
	
MG := Gui("-Caption -Border", GroupID)
MG.Show("x0 y0 w0 h0 NoActivate")
WinHide(GroupID)
OnMessage 0x004A, Receive_WM_COPYDATA  ; 0x004A is WM_COPYDATA
Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
{
    StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
	SetTimer((*) => Callback(CopyOfData), -1)
    return true ; Returning 1 (true) is the traditional way to acknowledge this message.
}
	DetectHiddenWindows Prev_DetectHiddenWindows  ; Restore original setting for the caller.
    SetTitleMatchMode Prev_TitleMatchMode         ; Same.
Return 1
}

ahk_threadPass(GroupID, StringToSend:="1", TimeOut:=10)
{
	StringToSend := String(StringToSend)
	TimeOut := TimeOut<2 ? 2 : TimeOut
    CopyDataStruct := Buffer(3*A_PtrSize)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut( "Ptr", SizeInBytes  ; OS requires that this be done.
          , "Ptr", StrPtr(StringToSend)  ; Set lpData to point to the string itself.
          , CopyDataStruct, A_PtrSize)
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows True
    SetTitleMatchMode 3

try {
RetValue := SendMessage(0x004A, 0, CopyDataStruct,, GroupID,,,, TimeOut) ; 0x004A is WM_COPYDATA.
} Catch {
RetValue := 0
}
    DetectHiddenWindows Prev_DetectHiddenWindows  ; Restore original setting for the caller.
    SetTitleMatchMode Prev_TitleMatchMode         ; Same.
    return RetValue  ; Return SendMessage's reply back to our caller.
}
