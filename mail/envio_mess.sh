#!/bin/bash
para=$1
asunto="Alarma Critica Swap Nodo $2"
mensaje="
NODO= $2
SERVICIO= Swap
Fecha/Hora= $3 $4
UTILIZACION= $5

Atte.
Equipo Soporte NLHPC
"
sendEmail -f alertas@nlhpc.cl -t $para  -m "$mensaje" -u "$asunto" -s mail.nlhpc.cl
