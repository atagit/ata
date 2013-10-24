/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório Direcionador de Custos                      ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"


User Function REPSZA()

	private nTotal 	:= 0
	private cTab   	:= " "
	private aOrd    := {"Grupo.CC + C.Custo"}
	private aReturn := {"Especial", 1,"Administracao",1, 2, 1, "", 1}
	private cPerg   := ""
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "DIRECIONADOR DE CUSTOS"
	private ContFun := 0
	private cString := "SZA"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "repSZA"
	private lAborta := .T.
	private cCbcRef	:= ""
	private cCbcNum	:= ""	
	private cxCabec1  := "                           VOLUME      VOLUME             "
	private cxCabec2  := "C.C    D.C   UNIDADE       ORÇADO     REALIZADO    MES/ANO"

	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]

	
	if nLastKey == 27 ; return ; endif

	
	Processa({|| Impr()},"","Aguarde. Imprimindo...",lAborta)
	
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

dbselectarea("SZA")
dbSetOrder(2)
dbGoTop()
	      
	
	ProcRegua(SZA->(RecCount()))
    
   	//	@000,000 PSay U_TamPag(66)+U_Reduz(0)				// P/ EPSON 
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
                      
    @prow()+1,006 psay cxCabec1      
    @prow()+1,006 psay cxCabec2
    @prow()+1,000 psay repli('-',80)
	Roda(0,"",Tamanho)
	
	//	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	//	@prow()+1,000 psay U_Negrito(.T.)+Padc("T i T U L O  DO R E L A T o R I O",80)+U_Negrito(.F.)
  	//	@prow()+1,000 psay U_expande(5)+'x'+U_expande(0)
 

/*	
	While !SZA->(Eof())

	  Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	  cGrupoCC := SZA->ZA_GRUPOCC
 	  
 	  @Prow()+1 ,000 psay Left(SZA->ZA_CUSTO,4) +' - ' + SZA->ZA_DESCCC
	  @Prow()+1 ,000 psay Replicate("-",80)
	
	  while ( !SZA->(Eof()) ) .and. ( SZA->ZA_GRUPOCC == cGrupoCC ) 
  		
		@Prow()+1,003      psay Left(SZA->ZA_CUSTO,4)
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
		    @prow()+1,006 psay cxCabec1      
    		@prow()+1,006 psay cxCabec2
    		@prow()+1,000 psay repli('-',80)
	 	    
	 	    @Prow()+1 ,000 psay Left(SZA->ZA_CUSTO,4) +' - ' + SZA->ZA_DESCCC
		    @Prow()+1 ,000 psay Replicate("-",80)
		endif                      

		@Prow()+1 ,006 psay Replicate("-",56)

	  Enddo
	  
	  If ( !SZA->(Eof()) )
	     //Roda(0,"",Tamanho)
      EndIf
      
	Enddo
*/
	   
return
