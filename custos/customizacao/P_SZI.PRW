/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 27/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Inclui Orçamento no Quadro de Custo - SZI             ¦
   ¦            Origem: Livro de Orçamento - SZF                      ¦
   ¦            Inlcui, também, em SZG-Despesas Realizadas            ¦ 
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "Protheus.ch"

User Function P_SZI()
           
    private cAnomes := ""
    private cCCde	:= ""
    private cCCate	:= ""
    private cCusto 	:= ""
    private cDC		:= ""
    private cCodesp	:= ""
    private lAborta := .F.
	private cPerg	:= 'SZI001'	
	
/*______________________________________________________________________
   Pergunta:SZI001
   			mv_par01 - Ano/mes:
   			mv_par02 - C.C de
   			mv_par03 - C.C ate
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
	
	If !Pergunte(cPerg)
	   Return
	EndIf
    
    If Empty(mv_par01) .or. Empty(mv_par02) .or. Empty(mv_par03)     
        return
    endif

    cAnomes := mv_par01 
	cCCde	:= mv_par02
	cCCate	:= mv_par03

	Processa({|| IncQuadro()},"","Aguarde. Processando ...",lAborta)

           
return


static function IncQuadro()

	dbselectarea("SZF")             		 
	dbSetOrder(1)
	
	dbSeek(xfilial("SZF")+cCCde)

	ProcRegua(SZF->(RecCount()))
	
	While !SZF->(Eof()) .and. SZF->ZF_CUSTO >= cCCde .and.  SZF->ZF_CUSTO <= cCCate 

	  	cCusto 	:= SZF->ZF_CUSTO
 	  	cDC	 	:= SZF->ZF_DC
 	  	cCodesp	:= SZF->ZF_CODESP
 	 
		dbselectarea("SZB")
		dbSetOrder(1)                                         
		dbSeek(xfilial("SZB")+cCodesp)

		// ----------------------
		// SZI - Quadro de Custos
		// ----------------------

		dbselectarea("SZI")
		dbSetOrder(1)

		If !dbSeek(xfilial("SZI")+cAnomes+cCusto+cDC+cCodesp)
				
			RecLock("SZI",.T.)
		    SZI->ZI_FILIAL	:= xFilial("SZI") 
		    
		    SZI->ZI_AM		:= cAnomes
	    	SZI->ZI_CUSTO 	:= cCusto
		    SZI->ZI_DC    	:= cDC
	    	SZI->ZI_CODESP	:= cCodesp
	    	SZI->ZI_DESCCD	:= Left(SZB->ZB_DESC,30)
			
			SZI->ZI_VOLORC 	:= SZF->ZF_VOLORC
			SZI->ZI_VOLREAL := 0.00
			SZI->ZI_ORCADO  := SZF->ZF_CUSTOM
			SZI->ZI_REALIZA	:= 0.00
					
			SZI->ZI_VARMES	:= 0.00
			SZI->ZI_PCVMES	:= 0.00
			SZI->ZI_VARACUM	:= 0.00
			SZI->ZI_PCVACUM	:= 0.00

			SZI->ZI_CUSTOP	:= 0.00
			SZI->ZI_PCUSTOP	:= 0.00
			
			SZI->ZI_GRUPOCC := SZF->ZF_GRUPOCC
			SZI->ZI_GRUPOCD := SZF->ZF_GRUPOCD
			SZI->ZI_TITULO  := SZF->ZF_TITULO
			MsUnlock()
		EndIf
        
		// -------------------------
		// SZG - DESPESAS REALIZADAS
		// -------------------------
		
		dbselectarea("SZG")
		dbSetOrder(1)

		If !dbSeek(xfilial("SZG")+cAnomes+cCusto+cDC+cCodesp)
				
			RecLock("SZG",.T.)
		    SZI->ZG_FILIAL	:= xFilial("SZG") 
		    SZG->ZG_AM		:= cAnomes
	    	SZG->ZG_CUSTO 	:= cCusto
	    	SZG->ZG_CODESP	:= cCodesp
			SZG->ZG_PRECO  	:= 0.00
			SZG->ZG_VALOR   := 0.00
			SZG->ZG_ORIGEM  := ''
			MsUnlock()
			
		EndIf


		dbSelectArea("SZF")
		SZF->(DbSkip())
		
		IncProc()
	  	
	Enddo
	   
Return          


