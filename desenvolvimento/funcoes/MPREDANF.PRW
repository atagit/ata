/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Retornar o titulo da sigla do imposto na Pre-DANFE    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function MPREDANF(cSigla)
	local cRet := ""
	
	do case
		case cSigla == "ICM"
			cRet := "ICMS"
		case cSigla == "IPI"
			cRet := "IPI"
		case cSigla == "ICA"
			cRet := "ICMS ref. Frete Autonomo"
		case cSigla == "TST"
			cRet := "ICMS ref. Frete Autonomo - ST"
		case cSigla == "ICR"
			cRet := "ICMS Retido"
		case cSigla == "ICC"
			cRet := "ICMS Complementar"
		case cSigla == "ISS"
			cRet := "ISS"
		case cSigla == "IRR"
			cRet := "IRRF"
		case cSigla == "INS"
			cRet := "INSS"
		case cSigla == "COF"
			cRet := "COFINS - Via Retenção"
		case cSigla == "CSL"
			cRet := "CSLL - Via Retenção"
		case cSigla == "PIS"
			cRet := "PIS - Via Retençao"
		case cSigla == "FRU"
			cRet := "FUNRURAL"
		case cSigla == "PS2"
			cRet := "PIS/Pasep - Via Apuração"
		case cSigla == "CF2"
			cRet := "COFINS - Via Apuração"
		case cSigla == "AFR"			//AFRMM
			cRet := "AFRMM"
		case cSigla == "SES"
			cRet := "SEST/SENAT"
		case cSigla == "PS3"
			cRet := "PIS/Pasep - Subst. Tributária"
		case cSigla == "CF3"
			cRet := "COFINS - Subst. Tributária"
		case cSigla == "FET"
			cRet := "FETHAB"
		case cSigla == "FDS"
			cRet := "FUNDERSUL"
		otherwise
			cRet := "Sigla não encontrada"
	endcase
return cRet