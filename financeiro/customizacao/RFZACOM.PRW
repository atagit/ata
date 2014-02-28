/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 03/02/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Refaz saldo do relatorio de acompanhamento            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function RFZACOM()
	private cDataIni := ""
	private cDataFin := ""
	private nRefazer := 5
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                                  ³
	//³ mv_par01 - Periodo de                                                ³
	//³ mv_par02 - Pediodo ate                                               ³
	//³ mv_par03 - Refazer (1-Recebido/2-Pago/3-Vendido/4-Comprado/5-Todos)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("RFZACO",.T.)
	
	cDataIni := DToS(mv_par01)
	cDataFin := DToS(mv_par02)
	nRefazer := mv_par03
	
	do case
		case nRefazer == 1
			Processa({|| Recebido()},"Aguarde...","Refazendo calculo do que foi recebido...",.F.)
		case nRefazer == 2
			Processa({|| Pago()},"Aguarde...","Refazendo calculo do que foi pago...",.F.)
		case nRefazer == 3
			Processa({|| Vendido()},"Aguarde...","Refazendo calculo do que foi vendido...",.F.)
		case nRefazer == 4
			Processa({|| Comprado()},"Aguarde...","Refazendo calculo do que foi comprado...",.F.)
		otherwise
			Processa({|| Recebido()},"Aguarde...","Refazendo calculo do que foi recebido...",.F.)
			Processa({|| Pago()},"Aguarde...","Refazendo calculo do que foi pago...",.F.)
			Processa({|| Vendido()},"Aguarde...","Refazendo calculo do que foi vendido...",.F.)
			Processa({|| Comprado()},"Aguarde...","Refazendo calculo do que foi comprado...",.F.)
	endcase
return

static function Recebido()
	cQry := "select E1_BAIXA, sum(E1_VALLIQ) as E1_VALLIQ "
	cQry += "from "+RetSqlName("SE1")+" "
	cQry += "where (E1_BAIXA between '"+cDataIni+"' and '"+cDataFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "group by E1_BAIXA"
	
	tcquery cQry alias "TMP" new
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if SZS->(DbSeek(xFilial("SZS")+TMP->E1_BAIXA,.F.))
			RecLock("SZS",.F.)
				SZS->ZS_RECFIN := TMP->E1_VALLIQ
				SZS->ZS_SLDFIN := TMP->E1_VALLIQ - SZS->ZS_PAGFIN
			MsUnLock()
		else
			RecLock("SZS",.T.)
				SZS->ZS_FILIAL := xFilial("SZS")
				SZS->ZS_ANO := Left(TMP->E1_BAIXA,4)
				SZS->ZS_MES := SubStr(TMP->E1_BAIXA,5,2)
				SZS->ZS_DIA := Right(TMP->E1_BAIXA,2)
				SZS->ZS_RECFIN := TMP->E1_VALLIQ
				SZS->ZS_SLDFIN := TMP->E1_VALLIQ
			MsUnLock()
		endif
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
return

static function Pago()
	cQry := "select E2_BAIXA, sum(E2_VALLIQ) as E2_VALLIQ "
	cQry += "from "+RetSqlName("SE2")+" "
	cQry += "where (E2_BAIXA between '"+cDataIni+"' and '"+cDataFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "group by E2_BAIXA"
	
	tcquery cQry alias "TMP" new
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if SZS->(DbSeek(xFilial("SZS")+TMP->E2_BAIXA,.F.))
			RecLock("SZS",.F.)
				SZS->ZS_PAGFIN := TMP->E2_VALLIQ
				SZS->ZS_SLDFIN := SZS->ZS_RECFIN - TMP->E2_VALLIQ
			MsUnLock()
		else
			RecLock("SZS",.T.)
				SZS->ZS_FILIAL := xFilial("SZS")
				SZS->ZS_ANO := Left(TMP->E2_BAIXA,4)
				SZS->ZS_MES := SubStr(TMP->E2_BAIXA,5,2)
				SZS->ZS_DIA := Right(TMP->E2_BAIXA,2)
				SZS->ZS_PAGFIN := TMP->E2_VALLIQ
				SZS->ZS_SLDFIN := TMP->E2_VALLIQ * -1
			MsUnLock()
		endif
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
return

static function Vendido()
	cQry := "select F2_EMISSAO, sum(F2_VALMERC) as F2_VALMERC "
	cQry += "from "+RetSqlName("SF2")+" "
	cQry += "where (F2_EMISSAO between '"+cDataIni+"' and '"+cDataFin+"') and F2_TIPO <> 'B' and D_E_L_E_T_ <> '*' "
	cQry += "group by F2_EMISSAO"
	
	tcquery cQry alias "TMP" new
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if SZS->(DbSeek(xFilial("SZS")+TMP->F2_EMISSAO,.F.))
			RecLock("SZS",.F.)
				SZS->ZS_RECFAT := TMP->F2_VALMERC
				SZS->ZS_SLDFAT := TMP->F2_VALMERC - SZS->ZS_PAGFAT
			MsUnLock()
		else
			RecLock("SZS",.T.)
				SZS->ZS_FILIAL := xFilial("SZS")
				SZS->ZS_ANO := Left(TMP->F2_EMISSAO,4)
				SZS->ZS_MES := SubStr(TMP->F2_EMISSAO,5,2)
				SZS->ZS_DIA := Right(TMP->F2_EMISSAO,2)
				SZS->ZS_RECFAT := TMP->F2_VALMERC
				SZS->ZS_SLDFAT := TMP->F2_VALMERC
			MsUnLock()
		endif
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
return

static function Comprado()
	cQry := "select C7_EMISSAO, sum(C7_TOTAL + C7_VALIPI - C7_VLDESC) as C7_TOTAL "
	cQry += "from "+RetSqlName("SC7")+" "
	cQry += "where (C7_EMISSAO between '"+cDataIni+"' and '"+cDataFin+"') and D_E_L_E_T_ <> '*' "
	cQry += "group by C7_EMISSAO"
	
	tcquery cQry alias "TMP" new
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if SZS->(DbSeek(xFilial("SZS")+TMP->C7_EMISSAO,.F.))
			RecLock("SZS",.F.)
				SZS->ZS_PAGFAT := TMP->C7_TOTAL
				SZS->ZS_SLDFAT := SZS->ZS_RECFAT - TMP->C7_TOTAL
			MsUnLock()
		else
			RecLock("SZS",.T.)
				SZS->ZS_FILIAL := xFilial("SZS")
				SZS->ZS_ANO := Left(TMP->C7_EMISSAO,4)
				SZS->ZS_MES := SubStr(TMP->C7_EMISSAO,5,2)
				SZS->ZS_DIA := Right(TMP->C7_EMISSAO,2)
				SZS->ZS_PAGFAT := TMP->C7_TOTAL
				SZS->ZS_SLDFAT := TMP->C7_TOTAL * -1
			MsUnLock()
		endif
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
return