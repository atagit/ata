/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de Equipamentos                             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

User Function RELSZJ()

	private nTotal 	:= 0
	private cTab   	:= " "
	private aOrd    := {"Grupo.CC + C.Custo + Num.Pat"}
	private aReturn := {"Especial", 1,"Administracao", 2, 2, 1, "", 4}
	private cPerg   := "SZF001"
	private Cabec1  := "                             "+space(39)+" Dias  Horas   Horas   Hrs.Máq   Indice   Vlr/mes a  Rateio de"
	private Cabec2  := "C.Custo Num.Pat.  Equipamento"+space(39)+"  Mes    Dia  Ociosas      Mes  Func(%)   Depreciar  Enegia(%)"
	private cDesc1  := "EQUIPAMENTOS" 
	private cString := "SZJ"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := "relSZJ"
	private lAborta := .T.
   	private cxCabec1:= Cabec1
   	private cxCabec2:= Cabec2
	private cNomeEmp:= ""
	private cTipEmp := ""
	private nReduz  := 5
	private nComp	:= 131
	private cPict1	:=	"@E 999,999.99"    

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
 
	cEmp := iif(Left(mv_par02,2)='09','01','02')

	If nImp == 1
	   Processa({|| ImprM()},"","Aguarde. Imprimindo...",lAborta)
	Else
		Processa({|| ImprL()},"","Aguarde impressão...",lAborta)
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

dbselectarea("SZJ")
dbSetOrder(4)

SET FILTER TO (ZJ_CUSTO >= mv_par01 .and. ZJ_CUSTO <= mv_par02)

dbGoTop()
	  
	
	ProcRegua(SZJ->(RecCount()))
	
	while !SZJ->(Eof())

	  Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	  
	  cGrupoCC := SZJ->ZJ_GRUPOCC

	  dbselectarea("CTT")
	  dbSetOrder(1)
	  dbseek(xfilial("CTT")+SZJ->ZJ_CUSTO)

	  cxGrupoCC := 'Grupo do C.C: '+cGrupoCC+"-"+CTT->CTT_DESC01 
	  @Prow()+1 ,000 psay cxGrupoCC
	  @Prow()+1 ,000 psay Replicate("-",51)

      dbselectarea("SZJ")
	
	  while ( !SZJ->(Eof()) ) .and. ( SZJ->ZJ_GRUPOCC == cGrupoCC ) 
	
		cCod := SZJ->ZJ_CUSTO                        
	
		@Prow()+1 ,000 psay Left(SZJ->ZJ_CUSTO,6)
		@Prow()  ,008 psay SZJ->ZJ_NUMPAT
		@Prow()  ,018 psay SZJ->ZJ_DESC
		@Prow()  ,071 psay SZJ->ZJ_DIASMES  picture "@E 99"
		@Prow()  ,074 psay SZJ->ZJ_HMDIA	picture "@E  999.99"
		@Prow()  ,083 psay SZJ->ZJ_HMDO 	picture "@E  999.99"
		@Prow()  ,091 psay SZJ->ZJ_HMMES    picture "@E 9999.99"
		@Prow()  ,100 psay SZJ->ZJ_INDT1    picture "@E 9999.99"
		@Prow()  ,109 psay SZJ->ZJ_VRADEPR  picture "@E 999,999.99"
		@Prow()  ,122 psay SZJ->ZJ_RATENER  picture "@E 999999.99"
		
		IncProc()
		
		SZJ->(DbSkip())

		If ( !SZJ->(Eof()) ) .and. ( (Prow() >= 57) )
			Roda(0,"",Tamanho)
			Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	   	  	@Prow()+1 ,000 psay cxGrupoCC
	  		@Prow()+1 ,000 psay Replicate("-",51)
		endif                      

		@Prow()+1,000 psay Replicate("-",131)
	  Enddo
	  
	  If !SZJ->(Eof())	                  
	    Roda(0,"",Tamanho)
	  EndIf
	  
	Enddo

set filter to
	   
return


Static Function ImprM()

dbselectarea("SZJ")
dbSetOrder(4)

SET FILTER TO (ZD_CUSTO >= mv_par01 .and. ZD_CUSTO <= mv_par02)

dbGoTop()
	
	ProcRegua(SZJ->(RecCount()))
	
	while !SZJ->(Eof())
    
	  cEmp := iif(Left(SZJ->ZJ_CUSTO,2)='09','01','02')

	  U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	  m_Pag := m_Pag + 1

	  cGrupoCC := SZJ->ZJ_GRUPOCC

	  dbselectarea("CTT")
	  dbSetOrder(1)
	  dbseek(xfilial("CTT")+SZJ->ZJ_CUSTO)
                                                
	  cxGrupoCC := 'Grupo do C.C: '+cGrupoCC+"-"+CTT->CTT_DESC01 
	  @Prow()+1 ,000 psay U_Reduz(5) + cxGrupoCC + U_Reduz(0)
	  @Prow()+1 ,000 psay U_Reduz(5) + Replicate("-",51) + U_Reduz(0)

      dbselectarea("SZJ")
	
	  while ( !SZJ->(Eof()) ) .and. ( SZJ->ZJ_GRUPOCC == cGrupoCC ) 
	
		cCod := SZJ->ZJ_CUSTO                        

		cImp := Left(SZJ->ZJ_CUSTO,8) + SZJ->ZJ_NUMPAT+SZJ->ZJ_DESC + "   "
		cImp := cImp + str(SZJ->ZJ_DIASMES,2) + " "  + str(SZJ->ZJ_HMDIA,6,2) + "   "
		cImp := cImp + str(SZJ->ZJ_HMDO,6,2)  + "  " + str(SZJ->ZJ_HMMES,7,2) + "  "
		cImp := cImp + str(SZJ->ZJ_INDT1,7,2) + "  " + transf(SZJ->ZJ_VRADEPR,cPict1) + "  "
		cImp := cImp + str(SZJ->ZJ_RATENER,9,2) 

		@Prow()+1 ,000 psay U_Reduz(5) + cImp + U_Reduz(0)

		IncProc()
		
		SZJ->(DbSkip())

		If ( !SZJ->(Eof()) ) .and. ( SZJ->ZJ_GRUPOCC == cGrupoCC ) .and. ( (Prow() >= 57) )

          cEmp := iif(Left(SZJ->ZJ_CUSTO,2)='09','01','02')

		  U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
		  m_Pag := m_Pag + 1
		  
		  @Prow()+1 ,000 psay U_Reduz(5) + cxGrupoCC + U_Reduz(0)
		  @Prow()+1 ,000 psay U_Reduz(5) + Replicate("-",51) + U_Reduz(0)
		
		endif                      

		@Prow()+1,000 psay U_Reduz(5)+Replicate("-",131)+U_Reduz(0)
	  Enddo
	  
	  If !SZJ->(Eof())	                  
	    //Roda(0,"",Tamanho)
	  EndIf
	  
	Enddo
	   
set filter to

return
