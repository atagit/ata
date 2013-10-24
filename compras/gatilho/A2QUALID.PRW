/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 05/02/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para calcular media da qualidade quando for   ¦
   ¦          ¦ fornecedor de servico                                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function A2QUALID()
	local nSoma := 0
	
	if(Empty(M->A2_SEGURAC),cSeguranc := 0,cSeguranc := Val(M->A2_SEGURAC))
	if(Empty(M->A2_CAPACIT),cCapacit := 0,cCapacit := Val(M->A2_CAPACIT))
	if(Empty(M->A2_INFRA),cInfra := 0,cInfra := Val(M->A2_INFRA))
	if(Empty(M->A2_DISPONI),cDisponi := 0,cDisponi := Val(M->A2_DISPONI))
	if(Empty(M->A2_PRAZO),cPrazo := 0,cPrazo := Val(M->A2_PRAZO))
	if(Empty(M->A2_QUALIDA),cQualida := 0,cQualida := Val(M->A2_QUALIDA))
	if(Empty(M->A2_PARCERI),cParceri := 0,cParceri := Val(M->A2_PARCERI))
	if(Empty(M->A2_MEIOAMB),cMeioamb := 0,cMeioamb := Val(M->A2_MEIOAMB))
	
	nSoma := cSeguranc+cCapacit+cInfra+cDisponi+cPrazo+cQualida+cParceri+cMeioamb
return (nSoma)