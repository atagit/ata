#include "protheus.ch"

user function PREDANFE()
local oReport := TReport():New("PRE-DANFE","teste",/*cPerg*/,{|oReport| __PRPrint(oReport)},,,,,,,,)
local nI
local oBreak

oReport:SetTotalInLine(.F.)
oReport:SetTitle("Protheus Report Utility")
oReport:SetLineHeight(30)
oReport:SetColSpace(1)
oReport:SetLeftMargin(0)
oReport:oPage:SetPageNumber(1)
oReport:cFontBody := "Courier New"
oReport:nFontBody := 6
oReport:lBold := .F.
oReport:lUnderLine := .F.
oReport:lHeaderVisible := .T.
oReport:lFooterVisible := .T.
oReport:lParamPage := .F.

oTREPORT02 := TRSection():New(oReport,'Contas a Receber',,,,,,,,,,,,,,,,,,,)
oTREPORT02:SetTotalInLine(.F.)
oTREPORT02:SetTotalText('Contas a Receber')
oTREPORT02:lUserVisible := .T.
oTREPORT02:lHeaderVisible := .F.
oTREPORT02:SetLineStyle(.F.)
oTREPORT02:SetLineHeight(30)
oTREPORT02:SetColSpace(1)
oTREPORT02:SetLeftMargin(0)
oTREPORT02:SetLinesBefore(0)
oTREPORT02:SetCols(0)
oTREPORT02:SetHeaderSection(.T.)
oTREPORT02:SetHeaderPage(.F.)
oTREPORT02:SetHeaderBreak(.F.)
oTREPORT02:SetLineBreak(.F.)
oTREPORT02:SetAutoSize(.F.)
oTREPORT02:SetPageBreak(.F.)
oTREPORT02:SetClrBack(16777215)
oTREPORT02:SetClrFore(0)
oTREPORT02:SetBorder('')
oTREPORT02:SetBorder('',,,.T.)
oTREPORT02:aTable := {}
oTREPORT02:AddTable('SE1')
oTREPORT02:AddTable('SA1')
oTREPORT02:OnPrintLine({|| If(SE1->E1_FILIAL $ '01|02|', .T., .F.)})

TRCell():New(oTREPORT02,'__NEW__001','','',,,,,,,,,,,,)
oTREPORT02:Cell("__NEW__001"):SetName("A1_NOME")
oTREPORT02:Cell("A1_NOME"):cAlias := "SA1"
oTREPORT02:Cell("A1_NOME"):SetTitle("Nome")
oTREPORT02:Cell("A1_NOME"):SetSize(40)
oTREPORT02:Cell("A1_NOME"):SetPicture("@!")
oTREPORT02:Cell("A1_NOME"):SetAutoSize(.F.)
oTREPORT02:Cell("A1_NOME"):SetLineBreak(.F.)
oTREPORT02:Cell("A1_NOME"):SetHeaderSize(.F.)
oTREPORT02:Cell("A1_NOME"):nAlign := 1
oTREPORT02:Cell("A1_NOME"):nHeaderAlign := 1
oTREPORT02:Cell("A1_NOME"):SetClrBack(16777215)
oTREPORT02:Cell("A1_NOME"):SetClrFore(0)
oTREPORT02:Cell("A1_NOME"):cOrder := "A0"
oTREPORT02:Cell("A1_NOME"):nType := 1
oTREPORT02:Cell("A1_NOME"):cFormula := ""
oTREPORT02:Cell("A1_NOME"):cRealFormula := ""
oTREPORT02:Cell("A1_NOME"):cUserFunction := ""
oTREPORT02:Cell("A1_NOME"):lVisible := .T.
oTREPORT02:Cell("A1_NOME"):SetBorder("")
oTREPORT02:Cell("A1_NOME"):SetBorder("",,,.T.)

