#!/usr/bin/perl

#Divide archivos en fragmentos de un tamaño dado.
#Permite unir los fragmentos de un archivo cortado
#PENDIENTE: Hacer refactoring para que la "main" sea &menu, desde la cual se lancen el resto de métodos. La actual main debería ser "abrir archivo" o similar

#Sustituir variables $entrada y $salida por $nombrearchivo o similar

use warnings;
use Fcntl 'SEEK_CUR';  #Requerido para sysseek (en systell)

#MENU // Main function:
my $opc=0;
my $ruta="";
while($opc!=1 && $opc!=2) {
  system("clear");
  print "Serrucho v0.2\n";
  print "                       ESCOGE OPCIÓN\n";
  print "                       -------------\n\n";
  print "          1  --> Cortar\n";
  print "          2  --> Pegar\n";
  print "          !q --> Salir\n\nOpción: ";
    $opc = <STDIN>;
    chop($opc);

  $ruta = &arcomp(&dircomp);
  print "\n RUTA GENERADA: $ruta";

  if($opc == 1) {
    &trozos;
    &corta;
  }
  elsif($opc == 2) {
    &pega;
  }
  elsif($opc eq "!q") {
    exit();
  }
}


################################################################################
##                        FUNCIONES:

#Opción 1: cortar
sub corta {
  $num=0;
  open(FENTRADA, "<$entrada");
  open(FSALIDA, ">$salida.ser.$num");
  binmode(FENTRADA);
  binmode(FSALIDA);
  $segi = time();
  while (!eof(FENTRADA)) {
    read(FENTRADA, $buffer, $buflon);
    syswrite(FSALIDA, $buffer, $buflon);
    $pos = systell(FSALIDA);
    $pos++;
    if($tam <= $pos) {
      $tam = -s FSALIDA;
      print "\nGuardando $salida.ser.$num      $tam bytes";
      $pos = 0;
      $num++;
      if(!eof(FENTRADA)) {
        close FSALIDA;
        open FSALIDA, ">$salida.ser.$num";
      }
    }
  }
  $tam = -s FSALIDA;
  $segf = time();
  $segst = $segf - $segi;
  if ($tam < $trozo) {
    $tam = -s FSALIDA;
    print "\nGuardando $salida.ser.$num      $tam bytes";
    $num++;
  }
  $tam = -s FENTRADA;
  print "\n\n\n         Archivo procesado en $segst segundo(s)";
  print "\n\n         Tamaño original:        $tam         bytes";
  $tam = $tam / 1024;
  printf ("\n                                 %.2f         KB", $tam);
  $tam = $tam / 1024;
  printf ("\n                                 %.2f            MB", $tam);
  print "\n\n         Archivos leídos: $num\n";
}

#Opción 2: pegar
sub pega {
  $salida = substr($salida, 0, -6);
  print "\nimprime la salida $salida";
  $entrada = $salida;
  open FSALIDA, ">$salida";
  $num = 0;
  if ($buflon == "") {
    $buflon = 524288;
  }
  $num=0;
  binmode(FSALIDA);
  $terminado=0;
  $segi = time();
  while ($terminado == 0) {
    if(!open FENTRADA, "$entrada.ser.$num") {
      $terminado=1;
    } else {
      $tam = -s FENTRADA;
      print "\nLeyendo $entrada.ser.$num      $tam bytes";
      binmode(FENTRADA);
      while(!eof(FENTRADA)) {
        read(FENTRADA, $buffer, $buflon);
        syswrite(FSALIDA, $buffer, $buflon);
      }
      close FENTRADA;
      $num++;
    }
  }
  $tam = -s FSALIDA;
  $segf = time();
  $segst = $segf - $segi;
  print "\n\n\n         Archivo procesado en $segst segundo(s)";
  print "\n\n         Tamaño final:           $tam         bytes";
  $tam = $tam / 1024;
  printf ("\n                                 %.2f         KB", $tam);
  $tam = $tam / 1024;
  printf ("\n                                 %.2f            MB", $tam);
  close FSALIDA;
  close FENTRADA;
  print "\n\nPulsa intro para salir";
  getc();
}

#Función para determinar la posición del "puntero" del fichero
sub systell { sysseek($_[0], 0, SEEK_CUR) }    #en el modo syswrite.

#Pide y comprueba que el directorio introducido es correcto (o asume el directorio actual) y genera una cadena con la ruta
sub dircomp {
  my $dir = 0;
  my $ruta = "";
  while($dir == 0) {
    system("clear");
    print "Ruta del fichero de entrada (intro para directorio actual): ";
    chop ($ruta = <STDIN>);
      if($ruta eq "") {
        chop($ruta = `pwd`);
        print "\n         Ruta correcta: $ruta";
        # chop ($ruta = `cd`);
        # print `pwd`;
        $dir = 1;
      } elsif (chdir($ruta)) {
          print "\n         Ruta correcta";
          $dir = 1;
      } else {
        print "\n         No se encuentra el directorio, pulse intro";
        getc();
      }
  }
  print "\n\nSe retornará $ruta";
  return($ruta);
}

#Pide el archivo de entrada y comprueba su existencia:
sub arcomp {
  my $ruta = shift(@_);
  my $sw=0;
  my $entrada, $salida, $rutacomp;
  print "\n\nNombre del fichero de entrada: ";
  chop ($entrada = <STDIN>);
  $salida=$entrada;
  if (!(open (FENTRADA, "$entrada"))) {
    while ($sw == 0) {
      system ("clear");
      print "Archivo no encontrado en la ruta\n";
      print "Nuevo nombre del fichero de entrada (!q para salir): ";
      chop ($entrada = <STDIN>);
      if (open (FENTRADA, "$entrada")) {
        $salida = $entrada;
        $sw = 1;
        $rutacomp = "$ruta\\$salida";
        print "Imprime ruta completa 1: $rutacomp\n"; #Debugging
        $rutacomp =~ s/\\\\/\\/g;
        print "Imprime ruta completa 2: $rutacomp"; #Debugging
      } elsif ($entrada eq "!q") {
          exit();
      }
    }
  }
}


#Determina el tamaño de cada archivo y el buffer de lectura/escritura
sub trozos {
  my $sw=0;
  while ($sw==0) {
    print "\nTamaño en MB de cada fragmento (d para disquete, c para cd-rom de 700MB): ";
    chop($tam = <STDIN>);
    if($tam > 0 && $tam ne "c" && $tam ne "d") {
      $tam = $tam * 1024 * 1024;
      $trozo = $tam;
      print "\nTamaño del buffer en MB (intro para usar el buffer por defecto): ";
      chop($buflon = <STDIN>);
      if ($buflon eq "") {
        if ($buflon >= $tam || $tam <= 16777216) {
          $buflon = $tam;
        } else {
          $buflon = 524288;
        }
      } else {
        $buflon = $buflon * 1024 * 1024;
      }
      $sw=1;
    } else {
      chop($tam);
      if((lc($tam)) eq "d") {
        $tam = 1437034;
        $buflon = 1437034;
        $sw=1;
      }
      if((lc($tam)) eq "c") {
        $tam = 737148928;
        $buflon=9961472;
        $sw=1;
      }
    }
  }
}
