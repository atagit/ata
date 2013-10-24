/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 22/09/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar projeto do Programa ATF                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PROJETO()
	local nLinini := 10
	local cProjetoDe := Space(6)
	local cProjetoAte := Space(6)
	
	private oDlg
	private lAborta := .T.
	
	@010,010 to 125,200 dialog oDlg title OemToAnsi("IMPORTAR PROJETO")
		@nLinini,010 say OemToAnsi("Projeto de")
		@nLinini-2,040 get cProjetoDe picture "@E 999999" size 30,07
		nLinini += 13
		@nLinini,010 say OemToAnsi("Projeto ate")
		@nLinini-2,040 get cProjetoAte picture "@E 999999" size 30,07
		
		nLinini += 17
		@nLinini,031 bmpbutton type 01 action Processa({|| GravarCTH(cProjetoDe,cProjetoAte)},"","Aguarde processando...",lAborta)
		@nLinini,061 bmpbutton type 02 action Close(oDlg)
	activate dialog oDlg center
return

static function GravarCTH(cProjetoDe,cProjetoAte)
	local cProjetos := ""
	
	cQry := "select numero, descricao1, coleta, proj_cli, dt_entra1, dt_entre1, pesopro, vlunitaf, pesoaf, valor_uni, tipopro1, cliente "
	cQry += "from [DADOSATF].dbo.ATFPRO "
	cQry += "where (numero between '"+cProjetoDe+"' and '"+cProjetoAte+"') "
	cQry += "order by numero"
	
	tcquery cQry New Alias ATF
	DbSelectArea("ATF")
	ATF->(DbGoTop())
	
	DbSelectArea("CTH")
	DbSetOrder(1)
	
	DbSelectArea("SA1")
	DbSetOrder(9)
	
	ProcRegua(ATF->(RecCount()))
	
	while !ATF->(Eof())
		IncProc()
		
		if !(CTH->(DbSeek(xFilial("CTH")+ATF->numero,.F.)))
			RecLock("CTH",.T.)
				CTH->CTH_FILIAL := xFilial("CTH")
				CTH->CTH_CLVL	:= ATF->numero
				CTH->CTH_CLVLLP := ATF->numero
				CTH->CTH_DESC01 := ATF->descricao1
				CTH->CTH_COLETA := ATF->coleta
				CTH->CTH_AF		:= ATF->proj_cli
				CTH->CTH_DTEXIS := SToD(ATF->dt_entra1)
				CTH->CTH_DTENTR := SToD(ATF->dt_entre1)
				CTH->CTH_PESPRJ := ATF->pesopro
				CTH->CTH_VLPROJ := ATF->vlunitaf
				CTH->CTH_PESAF	:= ATF->pesoaf
				CTH->CTH_VLAF	:= ATF->valor_uni
				CTH->CTH_TPPRJ	:= ATF->tipopro1
				CTH->CTH_CLASSE	:= "2"		//Analitico
				
				if SA1->(DbSeek(xFilial("SA1")+ATF->cliente,.F.))
					CTH->CTH_CLIENT := SA1->A1_COD
					CTH->CTH_LOJACL := SA1->A1_LOJA
					CTH->CTH_BLOQ 	:= "2"
				else
					CTH->CTH_BLOQ 	:= "1"
				endif
			MsUnLock()
		else
			if Empty(CTH->CTH_AF)
				RecLock("CTH",.F.)
					CTH->CTH_DESC01 := ATF->descricao1
					CTH->CTH_AF 	:= ATF->proj_cli
					CTH->CTH_PESAF	:= ATF->pesoaf
					CTH->CTH_VLAF 	:= ATF->valor_uni
					CTH->CTH_TPPRJ	:= ATF->tipopro1
					CTH->CTH_DTENTR := SToD(ATF->dt_entre1)
				MsUnLock()
			else
				cProjetos += ATF->numero+", "
			endif
		endif
		
		ATF->(DbSkip())
	enddo
	
	if !Empty(cProjetos)
		MsgBox("O(s) projeto(s): "+cProjetos+"ja esta(ao) importado(s).","Aviso","INFO")
	endif
	
	MsgBox("Projeto(s) importado(s) com sucesso!","Aviso","INFO")
	
	ATF->(DbCloseArea())
	Close(oDlg)
return