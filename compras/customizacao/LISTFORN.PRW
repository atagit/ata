/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/08/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para visualizar IQF dos fornecedores             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "topconn.ch"

user function LISTFORN()
	local oButton1, oButton2
	local oGet1, oGet2
	local oGroup1, oGroup2
	
	private oDlg
	private oListBox1
	private cGet1 := Space(3)
	private cGet2 := Space(50)
	private aArqList := {}
	private oOk := LoadBitmap(GetResources(),"LBOK")
	private oNo := LoadBitmap(GetResources(),"LBNO")
	
	define msdialog oDlg title "Principais Fornecedores" from 000,000 to 360,500 colors 0,16777215 pixel
		@003,003 group oGroup1 to 028,245 prompt " Grupo de Materiais " of oDlg color 0,16777215 pixel
		@013,007 msget oGet1 var cGet1 size 026,010 of oDlg colors 0,16777215 on change FSetArray() F3 "GMA" pixel
		@013,052 msget oGet2 var cGet2 size 189,010 of oDlg colors 0,16777215 readonly pixel
		@032,003 group oGroup2 to 159,245 prompt " Fornecedores " of oDlg color 0,16777215 pixel
		
		FGetList()
		
		@163,207 button oButton1 prompt "OK" size 037,012 of oDlg action Selecionar() pixel
		@163,167 button oButton2 prompt "Cancelar" size 037,012 of oDlg action oDlg:End() pixel
	activate msdialog oDlg centered
return .T.

static function FSetArray()
	ASize(aArqList,0)
	
	aArqList := {}
	aDados := {}
	
	if Select("TTT") != 0
		TTT->(DbCloseArea())
		
		if File("TTT"+GetDBExtension())
			FErase("TTT"+GetDBExtension())
		endif
	endif
	
	cQry := "select ZO_CPFCNPJ, ZO_DFORNEC, ZO_DGRPMAT, A2_ULTCOM, A2_COD, A2_LOJA "
	cQry += "from "+RetSqlName("SZO")+" SZO inner join "+RetSqlName("SA2")+" SA2 on (ZO_CPFCNPJ = A2_CGC) "
	cQry += "where ZO_GRPMAT = '"+AllTrim(cGet1)+"' and SZO.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "order by A2_ULTCOM desc "
	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TTT",.F.,.T.)
	
	cGet2 := TTT->ZO_DGRPMAT
	
	if TTT->(Eof())
		Aviso("Microsiga Protheus","Nao existe registro(s) para esse grupo de material",{"Ok"})
		AAdd(aArqList,{"","",0})
		
		oListBox1:Refresh()
	else
		TTT->(DbGoTop())
		
		while !TTT->(Eof())
			cQry := "select ZV_VALIQF, ZV_FINAVAL, ZV_STATUS "
			cQry += "from "+RetSqlName("SA2")+" SA2 inner join "+RetSqlName("SZV")+" SZV on (A2_COD = ZV_FORNECE and A2_LOJA = ZV_LOJA) "
			cQry += "where A2_CGC = '"+TTT->ZO_CPFCNPJ+"' and SA2.D_E_L_E_T_ <> '*' and SZV.D_E_L_E_T_ <> '*' "
			cQry += "order by ZV_STATUS, ZV_FINAVAL desc"
			
			tcquery cQry new alias "TIQF"
			
			DbSelectArea("TIQF")
			TIQF->(DbGoTop())
			
			AAdd(aDados,{TTT->ZO_CPFCNPJ,TTT->ZO_DFORNEC+Space(80 - Len(TTT->ZO_DFORNEC)),IIf(!Empty(TIQF->ZV_VALIQF),TIQF->ZV_VALIQF,0),TTT->A2_COD,TTT->A2_LOJA})
			
			TIQF->(DbCloseArea())
			TTT->(DbSkip())
		enddo
		
		ASort(aDados,,,{|x,y| x[3] > y[3]})
		
		for i := 1 to Len(aDados)
			AAdd(aArqList,{aDados[i][1],aDados[i][2],aDados[i][3],aDados[i][4],aDados[i][5]})
		next
		
		ADel(aArqList,1)
		ASize(aArqList,Len(aArqList) - 1)
		
		oListBox1:SetArray(aArqList)
		oListBox1:bLine := {|| {Transf(aArqList[oListBox1:nAt][1],IIf(Len(aArqList[oListBox1:nAt][1]) = 14,"@R 99.999.999/9999-99","@R 999.999.999-99")),aArqList[oListBox1:nAt][2],aArqList[oListBox1:nAt][3],aArqList[oListBox1:nAt][4],aArqList[oListBox1:nAt][5]}}
		oListBox1:bLDblClick := {|| Selecionados()}
		oListBox1:Refresh()
	endif
return .T.

static function FGetList()
	AAdd(aArqList,{"","",0,"",""})
	
	@042,007 listbox oListBox1 fields, header "CNPJ/CPF","N.FANTASIA","IQF","CODIGO","LOJA" size 235,112 of oDlg pixel colsizes 050,030 /*Largura*//*Altura*/
		oListBox1:SetArray(aArqList)
		oListBox1:bLine := {|| {aArqList[oListBox1:nAt][1],aArqList[oListBox1:nAt][2],aArqList[oListBox1:nAt][3],aArqList[oListBox1:nAt][4],aArqList[oListBox1:nAt][5]}}
		oListBox1:bLDblClick := {|| Selecionados()}
		oListBox1:Refresh()
return

static function Selecionados()
	if !Empty(aArqList)
		CA120FORN := aArqList[oListBox1:nAt][4]
		CA120LOJ := aArqList[oListBox1:nAt][5]
	endif
	
	oDlg:End()
return