/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/09/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gerar pedido de venda a partir da folha de rosto      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "tbiconn.ch"

user function IMPFOLR()
	public nValPed := 0
	
	private oDlg
	private oWBrowse1, oWBrowse2
	private oGroup1, oGroup2, oGroup2
	private oButton1, oButton2
	private oGet1, oGet2, oGet3
	private oSay1, oSay2, oSay3
	private oCheckBo1, oCheckBo2, oCheckBo3, oCheckBo4
	private cGet1 := Space(6)
	private cGet2 := Space(30)
	private cGet3 := Space(100)
	private lCheckBo1 := .F.
	private lCheckBo2 := .F.
	private lCheckBo3 := .F.
	private lCheckBo4 := .F.
	private aWBrowse1 := {}
	private aWBrowse2 := {}
	private lAborta := .T.
	private oOk := LoadBitmap(GetResources(),"LBOK")
	private oNo := LoadBitmap(GetResources(),"LBNO")
	
	define msdialog oDlg title "Folha de Rosto" from 000,000 to 500,700 colors 0,16777215 pixel
		@003,004 group oGroup1 to 039,347 prompt " Folha de Rosto " of oDlg color 0,16777215 pixel
		@013,008 say oSay1 prompt "Codigo" size 021,007 of oDlg colors 0,16777215 pixel
		@011,044 msget oGet1 var cGet1 size 036,010 of oDlg colors 0,16777215 valid Carregar() F3 "SZM" pixel
		@025,008 say oSay2 prompt "Ord. Compra" size 036,007 of oDlg colors 0,16777215 pixel
		@024,044 msget oGet2 var cGet2 size 071,010 of oDlg colors 0,16777215 readonly pixel
		@025,120 say oSay3 prompt "Cliente" size 021,007 of oDlg colors 0,16777215 pixel
		@024,143 msget oGet3 var cGet3 size 201,010 of oDlg colors 0,16777215 readonly pixel
		@040,004 group oGroup2 to 180,347 prompt " Projeto " of oDlg color 0,16777215 pixel
		
		FWBrowse1()
		
		@182,003 group oGroup3 to 229,347 prompt " TES " of oDlg color 0,16777215 pixel
		
		FWBrowse2()
		
		@233,309 button oButton1 prompt "Cancelar" size 037,012 of oDlg action oDlg:End() pixel
		@233,269 button oButton2 prompt "Gerar" size 037,012 of oDlg action Processa({|| Gerar()},"","Aguarde processando...",lAborta) pixel
	activate msdialog oDlg centered
return

static function Gerar()
	local aCabec := {}
	local aItens := {}
	local aLinha := {}
	local nX := 0
	local nY := 0
	local cDoc := ""
	local lOk := .T.
	
	private lMsErroAuto := .F.
	
	if Empty(aWBrowse2)
		MsgAlert("Nenhuma TES selecionada.")
		
		return
	endif
	
	if Empty(aWBrowse1)
		MsgAlert("Tem selecionar pelo menos um PROJETO pra gerar a Pre-nota.")
		
		return
	endif
	
	ProcRegua(Len(aWBrowse1))
	
	for i := 1 to Len(aWBrowse2)
		MsgAlert("O numero da pre-nota a ser gerada e: "+cDoc)
		
		for j := 1 to Len(aWBrowse1)
			cDoc := GetSxeNum("SC5","C5_NUM")
			aCabec := {}
			aItens := {}
			
			if SZM->(DbSeek(xFilial("SZM")+cGet1,.F.))
				AAdd(aCabec,{"C5_PROJETO",SZM->ZM_PROJETO,nil})
				AAdd(aCabec,{"C5_NUM",cDoc,nil})
				AAdd(aCabec,{"C5_TIPO","N",nil})
				AAdd(aCabec,{"C5_CLIENTE",SZM->ZM_CLIENTE,nil})
				AAdd(aCabec,{"C5_LOJACLI",SZM->ZM_LOJA,nil})
				AAdd(aCabec,{"C5_LOJAENT",SZM->ZM_LOJA,nil})
				AAdd(aCabec,{"C5_CONDPAG",SZM->ZM_CONDPGT,nil})
				AAdd(aCabec,{"C5_FOLROST",SZM->ZM_CODIGO,nil})
				AAdd(aCabec,{"C5_NATUREZ",aWBrowse2[i][4],nil})
				AAdd(aCabec,{"C5_TPFRETE",SZM->ZM_TPFRETE,nil})
			endif
			
			for j := 1 to Len(aWBrowse1)
				aLinha := {}
