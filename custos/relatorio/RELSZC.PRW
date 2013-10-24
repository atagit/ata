/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de Encargos                                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

User Function RELSZC()

	private nTotal 	:= 0
	private cTab   	:= " "
	private aOrd    := {"Tabela+Grupo+Cod.Enc"}
	private aReturn := {"Especial", 1,"Administracao", 1, 2, 1, "", 1}
	private Cabec1  := "     COD  ENCARGO                              PERCENTUAL  COD.DESPESA"
	private Cabec2  := ""
	private cDesc1  := "TABELA DE ENCARGOS"
	private ContFun := 0
	private cString := "SZC"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "RELSZC"
	private lAborta := .T.
	private cPerg   := "SZAIMP"
	private cxCabec1:= Cabec1
	private cxCabec2:= Cabec2
	private cNomeEmp:= ""
	private cTipEmp := ""
	private nReduz  := 0
	private nComp	:= 80
                 
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]

	
	if nLastKey == 27 ; return ; endif
	

/*  ______________________________________________________________________
   Pergunta: SZAIMP
   			mv_par01 - Impressora?: 1-Epson
   								    2-Laser 	
*/  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    If Empty(mv_par01)   
        return
    endif

    nImp := mv_par01 
 
	cEmp := Left(cNumEmp,2)

	If nImp == 1
	  U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	  m_Pag := m_Pag + 1
	   Processa({|| ImprM()},"","Aguarde. Imprimindo...",lAborta)
	Else
		Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		Processa({|| ImprL()},"","Aguarde. Imprimindo...",lAborta)
	   	Roda(0,"",Tamanho)
	EndIf
	
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


static function ImprL()

dbselectarea("SZC")
dbSetOrder(1)
dbGoTop()
	
	ProcRegua(SZC->(RecCount()))
	
	while !SZC->(Eof())

		cCod := SZC->ZC_TABELA

    	Do Case
    		Case cCod = '1' 
    		cTab := 'ADM'
    		Case cCod = '2' 
    		cTab := '1TURNO'
    		Case cCod = '3' 
    		cTab := '2TURNOS'
    		Case cCod = '4' 
    		cTab := '3TURNOS'
    		Case cCod = '5' 
    		cTab := 'OUTROS'
    	EndCase
	
		@Prow()+1 ,000 psay 'TABELA: '+SZC->ZC_TABELA+"-"+cTab
		@Prow()+1 ,000 psay Replicate("_",80)

		while cCod == SZC->ZC_TABELA

    		If SZC->ZC_TITULO = 'S'
    			@Prow()+1,005 psay 'GRUPO : '+SZC->ZC_DESC
    			@Prow()+1,005 psay Replicate("-",66)
    			SZC->(DbSkip())
    			Loop
    		EndIf

    		If(SZC->ZC_TITULO = 'T') .or. (SZC->ZC_GRUPO='99')
    			@Prow()+1,005 psay Replicate("-",66)
			EndIf

			@Prow()+1,005 psay SZC->ZC_CODENC
			@Prow()  ,009 psay SZC->ZC_DESC
			@Prow()  ,046 psay SZC->ZC_PERC picture "@E 9999999.99"
			@Prow()  ,064 psay SZC->ZC_CODESP

    		If (SZC->ZC_TITULO = 'T') .or. (SZC->ZC_GRUPO='99')
				nTotal += SZC->ZC_PERC
    			@Prow()+1 ,005 psay Replicate("-",66)
    			@Prow()+2 ,000 psay Replicate("_",80)
			EndIf
		
			IncProc()
		
			SZC->(DbSkip())

			If ( !SZC->(Eof()) ) .and. ( (Prow() >= 57) .or. (!cCod = SZC->ZC_TABELA) )
				Roda(0,"",Tamanho)
				Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
			endif                      
  
		enddo
	
	enddo
	
return



Static Function ImprM()

dbselectarea("SZC")
dbSetOrder(1)
dbGoTop()
	
	ProcRegua(SZC->(RecCount()))
	
	while !SZC->(Eof())

		cCod := SZC->ZC_TABELA

    	Do Case
    		Case cCod = '1' 
    		cTab := 'ADM'
    		Case cCod = '2' 
    		cTab := '1TURNO'
    		Case cCod = '3' 
    		cTab := '2TURNOS'
    		Case cCod = '4' 
    		cTab := '3TURNOS'
    		Case cCod = '5' 
    		cTab := 'OUTROS'
    	EndCase
	
		@Prow()+1 ,000 psay 'TABELA: '+SZC->ZC_TABELA+"-"+cTab
		@Prow()+1 ,000 psay Replicate("_",80)

		while cCod == SZC->ZC_TABELA

    		If SZC->ZC_TITULO = 'S'
    			@Prow()+1,005 psay 'GRUPO : '+SZC->ZC_DESC
    			@Prow()+1,005 psay Replicate("-",66)
    			SZC->(DbSkip())
    			Loop
    		EndIf

    		If(SZC->ZC_TITULO = 'T') .or. (SZC->ZC_GRUPO='99')
    			@Prow()+1,005 psay Replicate("-",66)
			EndIf

			@Prow()+1,005 psay SZC->ZC_CODENC
			@Prow()  ,009 psay SZC->ZC_DESC
			@Prow()  ,046 psay SZC->ZC_PERC picture "@E 9999999.99"
			@Prow()  ,064 psay SZC->ZC_CODESP

    		If (SZC->ZC_TITULO = 'T') .or. (SZC->ZC_GRUPO='99')
				nTotal += SZC->ZC_PERC
    			@Prow()+1 ,005 psay Replicate("-",66)
    			@Prow()+2 ,000 psay Replicate("_",80)
			EndIf
		
			IncProc()
		
			SZC->(DbSkip())

			If ( !SZC->(Eof()) ) .and. ( (Prow() >= 57) .or. (!cCod = SZC->ZC_TABELA) )
			  	U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	  			m_Pag := m_Pag + 1
			endif                      
  
		enddo
	
	enddo
	
return
