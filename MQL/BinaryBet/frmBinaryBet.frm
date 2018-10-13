VERSION 5.00
Begin VB.Form frmBinaryBet 
   Caption         =   "Binary Bet"
   ClientHeight    =   3870
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   6045
   LinkTopic       =   "Form1"
   ScaleHeight     =   3870
   ScaleWidth      =   6045
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   495
      Left            =   600
      TabIndex        =   0
      Top             =   1680
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "Label3"
      Height          =   255
      Left            =   600
      TabIndex        =   3
      Top             =   3480
      Width           =   3255
   End
   Begin VB.Label Label2 
      Caption         =   "Label2"
      Height          =   255
      Left            =   600
      TabIndex        =   2
      Top             =   3000
      Width           =   2415
   End
   Begin VB.Label Label1 
      Caption         =   "Label1"
      Height          =   255
      Left            =   600
      TabIndex        =   1
      Top             =   2520
      Width           =   1335
   End
End
Attribute VB_Name = "frmBinaryBet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Sub Command1_Click()
    Dim AccBalance As Long
    Dim Draw As Integer, MaxDraws As Integer
    Dim Bet As Integer
    Dim BetSize As Long
    Dim RiskPct As Integer
    Dim TotRuns As Integer
    Dim MaxDrawDown As Long
    Dim i As Integer, d As Integer
    Randomize
    
    AccBalance = 10000
    MaxDrawDown = AccBalance
    MaxDraws = 20
    TotRuns = 100
    RiskPct = 2
    
    For d = 1 To TotRuns
        If Bet = 1 Then
            Bet = 0
        Else
            Bet = 1
        End If
        'BetSize = AccBalance * RiskPct / 100
        BetSize = 200
        MaxDrawDown = AccBalance
        'MaxDrawDown = 10000
        For i = 1 To MaxDraws
            Draw = Int(Rnd() * 2)
            If Draw = Bet Then
                AccBalance = AccBalance + BetSize
                Exit For
            Else
                AccBalance = AccBalance - BetSize
                If AccBalance < 0 Then
                    MsgBox "YOU'RE TOAST!", vbOKOnly
                    Exit For
                End If
                BetSize = 2 * BetSize
                If AccBalance < MaxDrawDown Then MaxDrawDown = AccBalance
            End If
        Next i
        Label1.Caption = Format$(AccBalance, "#,##0")
        Label2.Caption = "Finished after " & i & " bets."
        Label3.Caption = "Max Drawdown for the run= " & Format$(MaxDrawDown, "#,##0")
        If MsgBox("Run " & d & " Completed.", vbOKCancel) = vbCancel Then Exit For
    Next d
End Sub
