/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 24/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Adiciona botão na tela de inclusão de clientes        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function M103BROW()
//	AAdd(aRotina,{"Acertar C.C.","U_AcertaCC()",0,3})
	AAdd(aRotina,{"Avalia Fornec","U_TELAFORN()",0,3})
return

user function TELAFORN()
	private oDlg, oButton, oCancelar, aItems, oRadio
	private cPrazo, cIdent, cEspec, cQuant, cCertif, nRadio
	private cNF := SF1->F1_DOC
	private cPref := SF1->F1_SERIE
	private cForn := SF1->F1_FORNECE
	private cLoja := SF1->F1_LOJA
	private cTipo := If(Empty(SF1->F1_TIPO),"N",SF1->F1_TIPO)
	
	if !Empty(SF1->F1_AVIQF)
		aItems := {"Sem avaliacao","Aprovado","Reprovado","Aceito com restricao"}
		nRadio := 0
		
		define msdialog oDlg from 000,000 to 190,430 pixel title "Avaliação do Fornecedor"
			oGroup := TGroup():New(005,007,020,209,"Nota Fiscal / Fornecedor",oDlg,,,.T.)
			@012,010 say cNF+"-"+cPref+" / "+cForn+"-"+cLoja+" - "+If(SA2->(DbSeek(xFilial("SA2")+cForn+cLoja,.F.)),SA2->A2_NREDUZ,"")
			
			oRadio := TRadMenu():New(027,007,aItems,,oDlg,,,,,,,,100,12,,,,.T.)
			oRadio:bSetGet := {|u| IIf(PCount() == 0,nRadio,nRadio := u)}
			
			oRadio:SetOption(1)
			
			oButton := TButton():New(080,145,"Salvar",oDlg,{|| Gravar(cForn,cLoja,(nRadio - 1))},030,010,,,,.T.)
			oButton := TButton():New(080,180,"Cancelar",oDlg,{|| Close(oDlg)},030,010,,,,.T.)
		activate msdialog oDlg center
	else
		MsgAlert("O fornecedor dessa nota fiscal ja foi avaliado.")
	endif
return

static function Gravar(cForn,cLoja,nAval)
	RecLock("SF1",.F.)
		SF1->F1_AVIQF := Str(nAval,1)
	MsUnLock()
	
	U_AVFORNE(cForn,cLoja,nAval)
	
	Close(oDlg)
return