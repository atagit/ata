/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório do ORGANOGRAMA                              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

User Function RELSZD()

	private nTotal 	:= 0
	private aOrd    := {"Código + Nivel"}
	private aReturn := {"Especial", 1,"Administracao", 2, 2, 1, "", 2}
	private cPerg   := "SZF001"
   	private Cabec1  := "                                                         COMPOSICAO DO CARGO    SALARIO   CAD.FUNCIONARIO"
   	private Cabec2  := "C.C  CODIGO/CARGO                                        PREVISTO TURNO TOTAL     MEDIO    EFETIVO  VAGAS"
	private cDesc1  := "ORGANOGRAMA - PREVISAO DE VAGAS" 
	private cString := "SZD"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := "RELSZD"
	private lAborta := .T.                                                            
   	private cxCabec1:= "                                                                    COMPOSICAO  DO  CARGO       SALARIO    CAD.FUNCIONARIOS"
   	private cxCabec2:= "C.C   CODIGO/CARGO                                                 PREVISTO   TURNO   TOTAL       MEDIO    EFETIVO    VAGAS"
	private cNomeEmp:= ""
	private cTipEmp := ""
	private nReduz  := 5
	private nComp	:= 123
	private nLen	:= 0
	private nVagEmp := 0
	  
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	if nLastKey == 27 ; return ; endif
	
/*  ______________________________________________________________________
   Pergunta: SZF001
   			mv_par01 - C.C de
   			mv_par02 - C.C até
   			mv_par03 - Impressora?: 1-Epson
   								    2-Laser
   			mv_par04 - Tipo ?	  : 1-Analitico
   									2-Sintetico	
*/  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    If Empty(mv_par01) .or. Empty(mv_par02) .or. Empty(mv_par03)    
        return
    endif

    nImp := mv_par03 
 
	cEmp := iif(Left(mv_par01,2)='09','01','02')
    cxEmp:= cEmp

	If nImp == 1
	   Processa({|| ImprM()},"","Aguarde. Imprimindo...",lAborta)
	Else
		Processa({|| ImprL()},"","Aguarde impressão...",lAborta)
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

dbselectarea("SZD")
dbSetOrder(2)

SET FILTER TO (ZD_CUSTO >= mv_par01 .and. ZD_CUSTO <= mv_par02)

dbGoTop()
	
ProcRegua(SZD->(RecCount()))
nVagEmp := 0  	

while !SZD->(Eof())
		
	cGrupocc := SZD->ZD_GRUPOCC

	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo) 
	cDgrupo := rtrim(SZD->ZD_DESCCC) 

	while ( !SZD->(Eof()) ) .and. ( SZD->ZD_GRUPOCC == cGrupocc )  
	
		cCod 	:= SZD->ZD_CUSTO
		cDescCC := rtrim(SZD->ZD_DESCCC)
    	
    	@Prow()+1,000 psay Left(SZD->ZD_CUSTO,5)+"-"+cDescCC
		
		while cCod == SZD->ZD_CUSTO
		
			@Prow()+1,005 	   psay SZD->ZD_FUNCAO+'-'+Left(SZD->ZD_DESCFUN,45)
			@Prow()  ,Pcol()+1 psay SZD->ZD_PREV   picture "@E 99999999"
			@Prow()  ,Pcol()+1 psay SZD->ZD_TURNO  picture "@E 99999"
			@Prow()  ,Pcol()+1 psay SZD->ZD_TOTAL  picture "@E 99999"
			@Prow()  ,Pcol()+3 psay SZD->ZD_SALMED picture "@E 9999.99"
			@Prow()  ,Pcol()+4 psay "0000000"      // EFETIVO (sumarizar SRA)
			@Prow()  ,Pcol()+2 psay "00000"        // ZD_TOTAL - EFETIVO 
			
			nTotal  += SZD->ZD_TOTAL
			nVagEmp += SZD->ZD_TOTAL
					
			if ( !SZD->(Eof()) ) .and. ( SZD->ZD_GRUPOCC == cGrupocc )  .and.( Prow() >= 55 )

				Roda(0,"",Tamanho)
				Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)

		    	cDescCC := cDescCC + ' (continuação)'
		    	@Prow()+1,000 psay Left(cCod,5)+"-"+cDescCC

			endif
	   		
			IncProc()

			SZD->(DbSkip())
		Enddo
		
		@Prow()+1,000 psay Replicate("_",105)
	Enddo

   	@Prow()+2,005  psay "TOTAL VAGAS PARA ("+cDgrupo+"): "    //35-23
   	@Prow()  ,072  psay Transf(nTotal,"@E 9,999")
   	@Prow()  ,091  psay "0000000"            				// soma da coluna EFETIVO
   	@Prow()  ,0100 psay "00000"              				// soma_EFETIVO - Toal de Vagas
   	@Prow()+1 ,000 psay Replicate("-",105)
	
	cEmp := iif(Left(SZD->ZD_CUSTO,2)='09','01','02')
	
	iF !cEmp == cxEmp
   	
   		@Prow()+2,005  psay "TOTAL VAGAS PARA ("+ iif(cxEmp='01','ATA','ATF') +"): "    //35-23
   		@Prow()  ,072  psay Transf(nVagEmp,"@E 9,999")
   		@Prow()  ,091  psay "0000000"            				// soma da coluna EFETIVO
   		@Prow()  ,0100 psay "00000"              				// soma_EFETIVO - Toal de Vagas
   		@Prow()+1 ,000 psay Replicate("-",105)
	    cxEmp 	:= cEmp
		nVagEmp := 0
		  	        
    EndIf
    
	Roda(0,"",Tamanho)

	nTotal := 0
	
