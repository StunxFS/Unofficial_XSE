Attribute VB_Name = "modSaveDialog"
Option Explicit

' Copyright � 2009 HackMew
' ------------------------------
' Feel free to create derivate works from it, as long as you clearly give me credits of my code and
' make available the source code of derivative programs or programs where you used parts of my code.
' Redistribution is allowed at the same conditions.

Private Const sMyName As String = "modSaveDialog"

Private Type OPENFILENAME
    lStructSize As Long
    hWndOwner As Long
    hInstance As Long
    lpstrFilter As Long
    lpstrCustomFilter As Long
    nMaxCustFilter As Long
    nFilterIndex As Long
    lpstrFile As Long
    nMaxFile As Long
    lpstrFileTitle As Long
    nMaxFileTitle As Long
    lpstrInitialDir As Long
    lpstrTitle As Long
    Flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    lpstrDefExt As Long
    lCustData As Long
    lpfnHook As Long
    lpTemplateName As Long
    pvReserved As Long
    dwReserved As Long
    FlagsEx As Long
End Type

Private Const MAX_PATH = 260&
Private Const OFN_OVERWRITEPROMPT = &H2&
Private Const OFN_PATHMUSTEXIST = &H800&
Private Const OFN_FILEMUSTEXIST = &H1000&

Public Enum SaveDialogFlags
    OverWritePrompt = OFN_OVERWRITEPROMPT
    SavePathMustExist = OFN_PATHMUSTEXIST
    SaveFileMustExist = OFN_FILEMUSTEXIST
End Enum

Private Declare Function GetSaveFileNameW Lib "comdlg32" (ByRef lpofn As OPENFILENAME) As Long

Private m_LastFileName As String
Private m_LastFilter As Long

Public Function ShowSave(ByVal hWndOwner As Long, Optional ByVal Title As String = "", Optional ByVal InitDir As String = "", Optional ByVal Filter As String = "All Files (*.*)|*.*|", Optional FilterIndex As Long = 0&, Optional DefaultExt As String = "", Optional DefaultFileName As String = "", Optional Flags As SaveDialogFlags = OverWritePrompt Or SavePathMustExist Or SaveFileMustExist) As String
Const sThis As String = "ShowSave"
Dim sFileName As String
Dim ofn As OPENFILENAME
    
    On Error GoTo LocalHandler
    
        ' Replace pipes with null characters
    Filter = Replace(Filter, "|", vbNullChar)
    
    ' Make sure the filter is null terminated
    If Right$(Filter, 1&) <> vbNullChar Then
        Filter = Filter & vbNullChar
    End If
    
    ' If the InitDir was not specified, use the last one
    If LenB(InitDir) = 0& Then
        InitDir = m_LastFileName
    End If
    
    ' Initialize the file name buffer
    If LenB(DefaultFileName) = 0& Then
        sFileName = String$(MAX_PATH, vbNullChar)
    Else
        sFileName = DefaultFileName & String$(MAX_PATH - Len(DefaultFileName), vbNullChar)
    End If
    
    ' Fill the OPENFILENAME structure
    With ofn
        .lStructSize = Len(ofn)
        .hWndOwner = hWndOwner
        .hInstance = App.hInstance
        .lpstrFilter = StrPtr(Filter)
        .nFilterIndex = FilterIndex
        .lpstrFile = StrPtr(sFileName)
        .nMaxFile = MAX_PATH
        .lpstrInitialDir = StrPtr(InitDir)
        .lpstrTitle = StrPtr(Title)
        .Flags = Flags
        .lpstrDefExt = StrPtr(DefaultExt)
    End With
    
    ' Check if a file was actually chosen
    If GetSaveFileNameW(ofn) Then
        
        ' Update the LastFileName value stripping the extra null characters
        m_LastFileName = Left$(sFileName, InStr(sFileName, vbNullChar) - 1&)
        
        ' Update the LastFilter
        m_LastFilter = ofn.nFilterIndex
        
        ' Set the return value
        ShowSave = m_LastFileName
        
    End If
    Exit Function
    
LocalHandler:

    Select Case GlobalHandler(sThis, sMyName)
        Case vbRetry
            Resume
        Case vbAbort
            Quit
        Case Else
            Resume Next
    End Select
       
End Function

Public Property Get SaveFilterIndex() As Long
    SaveFilterIndex = m_LastFilter
End Property
