/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de fornecedores                               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELFOR()
	private aOrd    := {"Codigo","Descricao"}
	private aReturn := {"Especial", 1,"Administracao", 1, 2, 1, "", 1}
	private cPerg   := "RELFOR"
	private Cabec1  := "CODIGO LJ RAZAO SOCIAL                              DDD TELEFONE CONTATO"
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE FORNECEDORES"
	private ContFun := 0
	private cString := "SA2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "RELFOR"
	private lAborta := .T.
	
	private cQry    := ""
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cQry := "select * "
	cQry += "from "+RetSqlName("SA2")+" "
	cQry += "where (A2_COD between '"+mv_par01+"' and '"+mv_par02+"') and D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by A2_COD"
	elseif nOrdem == 2
		cQry += "order by A2_NOME"
	endif
	
	if nLastKey == 27 ; return ; endif
	
	tcquery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
	
	Roda(0,"",Tamanho)
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return

static function Impr()
	local nTotal := 0
	
	ProcRegua(TEMP->(RecCount()))
	
	while !TEMP->(Eof())
		cCod := TEMP->A2_COD
		
		while cCod == TEMP->A2_COD
			@Prow()+1,000 psay TEMP->A2_COD
			@Prow()  ,007 psay TEMP->A2_LOJA
			@Prow()  ,010 psay TEMP->A2_NOME
			@Prow()  ,052 psay TEMP->A2_DDD
			@Prow()  ,056 psay Left(TEMP->A2_TEL,8)
			@Prow()  ,065 psay Left(TEMP->A2_CONTATO,14)
			
			if Prow() >= 57
				Roda(0,"",Tamanho)
				Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
			endif
			
			nTotal++
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		@Prow()+1,000 psay Replicate("-",80)
	enddo
	
	@Prow()+2,000 psay "TOTAL DE FORNECEDOR: "+Transf(nTotal,"@E 999,999,999")
return