Enddo

SET FILTER TO
	
return   



static function ImprM()
dbselectarea("SZD")
dbSetOrder(2)

SET FILTER TO (ZD_CUSTO >= mv_par01 .and. ZD_CUSTO <= mv_par02)

dbGoTop()
	
ProcRegua(SZD->(RecCount()))
nVagEmp := 0  	

while !SZD->(Eof())
		
	cGrupocc := SZD->ZD_GRUPOCC

	cEmp 	:= iif(Left(SZD->ZD_CUSTO,2)='09','01','02')
	cDgrupo := rtrim(SZD->ZD_DESCCC) 

    U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
    m_Pag := m_Pag + 1

	While ( !SZD->(Eof()) ) .and. ( SZD->ZD_GRUPOCC == cGrupocc )  
	
		cCod := SZD->ZD_CUSTO
		cDescCC := rtrim(SZD->ZD_DESCCC)
    	
    	@Prow()+1,000 psay U_Reduz(5) + Left(SZD->ZD_CUSTO,5) + "-" + cDescCC + U_Reduz(0)
		
		While cCod == SZD->ZD_CUSTO

			cPrev := '     '
			cPrev := cPrev + SZD->ZD_FUNCAO + '  ' + SZD->ZD_DESCFUN   
			cPrev := cPrev + '     ' + str(SZD->ZD_PREV,8,0)      
 			cPrev := cPrev + '   ' 	 + str(SZD->ZD_TURNO,5,0)
 			cPrev := cPrev + '   '   + str(SZD->ZD_TOTAL,5,0)
 			cPrev := cPrev + '     ' + str(SZD->ZD_SALMED,7,2)
 			cPrev := cPrev + '    '  + "0000000"
 			cPrev := cPrev + '    '  + "00000"
 			
			@Prow()+1,000 psay U_Reduz(5) + cPrev + U_Reduz(0)

			nTotal  += SZD->ZD_TOTAL
			nVagEmp += SZD->ZD_TOTAL

			IncProc()

			SZD->(DbSkip())

			if ( !SZD->(Eof()) ) .and. ( SZD->ZD_GRUPOCC == cGrupocc ) .and. ( Prow() >= 57 )

				cEmp := iif(Left(SZD->ZD_CUSTO,2)='09','01','02')
    	        U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
		    	
		    	cDescCC := cDescCC + ' (continuacao)'
		    	@Prow()+1,000 psay U_Reduz(5) + Left(cCod,5) + "-" + cDescCC + U_Reduz(0)
		        m_Pag := m_Pag + 1

			endif

		Enddo
		// quebra de C.C
		
		@Prow()+1,000 psay  U_Reduz(5) + Replicate("_",nComp) + U_Reduz(0)
		
		
	Enddo
    // quebra do GRUPOCC
    // 86

   	cPrev := space(5) + "TOTAL VAGAS PARA ("+cDgrupo+"): "
   	nLen  := len(cPrev)
   	cPrev := cPrev + space(86-nLen) + str(nTotal,5,0)
   	                              
   	@Prow()+1,000 psay U_Reduz(5) + cPrev + U_Reduz(0)                   
   	@Prow()+1,000 psay U_Reduz(5) + Replicate("-",nComp) + U_Reduz(0)

	cEmp := iif(Left(SZD->ZD_CUSTO,2)='09','01','02')
	 
	iF !cEmp == cxEmp
   	
	   	cPrev := space(5) + "TOTAL VAGAS PARA ("+ iif(cxEmp='01','ATA','ATF') +"): "
   		nLen  := len(cPrev)
   		cPrev := cPrev + space(86-nLen) + str(nVagEmp,5,0)
   	                              
   		@Prow()+1,000 psay U_Reduz(5) + cPrev + U_Reduz(0)                   
   		@Prow()+1,000 psay U_Reduz(5) + Replicate("-",nComp) + U_Reduz(0)
   	                 
   		cxEmp   := cEmp
		nVagEmp := 0
		  
	EndIf
	
	nTotal := 0
	
Enddo

SET FILTER TO
	
return   