//				nValPed += Val(aWBrowse1[j][7])
				nValPed += aWBrowse1[j][7]
				
				AAdd(aLinha,{"C6_ITEM",StrZero(j,2),nil})
				AAdd(aLinha,{"C6_PRODUTO",aWBrowse1[j][3],nil})
//				AAdd(aLinha,{"C6_QTDVEN",Val(aWBrowse1[j][4]),nil})
//				AAdd(aLinha,{"C6_PRCVEN",Val(aWBrowse1[j][6]),nil})
//				AAdd(aLinha,{"C6_PRUNIT",Val(aWBrowse1[j][6]),nil})
//				AAdd(aLinha,{"C6_VALOR",Val(aWBrowse1[j][7]),nil})
				AAdd(aLinha,{"C6_QTDVEN",aWBrowse1[j][4],nil})
				AAdd(aLinha,{"C6_PRCVEN",aWBrowse1[j][6],nil})
				AAdd(aLinha,{"C6_PRUNIT",aWBrowse1[j][6],nil})
				AAdd(aLinha,{"C6_VALOR",aWBrowse1[j][7],nil})
				AAdd(aLinha,{"C6_TES",aWBrowse2[i][2],nil})
				AAdd(aItens,aLinha)
			next j
			
			IncProc()
			MsExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
			
			if !lMsErroAuto
				MsgAlert("Incluido com sucesso! "+cDoc)
				ConfirmSx8()
			else
				MsgAlert("Erro na inclusao!")
				MostraErro()
				RollBackSx8()
			endif
			
			lMsErroAuto := .F.
		next j
	next i
return

static function FWBrowse1()
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{.F.,"","",0.00,"",0.00,0.00})
//		AAdd(aWBrowse1,{.F.,"","","","","",""})
	endif
	
	@048,007 listbox oWBrowse1 fields header "","PROJETO","PRODUTO","QUANT","UN","PRC. UNIT.","TOTAL" size 338,130 of oDlg pixel /*colsizes 50,30*/
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {IIf(aWBrowse1[oWBrowse1:nAt,1],oOk,oNo),aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],aWBrowse1[oWBrowse1:nAt,4],aWBrowse1[oWBrowse1:nAt,5],aWBrowse1[oWBrowse1:nAt,6],aWBrowse1[oWBrowse1:nAt,7]}}
		oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
return

static function FWBrowse2()
	if Len(aWBrowse2) <= 0
		AAdd(aWBrowse2,{.F.,"","",""})
	endif
	
	@189,007 listbox oWBrowse2 fields header "","TES","CFOP","NATUREZA" size 338,038 of oDlg pixel /*colsizes 50,30*/
		oWBrowse2:SetArray(aWBrowse2)
		oWBrowse2:bLine := {|| {IIf(aWBrowse2[oWBrowse2:nAt,1],oOk,oNo),aWBrowse2[oWBrowse2:nAt,2],aWBrowse2[oWBrowse2:nAt,3],aWBrowse2[oWBrowse2:nAt,4]}}
		oWBrowse2:bLDblClick := {|| aWBrowse2[oWBrowse2:nAt,1] := !aWBrowse2[oWBrowse2:nAt,1],oWBrowse2:DrawSelect()}
return

