/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 26/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar produto do ATF22                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "topconn.ch"

user function IMPPROD()
	local oButton1
	local oButton2
	local oGet1
	local cGet1 := Space(100)
	local oGroup1
	local oSay1
	local oSay2
	
	private oDlg
	
	define msdialog oDlg title "Importar Produto" from 000,000 to 165,500 colors 0,16777215 pixel
		@002,003 group oGroup1 to 045,247 of oDlg color 0,16777215 pixel
		@005,006 say oSay1 prompt "Ao final de cada código de produto informado acrescentar o sinal ';' e em caso de mais de um código, só inserir a frente, conforme exemplo abaixo:"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Um Produto: AAA001;"+Chr(13)+Chr(10)+"Mais de um Produto: AAA001;BBB002;CCC003;" size 236,036 of oDlg colors 0,16777215 pixel
		@051,004 say oSay2 prompt "Produto(s)" size 030,007 of oDlg colors 0,16777215 pixel
		@050,036 msget oGet1 var cGet1 size 112,010 of oDlg colors 0,16777215 pixel
		@065,208 button oButton1 prompt "Cancelar" size 037,012 of oDlg action oDlg:End() pixel
		@065,168 button oButton2 prompt "Importar" size 037,012 of oDlg action Importar(AllTrim(cGet1)) pixel
	activate msdialog oDlg centered
return

static function Importar(cProduto)
	local aProduto := {}
	local nTotReg := 0
	local aAtf := {}
	
	if Empty(cProduto)
		MsgAlert("Nao foi informado nenhum produto.")
		
		return
	endif
	
	cProduto := IIf(Right(cProduto,1) = ";",cProduto,cProduto+";")
	aProduto := StrTokArr(cProduto,";")
	
	for i := 1 to Len(aProduto)
		if Select("QSB1") <> 0
			QSB1->(DbCloseArea())
		endif
		
		cQrySB1 := "select B1_COD from "+RetSqlName("SB1")+" where B1_COD = '"+aProduto[i]+"' and D_E_L_E_T_ <> '*'"
		
		tcquery cQrySB1 new alias "QSB1"
		DbSelectArea("QSB1")
		count to nTotReg
		QSB1->(DbCloseArea())
		
		if Empty(nTotReg)
			if Select("QATF") <> 0
				QATF->(DbCloseArea())
			endif
			
			cQryATF := "select * from [DADOSATF].dbo.ATFPER where codigo = '"+aProduto[i]+"'"
			nTotReg := 0
			
			tcquery cQryATF new alias "QATF"
			DbSelectArea("QATF")
			count to nTotReg
			
			if Empty(nTotReg)
				MsgAlert("O produto "+aProduto[i]+" nao esta na tabela intermediaria, verificar o cadastro no ATF22.")
				
				return
			else
				aAtf := {}
				aAtf := {QATF->codigo,QATF->desc_res,QATF->unidade,QATF->material,QATF->espectec,QATF->grupo,QATF->sgrupo,QATF->gsiga}
				cQry := "delete from [DADOSATF].dbo.ATFPER where codigo = '"+aProduto[i]+"'"
				nRet := TCSqlExec(cQry)
				cQry := "insert into [DADOSATF].dbo.ATFPER(codigo,desc_res,unidade,material,espectec,grupo,sgrupo,gsiga) values('"+aAtf[1]+"','"+aAtf[2]+"','"+aAtf[3]+"','"+aAtf[4]+"','"+aAtf[5]+"','"+aAtf[6]+"','"+aAtf[7]+"','"+aAtf[8]+"')"
				nRet := TCSqlExec(cQry)
				
				QATF->(DbCloseArea())
			endif
		else
			MsgAlert("O produto "+aProduto[i]+" ja esta cadastro no Microsiga.")
			
			return
		endif
	next
	
	MsgInfo("Importacao concluida com sucesso.")
return