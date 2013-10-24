/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/06/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Amarracao fornecedor ao grupo de material (produto)   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"
#include "colors.ch"

user function GRPMAT()
	private nCod := 0
	private cCadastro := "Fornecedor X Grp Material"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","U_GMOBJ",0,2},;
						{"Incluir","U_GMOBJ",0,3},;
						{"Alterar","U_GMOBJ",0,4},;
						{"Excluir","U_GMOBJ",0,5}}
	
	DbSelectArea("SZO")
	DbSetOrder(1)
	MBrowse(006,008,022,071,"SZO")
return

user function GMOBJ(cAlias,nRecno,nTipo)
	local oDlg
	local oFont10 := TFont():New('Arial',8,16,,.F.,,,,.T.,.F.)
	local oFont10n := TFont():New('Arial',8,16,,.T.,,,,.T.,.F.)
	local _ni
	local lOk
	
	private aHeader	:= {}
	private aCols	:= {}
	
	private cFornece := Space(6)
	private cLoja := Space(2)
	private cNFantas := Space(20)
	private cCnpj := Space(14)
	
	RegToMemory("SZO",(nTipo == 3))
	
	if nTipo <> 3
		cCnpj := M->ZO_CPFCNPJ
		cNFantas := M->ZO_DFORNEC
		
		SA2->(DbsetOrder(3))
		
		if SA2->(DbSeek(xFilial("SA2")+cCnpj,.F.))
			cFornece := SA2->A2_COD
			cLoja := SA2->A2_LOJA
		endif
	endif
	
	//Cria estrutura de aHeader e aCols
	nUsado := 0
	
	DbSelectArea("SX3")
	DbSeek("SZO")
	
	aHeader := {}
	
	while !Eof() .and. SX3->X3_ARQUIVO == "SZO"
		if AllTrim(SX3->X3_CAMPO) $ "ZO_ITEM/ZO_GRPMAT/ZO_DGRPMAT"
			if X3Uso(SX3->X3_USADO) .and. (cNivel >= SX3->X3_NIVEL)
				nUsado := nUsado + 1
				
				AAdd(aHeader,{AllTrim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"AllwaysTrue()",X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
			endif
		endif
		
		DbSelectArea("SX3")
		DbSkip()
	enddo
	
	_nPosItem := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZO_ITEM"})
	_nPosGrpMat := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZO_GRPMAT"})
	_nPosDGrpMat := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZO_DGRPMAT"})
	
	if nTipo == 3
		aCols := {Array(nUsado + 1)}
		aCols[1,nUsado + 1] := .F.
		
		for _ni := 1 to nUsado
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		next
	else
		aCols := {}
		
		DbSelectArea("SZO")
		DbSetOrder(1)
		DbSeek(xFilial("SZO")+M->ZO_CPFCNPJ)
		
		while !Eof() .and. SZO->ZO_FILIAL == M->ZO_FILIAL .and. SZO->ZO_CPFCNPJ == M->ZO_CPFCNPJ 
			AAdd(aCols,Array(nUsado + 1))
			
			for _ni := 1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
			next
			
			aCols[Len(aCols),nUsado + 1] := .F.				//valida linha deletada
			
			DbSelectArea("SZO")
			DbSkip()
		enddo
	endif
	//FIM - Cria estrutura de aHeader e aCols
	
	define msdialog oDlg from 000,000 to 400,570 pixel title OemToAnsi(cCadastro)
		TGroup():New(015,005,053,280,,oDlg,,,.T.,)
		
		do case
			case nTipo == 3
				TSay():New(022,013,{|| OemToAnsi("CPF/CNPJ:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
				TGet():New(020,058,{|u| IIf(PCount() > 0,cCnpj := u,cCnpj)},oDlg,090,010,"@!",{|| ValDFornece()},,,,,,.T.,,,,,,,.F.,,"SA2B","cCnpj")
				TSay():New(022,150,{|| OemToAnsi(cFornece+"-"+cLoja)},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,090,020)
//				TSay():New(022,013,{|| OemToAnsi("Fornecedor:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
//				TGet():New(020,058,{|u| IIf(PCount() > 0,cFornece := u,cFornece)},oDlg,050,010,"@!",,,,,,,.T.,,,,,,,.F.,,"SA2","cFornece")
//				TSay():New(022,142,{|| OemToAnsi("Loja:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
//				TGet():New(020,162,{|u| IIf(PCount() > 0,cLoja := u,cLoja)},oDlg,020,010,"@!",{|| ValDFornece()},,,,,,.T.,,,,,,,.F.,,,"cLoja")
				TSay():New(037,013,{|| OemToAnsi("N. Fantasia:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
				TGet():New(035,058,{|| OemToAnsi(cNFantas)},oDlg,210,010,"@!",,,,,,,.T.,,,,,,,.T.,,,"cNFantas")
				MsGetDados():New(055,005,193,279,nTipo,"AllwaysTrue()","AllwaysTrue()",,.T.,,,,,,,,,oDlg)
			case nTipo == 4
				TSay():New(022,013,{|| OemToAnsi("CPF/CNPJ:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
				TGet():New(020,058,{|u| IIf(PCount() > 0,cCnpj := u,cCnpj)},oDlg,090,010,"@!",{|| ValDFornece()},,,,,,.T.,,,,,,,.T.,,"SA2B","cCnpj")
				TSay():New(022,150,{|| OemToAnsi(cFornece+"-"+cLoja)},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,090,020)
//				TSay():New(022,013,{|| OemToAnsi("Fornecedor:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
//				TGet():New(020,058,{|u| IIf(PCount() > 0,cFornece := u,cFornece)},oDlg,050,010,"@!",,,,,,,.T.,,,,,,,.T.,,"SA2","cFornece")
//				TSay():New(022,142,{|| OemToAnsi("Loja:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
//				TGet():New(020,162,{|u| IIf(PCount() > 0,cLoja := u,cLoja)},oDlg,020,010,"@!",{|| ValDFornece()},,,,,,.T.,,,,,,,.T.,,,"cLoja")
				TSay():New(037,013,{|| OemToAnsi("N. Fantasia:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
				TGet():New(035,058,{|| OemToAnsi(cNFantas)},oDlg,210,010,"@!",,,,,,,.T.,,,,,,,.T.,,,"cNFantas")
				MsGetDados():New(055,005,193,279,nTipo,"AllwaysTrue()","AllwaysTrue()",,.T.,,,,,,,,,oDlg)
			otherwise
				TSay():New(022,013,{|| OemToAnsi("CPF/CNPJ:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
				TGet():New(020,058,{|| OemToAnsi(cCnpj)},oDlg,090,010,"@!",,,,,,,.T.,,,,,,,.T.,,,"cCnpj")
				TSay():New(022,150,{|| OemToAnsi(cFornece+"-"+cLoja)},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,090,020)
//				TSay():New(022,013,{|| OemToAnsi("Fornecedor:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
//				TGet():New(020,058,{|| OemToAnsi(cFornece)},oDlg,050,010,"@!",,,,,,,.T.,,,,,,,.T.,,,"cFornece")
//				TSay():New(022,142,{|| OemToAnsi("Loja:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
//				TGet():New(020,162,{|| OemToAnsi(cLoja)},oDlg,020,010,"@!",,,,,,,.T.,,,,,,,.T.,,,"cLoja")
				TSay():New(037,013,{|| OemToAnsi("N. Fantasia:")},oDlg,,oFont10n,,,,.T.,CLR_BLUE,CLR_BLUE,050,020)
				TGet():New(035,058,{|| OemToAnsi(cNFantas)},oDlg,210,010,"@!",,,,,,,.T.,,,,,,,.T.,,,"cNFantas")
				MsGetDados():New(055,005,193,279,nTipo,.F.,.F.,,,,,,,,,,,oDlg)
		endcase
	activate msdialog oDlg center on init EnchoiceBar(oDlg,{|| lOk := .T.,oDlg:End()},{|| lOk := .F.,oDlg:End()},,)
	
	if lOk
		GravarGMOBJ(nTipo,oDlg)
		ConfirmSx8()
	else
		RollBackSx8()
	endif
return
                      
static function GravarGMOBJ(nTip,oDlg)
	local nInd := 0
	
	//getdados	
	if (nTip == 3 .or. nTip == 4)
		//grava dados
		for nInd := 1 to Len(aCols)
			if !aCols[nInd,nUsado + 1]
				DbSelectArea("SZO")
				DbSetOrder(1)
				
				if DbSeek(xFilial("SZO")+cCnpj+aCols[nInd,_nPosItem])
					RecLock("SZO",.F.)
					
					SZO->ZO_GRPMAT := aCols[nInd,_nPosGrpMat]
					SZO->ZO_DGRPMAT := aCols[nInd,_nPosDGrpMat]
				else
					RecLock("SZO",.T.)
					
					SZO->ZO_FILIAL := xFilial("SZO")
					SZO->ZO_CPFCNPJ := cCnpj
					SZO->ZO_DFORNEC := cNFantas
					SZO->ZO_ITEM := aCols[nInd,_nPosItem]
					SZO->ZO_GRPMAT := aCols[nInd,_nPosGrpMat]
					SZO->ZO_DGRPMAT := aCols[nInd,_nPosDGrpMat]
				endif
				
				MsUnLock()
			else
				DbSelectArea("SZO")
				Dbsetorder(1)
				
				if DbSeek(xFilial("SZO")+cCnpj+aCols[nInd,_nPosItem])
					if RecLock("SZO",.F.)
						Dbdelete()
						MsUnLock()
					endif
				endif
			endif
		next
	elseif nTip == 5
		DbSelectArea("SZO")
		DbSetOrder(1)
		DbSeek(xFilial("SZO")+cCnpj)
		
		while !Eof() .and. SZO->ZO_CPFCNPJ == cCnpj
			if RecLock("SZO",.F.)
				Dbdelete()
				MsUnLock()
			endif
			
			SZO->(DbSkip())
		enddo
	endif
	//FIM - getdados
return

static function ValDFornece()
	local lRet := .T.
	
	DbSelectArea("SA2")
	DbSetOrder(3)
	
	if SA2->(DbSeek(xFilial("SA2")+cCnpj,.F.))
		cFornece := SA2->A2_COD
		cLoja := SA2->A2_LOJA
		cNFantas := SA2->A2_NREDUZ
	else
		MsgAlert("O fornecedor nao esta cadastrado ou digitou o codigo errado.")
		
		lRet := .F.
	endif
	
	DbSelectArea("SZO")
	DbSetOrder(1)
	
	if SZO->(DbSeek(xFilial("SZO")+cCnpj,.F.))
		MsgAlert("Para esse fornecedor ja foi relacinado grupo de material.")
		
		lRet := .F.
	endif
return(lRet)