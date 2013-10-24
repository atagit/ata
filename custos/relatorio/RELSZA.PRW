/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório Direcionador de Custos                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"


User Function RELSZA()

	private nTotal 	:= 0
	private cTab   	:= " "
	private aOrd    := {"Grupo.CC + C.Custo"}
	private aReturn := {"Especial", 1,"Administracao",1, 2, 1, "", 1}
	private Cabec1  := "                                     VOLUME      VOLUME             "
	private Cabec2  := "          C.C    D.C   UNIDADE       ORCADO     REALIZADO    MES/ANO"
	private cDesc1  := "DIRECIONADOR DE CUSTOS"
	private ContFun := 0
	private cString := "SZA"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "relSZA"
	private lAborta := .T.
	private cCbcRef	:= ""
	private cCbcNum	:= ""	
	private cPerg   := "SZF001"
	private cxCabec1:= Cabec1
	private cxCabec2:= Cabec2
	private cNomeEmp:= ""
	private cTipEmp := ""
	private nReduz  := 0
	private nComp	:= 80
                 
    pergunte(cPerg,.F.)
	
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

	If nImp == 1
	   Processa({|| ImprM()},"","Aguarde. Imprimindo...",lAborta)
	Else
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


Static Function ImprL()

dbselectarea("SZA")
dbSetOrder(2)

SET FILTER TO (ZA_CUSTO >= mv_par01 .and. ZA_CUSTO <= mv_par02)

dbGoTop()
	
	ProcRegua(SZA->(RecCount()))
    
	While !SZA->(Eof())

	  Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	  cGrupoCC := SZA->ZA_GRUPOCC
 	  
 	  @Prow()+1 ,000 psay Left(SZA->ZA_CUSTO,5) +'-' + SZA->ZA_DESCCC
	  @Prow()+1 ,000 psay Replicate("-",80)
	
	  while ( !SZA->(Eof()) ) .and. ( SZA->ZA_GRUPOCC == cGrupoCC ) 
  		
		@Prow()+1,010     psay Left(SZA->ZA_CUSTO,4)
		@Prow()  ,Pcol()+3 psay SZA->ZA_DC
		@Prow()  ,Pcol()+4 psay SZA->ZA_UNID
		@Prow()  ,Pcol()+3 psay SZA->ZA_VOLORCA	picture "@E  999,999.99"
		@Prow()  ,Pcol()+3 psay SZA->ZA_VOLREAL	picture "@E  999,999.99"
		@Prow()  ,Pcol()+5 psay Right(SZA->ZA_ANOMES,2)+'/'+Left(SZA->ZA_ANOMES,4)  
				
		IncProc()
		
		SZA->(DbSkip())

		If ( !SZA->(Eof()) ) .and. ( (Prow() >= 57) .and. ( SZA->ZA_GRUPOCC == cGrupoCC ) )
			Roda(0,"",Tamanho)
			Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	 	    
	 	    @Prow()+1 ,000 psay Left(SZA->ZA_CUSTO,5) +'-' + SZA->ZA_DESCCC
		    @Prow()+1 ,000 psay Replicate("-",80)
		endif                      

		@Prow()+1 ,010 psay Replicate("-",58)

	  Enddo
	  
	  If ( !SZA->(Eof()) )
	  	Roda(0,"",Tamanho)
      EndIf
      
	Enddo                                   
	
set filter to	
	   
return


Static Function ImprM()

dbselectarea("SZA")
dbSetOrder(2)

SET FILTER TO (ZA_CUSTO >= mv_par01 .and. ZA_CUSTO <= mv_par02)

dbGoTop()
	
	ProcRegua(SZA->(RecCount()))
    
	While !SZA->(Eof())
                                            
	  cEmp := iif(Left(SZA->ZA_CUSTO,2)='09','01','02')

	  U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	  m_Pag := m_Pag + 1
	  
	  cGrupoCC := SZA->ZA_GRUPOCC
 	  
 	  @Prow()+1 ,000 psay Left(SZA->ZA_CUSTO,5) +'-' + SZA->ZA_DESCCC
	  @Prow()+1 ,000 psay Replicate("-",80)
	
	  while ( !SZA->(Eof()) ) .and. ( SZA->ZA_GRUPOCC == cGrupoCC ) 
  		
		@Prow()+1,010      psay Left(SZA->ZA_CUSTO,4)
		@Prow()  ,Pcol()+3 psay SZA->ZA_DC
		@Prow()  ,Pcol()+4 psay SZA->ZA_UNID
		@Prow()  ,Pcol()+3 psay SZA->ZA_VOLORCA	picture "@E  999,999.99"
		@Prow()  ,Pcol()+3 psay SZA->ZA_VOLREAL	picture "@E  999,999.99"
		@Prow()  ,Pcol()+5 psay Right(SZA->ZA_ANOMES,2)+'/'+Left(SZA->ZA_ANOMES,4)  
				
		IncProc()
		
		SZA->(DbSkip())

		If ( !SZA->(Eof()) ) .and. ( (Prow() >= 59) .and. ( SZA->ZA_GRUPOCC == cGrupoCC ) )
			
			cEmp := iif(Left(SZA->ZA_CUSTO,2)='09','01','02')
            U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	 	    m_Pag := m_Pag + 1
	 	    @Prow()+1 ,000 psay Left(SZA->ZA_CUSTO,5) +'-' + SZA->ZA_DESCCC
		    @Prow()+1 ,000 psay Replicate("-",80)

		endif                      

		@Prow()+1 ,010 psay Replicate("-",58)

	  Enddo
      
	Enddo

set filter to
	   
return