TRCell():New(oTREPORT02,'__NEW__002','','',,,,,,,,,,,,)
oTREPORT02:Cell("__NEW__002"):SetName("E1_PREFIXO")
oTREPORT02:Cell("E1_PREFIXO"):cAlias := "SE1"
oTREPORT02:Cell("E1_PREFIXO"):SetTitle("Prefixo")
oTREPORT02:Cell("E1_PREFIXO"):SetSize(3)
oTREPORT02:Cell("E1_PREFIXO"):SetPicture("@!")
oTREPORT02:Cell("E1_PREFIXO"):SetAutoSize(.F.)
oTREPORT02:Cell("E1_PREFIXO"):SetLineBreak(.F.)
oTREPORT02:Cell("E1_PREFIXO"):SetHeaderSize(.F.)
oTREPORT02:Cell("E1_PREFIXO"):nAlign := 1
oTREPORT02:Cell("E1_PREFIXO"):nHeaderAlign := 1
oTREPORT02:Cell("E1_PREFIXO"):SetClrBack(16777215)
oTREPORT02:Cell("E1_PREFIXO"):SetClrFore(0)
oTREPORT02:Cell("E1_PREFIXO"):cOrder := "A1"
oTREPORT02:Cell("E1_PREFIXO"):nType := 1
oTREPORT02:Cell("E1_PREFIXO"):cFormula := ""
oTREPORT02:Cell("E1_PREFIXO"):cRealFormula := ""
oTREPORT02:Cell("E1_PREFIXO"):cUserFunction := ""
oTREPORT02:Cell("E1_PREFIXO"):lVisible := .T.
oTREPORT02:Cell("E1_PREFIXO"):SetBorder("")
oTREPORT02:Cell("E1_PREFIXO"):SetBorder("",,,.T.)

TRCell():New(oTREPORT02,'__NEW__003','','',,,,,,,,,,,,)
oTREPORT02:Cell("__NEW__003"):SetName("E1_NUM")
oTREPORT02:Cell("E1_NUM"):cAlias := "SE1"
oTREPORT02:Cell("E1_NUM"):SetTitle("No. Titulo")
oTREPORT02:Cell("E1_NUM"):SetSize(9)
oTREPORT02:Cell("E1_NUM"):SetPicture("@!")
oTREPORT02:Cell("E1_NUM"):SetAutoSize(.F.)
oTREPORT02:Cell("E1_NUM"):SetLineBreak(.F.)
oTREPORT02:Cell("E1_NUM"):SetHeaderSize(.F.)
oTREPORT02:Cell("E1_NUM"):nAlign := 1
oTREPORT02:Cell("E1_NUM"):nHeaderAlign := 1
oTREPORT02:Cell("E1_NUM"):SetClrBack(16777215)
oTREPORT02:Cell("E1_NUM"):SetClrFore(0)
oTREPORT02:Cell("E1_NUM"):cOrder := "A2"
oTREPORT02:Cell("E1_NUM"):nType := 1
oTREPORT02:Cell("E1_NUM"):cFormula := ""
oTREPORT02:Cell("E1_NUM"):cRealFormula := ""
oTREPORT02:Cell("E1_NUM"):cUserFunction := ""
oTREPORT02:Cell("E1_NUM"):lVisible := .T.
oTREPORT02:Cell("E1_NUM"):SetBorder("")
oTREPORT02:Cell("E1_NUM"):SetBorder("",,,.T.)

TRCell():New(oTREPORT02,'__NEW__004','','',,,,,,,,,,,,)
oTREPORT02:Cell("__NEW__004"):SetName("E1_PARCELA")
oTREPORT02:Cell("E1_PARCELA"):cAlias := "SE1"
oTREPORT02:Cell("E1_PARCELA"):SetTitle("Parcela")
oTREPORT02:Cell("E1_PARCELA"):SetSize(1)
oTREPORT02:Cell("E1_PARCELA"):SetPicture("@!")
oTREPORT02:Cell("E1_PARCELA"):SetAutoSize(.F.)
oTREPORT02:Cell("E1_PARCELA"):SetLineBreak(.F.)
oTREPORT02:Cell("E1_PARCELA"):SetHeaderSize(.F.)
oTREPORT02:Cell("E1_PARCELA"):nAlign := 1
oTREPORT02:Cell("E1_PARCELA"):nHeaderAlign := 1
oTREPORT02:Cell("E1_PARCELA"):SetClrBack(16777215)
oTREPORT02:Cell("E1_PARCELA"):SetClrFore(0)
oTREPORT02:Cell("E1_PARCELA"):cOrder := "A3"
oTREPORT02:Cell("E1_PARCELA"):nType := 1
oTREPORT02:Cell("E1_PARCELA"):cFormula := ""
oTREPORT02:Cell("E1_PARCELA"):cRealFormula := ""
oTREPORT02:Cell("E1_PARCELA"):cUserFunction := ""
oTREPORT02:Cell("E1_PARCELA"):lVisible := .T.
oTREPORT02:Cell("E1_PARCELA"):SetBorder("")
oTREPORT02:Cell("E1_PARCELA"):SetBorder("",,,.T.)

