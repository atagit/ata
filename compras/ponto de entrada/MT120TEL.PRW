#include "rwmake.ch"        
#include "protheus.ch"

user function MT120TEL()
local oNewDialog := PARAMIXB[1]
local aPosGet := PARAMIXB[2]
local aObj := PARAMIXB[3]
local nOpcx := PARAMIXB[4]

public _cNumRequi := Space(06)

@044,aPosGet[1,6] say "Requisicao" of oNewDialog pixel size 060,006
//@043,aPosGet[1,7] msget _cTransp picture PesqPict("SC7","C7_REQUI")  F3 CpoRetF3('C7_TRANSP','SA4') OF oNewDialog PIXEL SIZE 040,006
@043,aPosGet[1,7] msget _cNumRequi picture PesqPict("SC7","C7_NUMREQU") of oNewDialog pixel size 040,006
return(.T.)
 
//Utilizar este ponto para gravar o campo adicionado no cabeçalho do pedido
//User Function MT120GRV
//If !Acols[n][len(aHeader)+1]  //nao pega quando a linha esta deletada
    //Grava campos criados no cabeçalho do pedido
//RecLock("SC7",.F.)
      //SC7->C7_TRANSP  := _cTransp
   //MsUnlock("SC7")
//Endif