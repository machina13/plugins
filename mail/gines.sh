#!/bin/bash
b=$(cat lista)
for a in $b
do
para=$a
mensaje='
Estimados Usuarios,

Les hago llegar este email para comentarles que vamos a postular a un proyecto Fondequip para aumentar los recursos computacionales del NLHPC, lo cual significa añadir nodos de cómputo con mayor capacidad de RAM y la inclusión de GPUs. 

Desde el NLHPC queremos solicitarles el apoyo a esta postulación. Para formalizar este apoyo le pedimos que nos hagan llegar una carta (en español o inglés) dirigida a FONDEQUIP apoyando el proyecto "Sistema Avanzado de Procesamiento y Servicios de Supercómputo", del cual yo seré el coordinador científico. Además, la carta debería de contener:
La investigación que están pudiendo realizar actualmente gracias a los recursos que ofrecemos desde el NLHPC (ojalá con alguna referencia a algún artículo con agradecimientos al NLHPC).
La investigación que podrían realizar gracias al aumento de los recursos, principalmente haciendo énfasis en las necesidades de memoria RAM, más CPU (estamos operando al 100% y con tiempos largos de espera en cola) y GPUs (estamos pensando en comprar también alguna GPU, debido a que así lo han manifestado muchos usuarios). Es importante que se justifique bein la necesidad de incorporar uno o varios de estos recursos.
Le repercusión científica de la investigación que están realizando y realizarán en un futuro cercano.
La carta puede ser firmada de manera individual o grupal. Ojalá que en la carta siempre vaya la firma de algún investigador con doctorado o del PI del grupo.

Adjunto una carta que un investigador nos ha hecho llegar para que les sirva de ejemplo el contenido de la misma (muchas gracias Jorge y Julio). Por favor, hacédnosla llegar con formato institucional antes de viernes 3 de mayo.

Desde ya, muchas gracias por todo vuestro apoyo. Entre todos podemos conseguir que la infraestructura computacional más grande de Chile pueda crecer y seguir ofreciendo recursos computacionales de manera gratuita para el progreso de la ciencia del país.

Atentamente,

Atte.
Equipo Soporte NLHPC
'
sendEmail -f gguerrero@nlhpc.cl -t $para -o message-file=body.html  -u "[NLHPC] Apoyo Postulación Fondequip" -s mail.nlhpc.cl
done