TRCell():New(oTREPORT02,'__NEW__005','','',,,,,,,,,,,,)
oTREPORT02:Cell("__NEW__005"):SetName("E1_CLIENTE")
oTREPORT02:Cell("E1_CLIENTE"):cAlias := "SE1"
oTREPORT02:Cell("E1_CLIENTE"):SetTitle("Cliente")
oTREPORT02:Cell("E1_CLIENTE"):SetSize(6)
oTREPORT02:Cell("E1_CLIENTE"):SetPicture("@!")
oTREPORT02:Cell("E1_CLIENTE"):SetAutoSize(.F.)
oTREPORT02:Cell("E1_CLIENTE"):SetLineBreak(.F.)
oTREPORT02:Cell("E1_CLIENTE"):SetHeaderSize(.F.)
oTREPORT02:Cell("E1_CLIENTE"):nAlign := 1
oTREPORT02:Cell("E1_CLIENTE"):nHeaderAlign := 1
oTREPORT02:Cell("E1_CLIENTE"):SetClrBack(16777215)
oTREPORT02:Cell("E1_CLIENTE"):SetClrFore(0)
oTREPORT02:Cell("E1_CLIENTE"):cOrder := "A4"
oTREPORT02:Cell("E1_CLIENTE"):nType := 1
oTREPORT02:Cell("E1_CLIENTE"):cFormula := ""
oTREPORT02:Cell("E1_CLIENTE"):cRealFormula := ""
oTREPORT02:Cell("E1_CLIENTE"):cUserFunction := ""
oTREPORT02:Cell("E1_CLIENTE"):lVisible := .T.
oTREPORT02:Cell("E1_CLIENTE"):SetBorder("")
oTREPORT02:Cell("E1_CLIENTE"):SetBorder("",,,.T.)

TRCell():New(oTREPORT02,'__NEW__006','','',,,,,,,,,,,,)
oTREPORT02:Cell("__NEW__006"):SetName("E1_LOJA")
oTREPORT02:Cell("E1_LOJA"):cAlias := "SE1"
oTREPORT02:Cell("E1_LOJA"):SetTitle("Loja")
oTREPORT02:Cell("E1_LOJA"):SetSize(1)
oTREPORT02:Cell("E1_LOJA"):SetPicture("@!")
oTREPORT02:Cell("E1_LOJA"):SetAutoSize(.F.)
oTREPORT02:Cell("E1_LOJA"):SetLineBreak(.F.)
oTREPORT02:Cell("E1_LOJA"):SetHeaderSize(.F.)
oTREPORT02:Cell("E1_LOJA"):nAlign := 1
oTREPORT02:Cell("E1_LOJA"):nHeaderAlign := 1
oTREPORT02:Cell("E1_LOJA"):SetClrBack(16777215)
oTREPORT02:Cell("E1_LOJA"):SetClrFore(0)
oTREPORT02:Cell("E1_LOJA"):cOrder := "A5"
oTREPORT02:Cell("E1_LOJA"):nType := 1
oTREPORT02:Cell("E1_LOJA"):cFormula := ""
oTREPORT02:Cell("E1_LOJA"):cRealFormula := ""
oTREPORT02:Cell("E1_LOJA"):cUserFunction := ""
oTREPORT02:Cell("E1_LOJA"):lVisible := .T.
oTREPORT02:Cell("E1_LOJA"):SetBorder("")
oTREPORT02:Cell("E1_LOJA"):SetBorder("",,,.T.)

TRPosition():New(oTREPORT02,'SA1',1,{ || xFilial()+SE1->(E1_CLIENTE+E1_LOJA) } )

oBreak := TRBreak():New(oTREPORT02,{ ||oTREPORT02:Cell('E1_CLIENTE'):uPrint+oTREPORT02:Cell('E1_LOJA'):uPrint },'Sub-Total',.F.)
TRFunction():New(oTREPORT02:Cell('E1_CLIENTE'),, 'COUNT',oBreak ,,,,.F.,.F.,.F., oTREPORT02)
oTREPORT02:LoadOrder()
oReport:PrintDialog()
return