static function Carregar()
	aWBrowse2 := {}
	
	DbSelectArea("SZM")
	SZM->(DbGoTop())
	
	if SZM->(DbSeek(xFilial("SZM")+cGet1,.F.))
		cGet2 := SZM->ZM_OC
		
		if SA1->(DbSeek(xFilial("SA1")+SZM->(ZM_CLIENTE+ZM_LOJA),.F.))
			cGet3 := SZM->ZM_CLIENTE+"-"+SZM->ZM_LOJA+" "+SA1->A1_NREDUZ
		endif
		
		if !Empty(SZM->ZM_TES1)
			AAdd(aWBrowse2,{.F.,SZM->ZM_TES1,IIf(SF4->(DbSeek(xFilial("SF4")+SZM->ZM_TES1,.F.)),SF4->F4_CF,""),SZM->ZM_NATUR1})
		endif
		
		if !Empty(SZM->ZM_TES2)
			AAdd(aWBrowse2,{.F.,SZM->ZM_TES2,IIf(SF4->(DbSeek(xFilial("SF4")+SZM->ZM_TES2,.F.)),SF4->F4_CF,""),SZM->ZM_NATUR2})
		endif
		
		if !Empty(SZM->ZM_TES3)
			AAdd(aWBrowse2,{.F.,SZM->ZM_TES3,IIf(SF4->(DbSeek(xFilial("SF4")+SZM->ZM_TES3,.F.)),SF4->F4_CF,""),SZM->ZM_NATUR3})
		endif
		
		if !Empty(SZM->ZM_TES4)
			AAdd(aWBrowse2,{.F.,SZM->ZM_TES4,IIf(SF4->(DbSeek(xFilial("SF4")+SZM->ZM_TES4,.F.)),SF4->F4_CF,""),SZM->ZM_NATUR4})
		endif
		
		oWBrowse2:SetArray(aWBrowse2)
		oWBrowse2:bLine := {|| {IIf(aWBrowse2[oWBrowse2:nAt,1],oOk,oNo),aWBrowse2[oWBrowse2:nAt,2],aWBrowse2[oWBrowse2:nAt,3],aWBrowse2[oWBrowse2:nAt,4]}}
		oWBrowse2:Refresh()
		
		CarregarGrid()
	endif
	
	SZM->(DbCloseArea())
return

static function CarregarGrid()
	aWBrowse1 := {}
	
	DbSelectArea("SZN")
	SZN->(DbGoTop())
	
	if SZN->(DbSeek(xFilial("SZN")+cGet1,.F.))
		while !SZN->(Eof()) .and. SZN->ZN_CODIGO == cGet1
//			AAdd(aWBrowse1,{.F.,SZN->ZN_PROJETO,SZN->ZN_PRODUTO,Transf(SZN->ZN_QUANT,"@E 999,999,999.9999"),SZN->ZN_UM,Transf(SZN->ZN_PRCUNIT,"@E 999,999,999.99"),Transf(SZN->ZN_TOTAL,"@E 9,999,999,999,999.99")})
			AAdd(aWBrowse1,{.F.,SZN->ZN_PROJETO,SZN->ZN_PRODUTO,SZN->ZN_QUANT,SZN->ZN_UM,SZN->ZN_PRCUNIT,SZN->ZN_TOTAL})
			
			SZN->(DbSkip())
		enddo
	endif
	
	SZN->(DbCloseArea())
	
	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:bLine := {|| {IIf(aWBrowse1[oWBrowse1:nAt,1],oOk,oNo),aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3],Transf(aWBrowse1[oWBrowse1:nAt,4],"@E 999,999,999.9999"),aWBrowse1[oWBrowse1:nAt,5],Transf(aWBrowse1[oWBrowse1:nAt,6],"@E 999,999,999.99"),Transf(aWBrowse1[oWBrowse1:nAt,7],"@E 9,999,999,999,999.99")}}
	oWBrowse1:Refresh()
return