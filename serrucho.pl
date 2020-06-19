#Divide archivos en fragmentos de un tamaño dado.
#Permite unir los fragmentos de un archivo cortado

&menu;
&dircomp;
&arcomp;
&trozos;

if($opc == 1) {
  $num=0;
  open(FENTRADA, "<$entrada");
  open(FSALIDA, ">$salida.$num");
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
      print "\nGuardando $salida.$num      $tam bytes";
      $pos = 0;
      $num++;
      if(!eof(FENTRADA)) {
        close FSALIDA;
        open FSALIDA, ">$salida.$num";
      }
    }
  }
  $tam = -s FSALIDA;
  $segf = time();
  $segst = $segf - $segi;
  if ($tam < $trozo) {
    $tam = -s FSALIDA;
    print "\nGuardando $salida.$num      $tam bytes";
    $num++;
  }
  $tam = -s FENTRADA;
  print "\n\n\n         Archivo procesado en $segst segundo(s)";
  print "\n\n         Tama¤o original:        $tam         bytes";
  $tam = $tam / 1024;
  printf ("\n                                 %.2f         KB", $tam);
  $tam = $tam / 1024;
  printf ("\n                                 %.2f            MB", $tam);
  print "\n\n         Archivos leidos: $num\n";
}
if($opc == 2) {
  chop($salida);
  chop($salida);
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
    if(!open FENTRADA, "$entrada.$num") {
      $terminado=1;
    } else {
      $tam = -s FENTRADA;
      print "\nLeyendo $entrada.$num      $tam bytes";
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
  print "\n\n         Tama¤o final:           $tam         bytes";
  $tam = $tam / 1024;
  printf ("\n                                 %.2f         KB", $tam);
  $tam = $tam / 1024;
  printf ("\n                                 %.2f            MB", $tam);}
close FSALIDA;
close FENTRADA;
print "\n\nPulsa intro para salir";
getc();


################################################
################################################
###################FUNCIONES:

use Fcntl 'SEEK_CUR';              #Función para determinar la posición del "puntero" del fichero
sub systell { sysseek($_[0], 0, SEEK_CUR) }    #en el modo syswrite.

#MENU:
sub menu {
  while($opc<1 || $opc>2) {
    system("cls");
    print "SERRUCHO\n";
    print "                                 ESCOGE OPCIàN";
    print "\n                                 -------------";
    print "\n\n1.- Cortar";
    print "\n2.- Pegar\n\n";
    $opc = <STDIN>;
  }
}

#Pide y comprueba que el directorio introducido es correcto (o asume el directorio actual) y genera una cadena con la ruta
sub dircomp {
  while($dir == 0) {
    system("cls");
    print "Ruta del fichero de entrada (intro para directorio actual): ";
    chop ($ruta = <STDIN>);
      if(chdir($ruta) || $ruta eq "") {
        $dir = 1;
        chop ($ruta = `cd`);
        print "\n         Ruta correcta\n\n";
      } else {
        print "\n         No se encuentra el directorio";
        getc();
      }
  }
  $rutacomp = "$ruta\\$salida";
  $rutacomp =~ s/\\\\/\\/g;
}

#Pide el archivo de entrada y omprueba su existencia:
sub arcomp {
  print "Nombre del fichero de entrada: ";
  chop ($entrada = <STDIN>);
  $salida=$entrada;
  $sw=0;
  if (!(open (FENTRADA, "$entrada"))) {
    while ($sw == 0) {
      system ("cls");
      print "Archivo no encontrado\nen la ruta $rutacomp";
      print "\nNuevo nombre del fichero de entrada (*q para salir): ";
      chop ($entrada = <STDIN>);
      if (open (FENTRADA, "$entrada")) {
        $salida = $entrada;
        $sw = 1;
        $rutacomp = "$ruta\\$salida";
        $rutacomp =~ s/\\\\/\\/g;
      } else {
        if ($entrada eq "*q") {
          exit();
        }
      }
    }
  }
}

#Determina el tamaño de cada archivo y el buffer de lectura/escritura
sub trozos {
  if ($opc == 1) {
    $sw=0;
    while ($sw==0) {
      print "\nTama¤o en MB de cada fragmento (d para disquete, c para cd-rom de 700MB): ";
      $tam = <STDIN>;
      if($tam > 0 && $tam ne "c" && $tam ne "d") {
        $tam = $tam * 1024 * 1024;
        $trozo = $tam;
        print "\nTama¤o del buffer en MB (intro para usar el buffer por defecto): ";
        $buflon = <STDIN>;
        $buflon = $buflon * 1024 * 1024;
        if ($buflon == "") {
          if ($buflon >= $tam || $tam <= 16777216) {
            $buflon = $tam;
          } else {
            $buflon = 524288;
          }
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
}
