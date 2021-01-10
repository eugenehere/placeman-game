program game;

uses CRT, System;

type
  Tsaves = record
    moneys,mymoneys,sfoods,gfoods,sklads,hs,lvls,levels,pys,pxs,lys,lxs,vys,vxs,fys,fxs,thems:integer;
    dates:string[40];
    saving,lvl2s,lvl4s,lvl10s,cheatpans,commanders:boolean;
  end;

label Lstart, Lfinish, Lmenu, Linstr, Labout, Llevel,Lsett, if02, pin,Lload, lstartsaved;

var player:char; finish:char; px,fx,lx,py,fy,ly:integer; police,villager:char;
step,steplake,stepdollar,stepvill,stepvill2,i,j,stepproc,stepproccolor:integer;
money,level:integer; health:char; chat:string; punktmenu:byte;
vx,vy,h:integer; sm:char; proc:char; ctrl:integer; preview:boolean;
rx,ry:integer; lvl2,lvl4,lvl10:boolean; cheat:boolean; msg1:boolean;
sfood,gfood,prod,buyprod,lvl,mymoney,sklad,m,them,pincod:integer;
cheatpan,commander,coord,policeturn,villturn,procturn,chmon:boolean;
savefile:array[1..4] of file of TSaves;save:Tsaves;

function savedgame(n:integer): boolean;
begin
  reset(savefile[n]);
  read(savefile[n],save);
  if save.saving=true then savedgame:=true else savedgame:=false;
  closefile(savefile[n]);
end;

procedure loadgame(n:integer);
begin
  reset(savefile[n]);
  read(savefile[n],save);
  with save do
  begin
    saving:=true;
    money:=moneys;
    mymoney:=mymoneys;
    sfood:=sfoods;
    gfood:=gfoods;
    sklad:=sklads;
    h:=hs;
    lvl:=lvls;
    px:=pxs; py:=pys;
    lx:=lxs; ly:=lys;
    vx:=vxs; vy:=vys;
    fx:=fxs; fy:=fys;
    level:=levels;
    lvl10:=lvl10s;lvl4:=lvl4s;lvl2:=lvl2s;
    cheatpan:=cheatpans;
    commander:=commanders;
    them:=thems;
  end;
  closefile(savefile[n]);
end;

procedure savegame(n:integer);
var d:DateTime;
begin
  rewrite(savefile[n]);
  with save do
  begin
    saving:=true;
    dates:=inttostr(d.day)+'.'+inttostr(d.month)+'.'+inttostr(d.Year)+' - '+inttostr(d.Hour)+':'+inttostr(d.Minute);
    moneys:=money;
    mymoneys:=mymoney;
    sfoods:=sfood;
    gfoods:=gfood;
    sklads:=sklad;
    hs:=h;
    lvls:=lvl;
    pxs:=px; pys:=py;
    lxs:=lx; lys:=ly;
    vxs:=vx; vys:=vy;
    fxs:=fx; fys:=fy;
    levels:=level;
    lvl10s:=lvl10;lvl4s:=lvl4;lvl2s:=lvl2;
    cheatpans:=cheatpan;
    commanders:=commander;
    thems:=them;
  end;
  write(savefile[n],save);
  closefile(savefile[n]);
end;

function datesave(n:integer): string;
begin
  reset(savefile[n]);
  read(savefile[n],save);
  datesave:=save.dates;
  closefile(savefile[n]);
end;

procedure coordin;
begin
  textcolor(8);
  if (coord=true) then begin
  gotoxy(2,2);write('player: X:',px,' Y:',py);
  gotoxy(2,3);write('police X:',lx,' Y:',ly);
  gotoxy(2,4);write('dollar X:',fx,' Y:',fy);
  //gotoxy(2,5);write('cursor X:',wherex,' Y:',wherey);
  end;
end;

function location: integer;
begin
  if (px=27) and (py=18) then location:=1;//home
  if (px in [43..47]) and (py=10) then location:=2;//bank
  if (px=74) and (py=10) then location:=3;//police
  if (px=13) and (py=15) then location:=4; //shop
  if (px in [62..68]) and (py=17) then location:=5 ;//station
end;

function playergran(x,y:integer): boolean;
begin
  playergran:=true;
  if (x in [63..77]) and (y in [4..9]) then playergran:=false;//полицейский участок
  if ((x in [1..80]) and (y = 1)) or ((x = 1) and (y in [1..25])) then playergran:=false;//границы карты
  if ((x in [1..80]) and (y = 24)) or ((x = 80) and (y in [1..25])) then playergran:=false;//границы карты
  if (x in [50..80]) and (y in [20..24]) then playergran:=false; //нижняя правая панель (чат)
  if (x in [2..14]) and (y in [20..24]) then playergran:=false; //нижня левая область
  if (x in [19..26]) and (y in [15..21]) then playergran:=false; // home
  if (x in [39..60]) and (y in [4..9]) then playergran:=false; //bank
  if (x in [2..16]) and (y in [2..6]) then  playergran:=false; //lake part 01;
  if (x in [17..26]) and (y in [2..5]) then playergran:=false; //lake part 02;
  if (x in [27,28]) and (y in [2,3]) then playergran:=false; //lake part 03;
  if (x in [50..79]) and (y in [18..19]) then playergran:=false; //station;
  if (x in [37..42]) and (y in [20..21]) then playergran:=false;//car
  if (x in [14..17]) and (y in [13..17]) then playergran:=false;//shop
end;

procedure gamewindow(y1,y2:integer);
var i:integer;
begin
  textcolor(black);
  gotoxy(3,y1);write('╔══════════════════════════════════════════════════════════════════════════╗');
  for i:=y1+1 to y2-1 do begin
  gotoxy(3,i); write('║                                                                          ║');
  gotoxy(3,y2);write('╚══════════════════════════════════════════════════════════════════════════╝');
  gotoxy(1,1);
end;
end;

procedure setproc;
begin
  gotoxy(rx,ry);
  if stepproccolor=0 then begin
    textcolor(5);
    stepproccolor:=1;
    end
  else begin
    textcolor(13);
    stepproccolor:=0;
  end;
  write(proc);
  stepproc:=stepproc+1;
end;

procedure changeproc;
label if01;
begin
  if01:
  rx:=(px-10)+PABCSystem.random(21);
  ry:=(py-6)+PABCSystem.random(13);
    //места в которых не должен спавнится %
  if (rx in [63..77]) and (ry in [4..9]) then goto if01;//полицейский участок
  if ((rx in [1..80]) and (ry = 1)) or ((rx = 1) and (ry in [1..25])) then goto if01;//границы карты
  if ((rx in [1..80]) and (ry = 24)) or ((rx = 80) and (ry in [1..25])) then goto if01;//границы карты
  if (rx in [50..80]) and (ry in [20..24]) then goto if01; //нижняя правая панель (чат)
  if (rx in [2..14]) and (ry in [20..24]) then goto if01; //нижня левая область
  if (rx in [19..26]) and (ry in [15..21]) then goto if01; // home
  if (rx in [39..60]) and (ry in [4..9]) then goto if01; //bank
  if (rx in [2..16]) and (ry in [2..6]) then goto if01; //lake part 01;
  if (rx in [17..26]) and (ry in [2..5]) then goto if01; //lake part 02;
  if (rx in [27,28]) and (ry in [2,3]) then goto if01; //lake part 03;
  if (rx in [50..79]) and (ry in [17..19]) then goto if01; //station;
  if (rx in [43..46]) and (ry in [16]) then goto if01; //надпись PARK
  if (rx in [80..100]) or (ry in [25..40]) then goto if01; // область за окошком с игрой
  if (rx<=0) or (ry<=0) then goto if01; // если отрецательные
  if (rx in [37..42]) and (ry in [20..21]) then goto if01;//car
  if (rx=26) and (ry=18) then goto if01; //locate home
  if (rx in [43..47]) and (ry=10) then goto if01; //locate bank
  if (rx=74) and (ry=10) then goto if01; //locate police
  if (rx=13) and (ry=15) then goto if01; //locate shop
  if (fx in [14..13]) and (fy in [13..17]) then goto if01;//  shop
end;

procedure villager01;
label s1,s2,s3,s4, Lend;
var i:integer;
begin
  stepvill:=stepvill+1;
  if stepvill=1 then
  begin
  //область, на которую не должен заходить житель.
  if (vx+1 in [63..77]) and (vy+1 in [4..9]) then ctrl:=1;//1. полицейский участок
  if (vx+1 in [63..77]) and (vy-1 in [4..9]) then ctrl:=2;
  if (vx-1 in [63..77]) and (vy+1 in [4..9]) then ctrl:=3;
  if (vx-1 in [63..77]) and (vy-1 in [4..9]) then ctrl:=4;
  
  if (vx+1 in [50..80]) and (vy+1 in [18..24]) then ctrl:=1;//2. нижняя правая панель (чат) + station
  
  if (vx+1 in [2..14]) and (vy+1 in [20..24]) then ctrl:=1; //3.нижняя левая область
  if (vx-1 in [2..14]) and (vy+1 in [20..24]) then ctrl:=3;  
  
  if (vx+1 in [39..60]) and (vy+1 in [4..9]) then ctrl:=1;//4. банк
  if (vx+1 in [39..60]) and (vy-1 in [4..9]) then ctrl:=2;
  if (vx-1 in [39..60]) and (vy+1 in [4..9]) then ctrl:=3;
  if (vx-1 in [39..60]) and (vy-1 in [4..9]) then ctrl:=4;
  
  if (vx+1 in [19..26]) and (vy+1 in [15..21]) then ctrl:=1;//4. home
  if (vx+1 in [19..26]) and (vy-1 in [15..21]) then ctrl:=2;
  if (vx-1 in [19..26]) and (vy+1 in [15..21]) then ctrl:=3;
  if (vx-1 in [19..26]) and (vy-1 in [15..21]) then ctrl:=4;
  
  if (vx-1 in [2..16]) and (vy-1 = 6) then ctrl:=4; //lake по контурам
  if (vx-1 in [17..23]) and (vy-1 = 5) then ctrl:=4;
  if (vx-1 in [24..26]) and (vy-1 = 4) then ctrl:=4;
  if (vx-1 in [17..23]) and (vy-1 = 5) then ctrl:=4;
  if (vx-1 = 27) and (vy-1 = 3) then ctrl:=4;
  if (vx-1 = 28) and (vy-1 = 2) then ctrl:=4;
  
  if (vx+1 in [lx-2..lx+2]) and (vy+1 in [ly-2..ly+2]) then ctrl:=1;//зона "комфорта" легавого
  if (vx+1 in [lx-2..lx+2]) and (vy-1 in [ly-2..ly+2]) then ctrl:=2;
  if (vx-1 in [lx-2..lx+2]) and (vy+1 in [ly-2..ly+2]) then ctrl:=3;
  if (vx-1 in [lx-2..lx+2]) and (vy-1 in [ly-2..ly+2]) then ctrl:=4;
  
  if (vx+1 in [14..17]) and (vy+1 in [13..17]) then ctrl:=1;//shop
  if (vx+1 in [14..17]) and (vy-1 in [13..17]) then ctrl:=2;
  if (vx-1 in [14..17]) and (vy+1 in [13..17]) then ctrl:=3;
  if (vx-1 in [14..17]) and (vy-1 in [13..17]) then ctrl:=4;
  
  
  
  if vx<=px then
  begin
    if (ctrl=1) or (ctrl = 2) then goto s1 else
    if vx=px then goto s1;
    vx:=vx+1;
    s1:
    gotoxy(vx,vy);
  end
  
  else
  begin
    if (ctrl=3) or (ctrl=4) then goto s2 else
    if vx=px then goto s2;
    vx:=vx-1;
    s2:
    gotoxy(vx,vy);
  end;
  
  if vy<py then
  begin
    if (ctrl=1) or (ctrl=3) then goto s3 else
    if vy=py then goto s3;
    vy:=vy+1;
    s3:
    gotoxy(vx,vy);
  end
  
  else
  begin
    if (ctrl=2) or (ctrl=4) then goto s4 else
    if vy=py then goto s4;
    vy:=vy-1;
    s4:
    gotoxy(vx,vy);
  end;
  
  write(villager);
  end
  else
    stepvill:=0;
  ctrl:=0;
  Lend:
  textcolor(black);
  gotoxy(vx,vy);
  write(villager);
end;

procedure changefin;
label if01;
begin
  if01:
  fy:=PABCSystem.random(23)+2;
  fx:=PABCSystem.random(77)+2;
  
  //места в которых не должен спавнится $
  if (fx in [63..77]) and (fy in [4..9]) then goto if01;//полицейский участок
  if ((fx in [1..80]) and (fy = 1)) or ((fx = 1) and (fy in [1..25])) then goto if01;//границы карты
  if ((fx in [1..80]) and (fy = 24)) or ((fx = 80) and (fy in [1..25])) then goto if01;//границы карты
  if (fx in [50..80]) and (fy in [20..24]) then goto if01; //нижняя правая панель (чат)
  if (fx in [2..14]) and (fy in [20..24]) then goto if01; //нижня левая область
  if (fx in [19..26]) and (fy in [15..21]) then goto if01; // home
  if (fx in [39..60]) and (fy in [4..9]) then goto if01; //bank
  if (fx in [14..17]) and (fy in [13..17]) then goto if01;//  shop
  if (fx in [2..16]) and (fy in [2..6]) then goto if01; //lake part 01;
  if (fx in [17..26]) and (fy in [2..5]) then goto if01; //lake part 02;
  if (fx in [27,28]) and (fy in [2,3]) then goto if01; //lake part 03;
  if (fx in [50..79]) and (fy in [17..19]) then goto if01; //station;
  if (fx in [43..46]) and (fy in [16]) then goto if01; //надпись PARK
  if (fx in [37..42]) and (fy in [20..21]) then goto if01;//car
  if (fx=26) and (fy=18) then goto if01; //locate home
  if (rx in [43..47]) and (fy=10) then goto if01; //locate bank
  if (fx=74) and (fy=10) then goto if01; //locate police
  if (fx=13) and (fy=15) then goto if01; //locate shop
  
end;

procedure policemoving;
label Lend, s1, s2, s3, s4;
var ctrl:integer;
begin
  step:=step+1;
  if step=1 then
  begin
  //область, на которую не должен заходить легавый.
  if (lx+1 in [63..77]) and (ly+1 in [4..9]) then ctrl:=1;//1. полицейский участок
  if (lx+1 in [63..77]) and (ly-1 in [4..9]) then ctrl:=2;
  if (lx-1 in [63..77]) and (ly+1 in [4..9]) then ctrl:=3;
  if (lx-1 in [63..77]) and (ly-1 in [4..9]) then ctrl:=4;
  
  if (lx+1 in [50..80]) and (ly+1 in [18..24]) then ctrl:=1;//2. нижняя правая панель (чат) + station
  
  if (lx+1 in [2..14]) and (ly+1 in [20..24]) then ctrl:=1; //3.нижняя левая область
  if (lx-1 in [2..14]) and (ly+1 in [20..24]) then ctrl:=3;  
  
  if (lx+1 in [39..60]) and (ly+1 in [4..9]) then ctrl:=1;//4. банк
  if (lx+1 in [39..60]) and (ly-1 in [4..9]) then ctrl:=2;
  if (lx-1 in [39..60]) and (ly+1 in [4..9]) then ctrl:=3;
  if (lx-1 in [39..60]) and (ly-1 in [4..9]) then ctrl:=4;
  
  if (lx+1 in [19..26]) and (ly+1 in [15..21]) then ctrl:=1;//4. home
  if (lx+1 in [19..26]) and (ly-1 in [15..21]) then ctrl:=2;
  if (lx-1 in [19..26]) and (ly+1 in [15..21]) then ctrl:=3;
  if (lx-1 in [19..26]) and (ly-1 in [15..21]) then ctrl:=4;
  
  if (lx-1 in [2..16]) and (ly-1 = 6) then ctrl:=4; //lake по контурам
  if (lx-1 in [17..23]) and (ly-1 = 5) then ctrl:=4;
  if (lx-1 in [24..26]) and (ly-1 = 4) then ctrl:=4;
  if (lx-1 in [17..23]) and (ly-1 = 5) then ctrl:=4;
  if (lx-1 = 27) and (ly-1 = 3) then ctrl:=4;
  if (lx-1 = 28) and (ly-1 = 2) then ctrl:=4;
  
  if (lx+1 in [14..17]) and (ly+1 in [13..17]) then ctrl:=1;//shop
  if (lx+1 in [14..17]) and (ly-1 in [13..17]) then ctrl:=2;
  if (lx-1 in [14..17]) and (ly+1 in [13..17]) then ctrl:=3;
  if (lx-1 in [14..17]) and (ly-1 in [13..17]) then ctrl:=4;
  
  
  if lx<=px then
  begin
    if (ctrl=1) or (ctrl = 2) then goto s1 else
    if lx=px then goto s1;
    lx:=lx+1;
    s1:
    gotoxy(lx,ly);
  end
  
  else
  begin
    if (ctrl=3) or (ctrl=4) then goto s2 else
    if lx=px then goto s2;
    lx:=lx-1;
    s2:
    gotoxy(lx,ly);
  end;
  
  if ly<py then
  begin
    if (ctrl=1) or (ctrl=3) then goto s3 else
    if ly=py then goto s3;
    ly:=ly+1;
    s3:
    gotoxy(lx,ly);
  end
  
  else
  begin
    if (ctrl=2) or (ctrl=4) then goto s4 else
    if ly=py then goto s4;
    ly:=ly-1;
    s4:
    gotoxy(lx,ly);
  end;
  
  write(police);
  end
  else
    step:=0;
  ctrl:=0;
  Lend:
  textcolor(blue);
  gotoxy(lx,ly);
  write(police);
end;

Procedure SetFin;
begin
  gotoxy(fx,fy);
  if stepdollar=0 then
  begin
    textcolor(red);stepdollar:=1;
  end
  else
  begin
    textcolor(lightred);stepdollar:=0;
  end;
  write(finish);
end;

procedure graph;
var i,lev:integer;
begin
  textcolor(black);
  gotoxy(1,1);
  write('╔══════════════════════════════════════════════════════════════════════════════╗');
  for i:=2 to 23 do
  begin
    gotoxy(1,i);
    write('║');
  end;
  for i:=2 to 23 do
  begin
    gotoxy(80,i);
    write('║');  
  end;
  gotoxy(50,20);
  write('╔═════════════════════════════╣');
  gotoxy(50,21);write('║');textcolor(7);if commander=true then write(' "/" - ввести команду') else write(' "M" - выйти в меню'); textcolor(black);
  gotoxy(50,22);
  write('╟─────────────────────────────╢');
  gotoxy(50,23);write('║');textcolor(7);
  if (chat='Вас ранил житель (-2xp)') or (chat='У вас задолжность в банке!') or (chat='Вы заплатили налоги!') then textcolor(red); //chat:=inttostr(mon)+'$';
  write(' ',chat);textcolor(black);
  gotoxy(1,24);
  write('╚════════════════════════════════════════════════╩═════════════════════════════╝');
  
  gotoxy(1,20);write('╠════════════╗');
   gotoxy(2,21);write('            ║');
   gotoxy(2,22);write('            ║');
   gotoxy(2,23);write('            ║');
 gotoxy(14,24);write('╩');
  textcolor(lightred);
  gotoxy(2,21);write(' ',health*h);
  textcolor(7);
  gotoxy(2,22);write(' ',mymoney,'$');
  textcolor(lightgreen);
  gotoxy(2,23);write(' LVL:',level,' ',lvl,'/',(lvl div 10)+1,'0');
end;

procedure houses;
var i,j:integer; m:real;
begin

  //shop
  textcolor(7);
  gotoxy(14,13);write('╓──┐');
  gotoxy(14,14);write('╢██│');
  gotoxy(14,15);write('███│');
  gotoxy(14,16);write('╢██│');
  gotoxy(14,17);write('╚══╛');
  textcolor(lightgreen);
  gotoxy(13,14);write('¤');
  gotoxy(13,16);write('¤');
  textcolor(black);gotoxy(13,15);write('▒');
  
  //Police
  textcolor(7);
  gotoxy(63,4);
  write('╓─────────────┐');
  gotoxy(63,5);
  write('║█████████████│');
  gotoxy(63,6);
  write('║█████████████│');
  gotoxy(63,7);
  write('║█████████████│');
  gotoxy(63,8);
  write('║█████████████│');
  gotoxy(63,9);
  write('╚════════╤▄▄▄╤╛');
  textcolor(blue);gotoxy(67,6);write('POLICE');
  textcolor(lightgreen);
  gotoxy(63,10);
  write('       ¤¤     ¤¤');
  textcolor(black);
  gotoxy(73,10);write('▒▒▒');
  gotoxy(73,11);write('▒▒▒');
  textcolor(7);
  //home
  textcolor(7);
  gotoxy(19,15);write('╓──────┐');
  gotoxy(19,16);write('║██████│');
  gotoxy(19,17);write('║██████╞');textcolor(lightgreen); write(' ¤');textcolor(7);
  gotoxy(19,18);write('║██████▐');textcolor(black);write('▒▒▒▒');textcolor(7);
  gotoxy(19,19);write('║██████╞');textcolor(lightgreen); write(' ¤');textcolor(7);
  gotoxy(19,20);write('║██████│');
  gotoxy(19,21);write('╚══════╛');
  
  textcolor(black);
  gotoxy(21,18);write('HOME');
  
  textcolor(7);
  
  
  //bank
  TextColor(7);
  gotoxy(39,4);write('╓────────────────┴─┴─┐');
  gotoxy(39,5);write('║████████████████████│');
  gotoxy(39,6);write('║████████████████████│');
  gotoxy(39,7);write('║████████████████████│');
  gotoxy(39,8);write('║████████████████████│');
  gotoxy(39,9);write('╚══╗▄▄▄▄▄╒═══════════╛');
 gotoxy(39,10);write('   ╙° ° °┘');
 textcolor(lightgreen);
gotoxy(37,10);write('¤ ¤ ¤       ¤ ¤ ¤');
 gotoxy(38,11);write('¤ ¤         ¤ ¤');
 textcolor(black);
 gotoxy(48,6);write('BANK');
 gotoxy(43,10);write('░░░░░');
 gotoxy(43,11);write('░░░');
 gotoxy(43,12);write('░░░');
 
 
 
 //money in bank
 m:=money;j:=0;
 if m<0 then m:=m*(-1);
 while m>=1 do
 begin
  m:=m/10;
  j:=j+1;
 end;
 case j of
 0..2 : begin gotoxy(49,7);write('',money,'$'); end;
 3 : begin gotoxy(48,7);write('',money,'$'); end;
 4..5 : begin gotoxy(47,7);write('',money,'$'); end;
 6..10 : begin gotoxy(46,7);write('',money,'$'); end;
 end;
  
  
  //roads
  textcolor(black);
  for i:=2 to 17 do begin
  gotoxy(30,i);write('▒▓▓▓▓▓░');
  end;
  gotoxy(30,18);write('▓▓▓▓▓▓░');
  for i:=19 to 23 do begin
  gotoxy(30,i);write('▒▓▓▓▓▓░');
  end;
  
  gotoxy(36,12);write('▒▒▒▒▒▒▒▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▒▒▒▒');
  gotoxy(35,13);write('▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(35,14);write('▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(35,15);write('▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(36,16);write('░░░░░░░    ░░░░░░░░░░░░░░▓▓▓▓▓▓▓▓▓░░░░░░░░░░');
  gotoxy(36,17);write('░           ░ ');
  gotoxy(36,18);write('░           ░ ');
  gotoxy(36,19);write('░------     ░ ');
  gotoxy(36,20);write('░           ░');
  gotoxy(36,21);write('░           ░');
  gotoxy(36,22);write('░------     ░');
  gotoxy(36,23);write('░           ░');
  
  gotoxy(2,8);write('▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒');
  gotoxy(2,9);write('▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(2,10);write('▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(2,11);write('▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(2,12);write('░░░░░░░░░░░░░░░░░░░░░░░░░░░░');
   
   textcolor(black);
   gotoxy(50,17);write('    ◄▄▄▄▄▄▄ STATION ▄▄▄▄▄▄►   ');
   textcolor(brown);
   gotoxy(50,18);write(' ╔╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪');
   gotoxy(50,19);write(' ╫ ╔╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪╪');
   
   textcolor(Black);
   gotoxy(37,20);write('├▀══▀╢');
   gotoxy(37,21);write('├▄══▄╢');
  
  textcolor(black);gotoxy(43,16);write('PARK');
  
  //tress
  textcolor(black);
  for i:=12 to 18 do
  begin
    gotoxy(10,i);write('▓▓▓');
  end;
  gotoxy(2,18);write('▓▓▓▓▓▓▓▓▓▓▓');
  gotoxy(2,19);write('▓▓▓▓▓▓▓▓▓▓▓');
  
  textcolor(lightgreen);
  gotoxy(3,14);write('¤');gotoxy(5,14);write('√');
  textcolor(yellow);
  gotoxy(3,16);write('☼');
  textcolor(lightgreen);
  gotoxy(3,17);write('√');
  gotoxy(6,17);write('¤');gotoxy(16,19);write('√');
  gotoxy(7,15);write('¤');gotoxy(26,6);write('√');
  gotoxy(3,14);write('¤');
  gotoxy(3,14);write('¤');
  textcolor(yellow);
  gotoxy(5,13);write('☼');
  textcolor(lightgreen);
  gotoxy(8,13);write('¤');
  textcolor(yellow);
  gotoxy(16,18);write('☼');
  textcolor(lightgreen);
  gotoxy(17,22);write('¤');
  gotoxy(19,14);write('¤');

  gotoxy(27,23);write('¤');
  
  gotoxy(28,5);write('¤');
  textcolor(yellow);
  gotoxy(26,5);write('☼');
  textcolor(lightgreen);
  gotoxy(8,7);write('¤');
  
  //lake
  textcolor(yellow);
  gotoxy(2,6);write('▓');
  gotoxy(3,6);write('▓');
  gotoxy(4,6);write('▓');
  gotoxy(5,6);write('▓');
  gotoxy(6,6);write('▓');
  gotoxy(7,6);write('▓');
  gotoxy(8,6);write('▓');
  gotoxy(9,6);write('▓');
  gotoxy(10,6);write('▓');
  gotoxy(11,6);write('▓');
  gotoxy(12,6);write('▓');
  gotoxy(13,6);write('▓');
  gotoxy(14,6);write('▓');
  gotoxy(15,6);write('▓');
  gotoxy(16,6);write('▓');
  gotoxy(17,5);write('▓');
  gotoxy(18,5);write('▓');
  gotoxy(19,5);write('▓');
  gotoxy(20,5);write('▓');
  gotoxy(20,5);write('▓');
  gotoxy(21,5);write('▓');
  gotoxy(22,5);write('▓');
  gotoxy(23,5);write('▓');
  gotoxy(24,4);write('▓');
  gotoxy(25,4);write('▓');
  gotoxy(26,4);write('▓');
  gotoxy(27,3);write('▓');
  gotoxy(27,2);write('▓▓');
  
  textcolor(9);
  if steplake=1 then
  begin
  //textcolor(9);
  gotoxy(2,2);write('▓▓██▓▓██▓▓██▓▓██▓▓██▓▓██▓');
  //textcolor(1);
  gotoxy(2,3);write('██▓▓██▓▓██▓▓██▓▓██▓▓██▓▓█');
  //textcolor(9);
  gotoxy(2,4);write('▓▓██▓▓██▓▓██▓▓██▓▓██▓▓');
  //textcolor(1);
  gotoxy(2,5);write('██▓▓██▓▓██▓▓██▓');
  
  steplake:=0;
  end else
  begin
  //textcolor(1);
  gotoxy(2,2);write('██▓▓██▓▓██▓▓██▓▓██▓▓██▓▓█');
  //textcolor(9);
  gotoxy(2,3);write('▓▓██▓▓██▓▓██▓▓██▓▓██▓▓██▓');
  //textcolor(1);
  gotoxy(2,4);write('██▓▓██▓▓██▓▓██▓▓██▓▓██');
  //textcolor(9);
  gotoxy(2,5);write('▓▓██▓▓██▓▓██▓▓█');
  
  steplake:=1;
  end;
  textcolor(7);
  //gotoxy(2,14);write('C:',steplake);
end;

procedure MPDown;
label Lend;
begin
  if cheat=false then
  if playergran(px,py+1)=false then goto lend;
  //if py+1=24 then goto Lend;
  py:=py+1;
  clrscr;graph;houses;setfin;policemoving;coordin;
  if level>=2 then
    villager01;
  if level >=4 then
    setproc;
  gotoxy(px,py);textcolor(white);
  write(player);
  Lend:
end;

procedure MPUp;
label Lend;
begin
  if cheat=false then
  if playergran(px,py-1)=false then goto lend;
  //if py-1=1 then goto Lend;
  py:=py-1;
  clrscr;graph;houses;setfin;policemoving;coordin;
  if level>=2 then
    villager01;
  if level >=4 then
    setproc;
  gotoxy(px,py);textcolor(white);
  write(player);
  Lend:
end;

procedure MPLeft;
label Lend;
begin
  if cheat=false then
  if playergran(px-1,py)=false then goto lend;
  //if px-1=1 then goto Lend;
  px:=px-1;
  clrscr;graph;houses;setfin;policemoving;coordin;
  if level>=2 then
    villager01;
  if level >=4 then
    setproc;
  gotoxy(px,py);textcolor(white);
  write(player);
  Lend:
end;

procedure MPRight;
label Lend;
begin
  if cheat=false then
  if playergran(px+1,py)=false then goto lend;
  //if px+1=80 then goto Lend;
  px:=px+1;
  clrscr;graph;houses;setfin;policemoving;coordin;
  if level>=2 then
    villager01;
  if level >=4 then
    setproc;
  gotoxy(px,py);textcolor(white);
  write(player);
  Lend:
end;

procedure rect(x1,y1,x2,y2 :integer);
var i,j:integer;
begin
  textcolor(black);
  gotoxy(x1,y1); write('╔');
  gotoxy(x1,y2); write('╚');
  gotoxy(x2,y1); write('╗');
  gotoxy(x2,y2); write('╝');
  
  for i:=x1+1 to x2-1 do
  begin
    gotoxy(i,y1);
    write('═');
  end;
  
  for i:=x1+1 to x2-1 do
  begin
    gotoxy(i,y2);
    write('═');
  end;
  
  for i:=y1+1 to y2-1 do
  begin
    gotoxy(x1,i);
    write('║');
  end;
  
  for i:=y1+1 to y2-1 do
  begin
    gotoxy(x2,i);
    write('║');
  end;
end;

procedure closepage(l:integer);
label if03, if04;
var i,j:integer;
begin
  j:=0;
  if04:
  textcolor(red);
  gotoxy(4,l);write('(C)lose page');
  if readkey = 'c' then goto if03
  else begin
  for i:=1 to 2 do begin
  if j=5 then begin gotoxy(25,l); textcolor(8); write('                         (Нажмите "с" чтобы закрыть)'); end;
  textcolor(lightred);
  gotoxy(4,l);write('(C)lose page');
  delay(100);
  textcolor(red);
  gotoxy(4,l);write('(C)lose page');
  delay(100);
  j:=j+1;
  end;
  goto if04;
  
  if03:
  clrscr;graph;houses;setfin;policemoving;
  if level>=2 then
    villager01;
  gotoxy(px,py);textcolor(white);
  write(player);
end;
end;

procedure location01;//home
label lct1, lexit;
var p:integer;
begin
  p:=1;
  lct1:
  repeat;
  gamewindow(4,22);
  textcolor(7);
  gotoxy(5,6);write('Вы зашли к себе домой. Выберите действие:');
  gotoxy(7,8);write('Поспать 1 ночь');
  gotoxy(7,10);write('Сьесть 1 еденицу еды (+1xp)');
  gotoxy(7,12);write('Приготовить 1 еденицу еды (-1000$ за газ/електричество)');textcolor(8);
  gotoxy(5,14);write('Состояние холодильника:');
  gotoxy(7,16);write('Сырая еда: ');textcolor(8);write(sfood);textcolor(8);
  gotoxy(7,18);write('Приготовленная еда: ');textcolor(8);write(gfood);textcolor(7);
  gotoxy(37,20);write('Выйти');
  textcolor(white);
  case p of
  1 : begin gotoxy(5,8); write('>'); end;
  2 : begin gotoxy(5,10); write('>'); end;
  3 : begin gotoxy(5,12); write('>'); end;
  4 : begin gotoxy(35,20);write('>'); end;
  end;
  case readkey of
  'w' : p:=p-1;
  's' : p:=p+1;
  #13 : case p of
        1 : begin lx:=74; ly:=10; vx:=2; vy:=10; chat:='Вы хорошо выспались :)';goto lexit; end;
        2 : begin
              if (gfood<=0) then
              begin
                gotoxy(29,14);textcolor(red);write('(недостаточно еды)');delay(500);
              end
              else begin if h>=10 then begin textcolor(red);gotoxy(29,14);write('(вам не хочется есть)');delay(500); end else begin gfood:=gfood-1; h:=h+1; end; end;
            end;
        3 : begin if sfood<=0 then begin gotoxy(29,14);textcolor(red);write('(недостаточно еды)');delay(500); end else begin sfood:=sfood-1; gfood:=gfood+1; money:=money-1000; end; end;
        4 : goto lexit;
        end;
  end;
  until (p=0) or (p=5);
  if p=0 then p:=4 else p:=1; goto lct1;
  lexit:
  clrscr;graph;houses;setfin;policemoving;
  if level>=2 then
  villager01;
  px:=28;py:=18;
  gotoxy(px,py);textcolor(white);
  write(player);
end;

procedure location04;//shop
label lct1,if04, lexit;
var p,i,j:integer;
begin
  p:=1;
  lct1:
  repeat;
  gamewindow(4,23);
  textcolor(7);
  gotoxy(5,6);write('Вы зашли в продуктовый магазин. Выберите действие:');
  gotoxy(7,10);write('Введите кол-во продуктов для покупки/продажи: ');
  gotoxy(53,9);write('╓──────╖');
  gotoxy(53,10);write('║      ║');
  gotoxy(53,11);write('╙──────╜');
  gotoxy(7,12);textcolor(8);write('(для продажи, поставьте "-" перед кол-вом)');textcolor(7);
  gotoxy(7,14);write('Оплатить');textcolor(8);
  if buyprod>=0 then begin gotoxy(7,16);write('На кассе: ',buyprod,' продуктов (',buyprod*500,'$)'); end else begin gotoxy(7,16);write('На продажу: ',buyprod*(-1),' продуктов (',-buyprod*450,'$)'); end;
  gotoxy(7,18);textcolor(8);write('Состояние склада: '); write(prod,' продуктов');textcolor(7);
  gotoxy(37,21);write('Выйти');
  textcolor(white);
  case p of
  1 : begin gotoxy(5,10); write('>'); case readkey of
                                      'd' : begin if04: gotoxy(55,10);textcolor(7);read(buyprod); textcolor(white); gotoxy(5,10) end;
                                      's' : begin p:=2; goto lct1; end;
                                      'w' : begin p:=3; goto lct1; end;
                                      end; end;
  2 : begin gotoxy(5,14); write('>'); end;
  3 : begin gotoxy(35,21);write('>'); end;
  end;
  case readkey of
  'w' : p:=p-1;
  's' : p:=p+1;
  #13 : case p of
        2 : begin
              if buyprod=0 then
              begin
                gotoxy(17,14);textcolor(red);write('(вы ничего не выбрали)');
              end;
              if buyprod>0 then begin
              rect(23,3,47,22);
              for i:=24 to 46 do
              for j:=4 to 21 do
              begin
                gotoxy(i,j);write(' ');
              end;
              
              textcolor(7);gotoxy(25,5);write('Товарный чек:');
              textcolor(7);gotoxy(26,7);write('Продукты : ');textcolor(blue);write(buyprod);textcolor(7);write(' штук.');
              textcolor(7);gotoxy(26,9);write('Цена за 1 продукт: ');
              textcolor(lightgreen);gotoxy(26,11);write('500$');textcolor(7);
              textcolor(black);gotoxy(25,13);write('=====================');
              textcolor(7);gotoxy(25,15);write('Итоговая цена: ');textcolor(lightgreen);write(buyprod*500,'$');
              if buyprod*500>mymoney then begin
                textcolor(7);gotoxy(25,17);write('Оплатил: ');textcolor(lightgreen);write('Central Bank');
                textcolor(8);gotoxy(28,18);write('Ознакомьтесь с');
                gotoxy(27,19);write('правилами банка!');
                end;
              textcolor(red);gotoxy(25,20);write('Положить чек в карман');
              textcolor(red);gotoxy(27,21);write(' (Нажмите Enter)');
              sfood:=sfood+buyprod;
              if prod<buyprod then goto lct1;
              prod:=prod-buyprod;
              if prod<buyprod then goto lct1;
              if buyprod*500>mymoney then
              begin
                if buyprod*500>900000 then
                  begin
                    buyprod:=0;
                    goto lct1
                  end;
              money:=money-(500*buyprod);
              end else mymoney:=mymoney-(500*buyprod);
              buyprod:=0;
              case readkey of #13 :
              begin
              clrscr;graph;houses;setfin;policemoving;
              goto lct1;
              end;
              end;
              end
              
              else if buyprod<0 then begin
              rect(23,3,47,22);
              for i:=24 to 46 do
              for j:=4 to 21 do
              begin
                gotoxy(i,j);write(' ');
              end;
              textcolor(7);gotoxy(25,5);write('Продажа товаров:');
              textcolor(7);gotoxy(26,7);write('Продукты : ');textcolor(blue);write(buyprod*(-1));textcolor(7);write(' штук.');
              textcolor(7);gotoxy(26,9);write('Цена за 1 продукт: ');
              textcolor(lightgreen);gotoxy(26,11);write('450$');textcolor(7);
              textcolor(black);gotoxy(25,13);write('=====================');
              textcolor(7);gotoxy(25,15);write('Вы получаете: ');textcolor(lightgreen);write((buyprod*(-1))*450,'$');
              textcolor(red);gotoxy(25,20);write('Положить чек в карман');
              textcolor(red);gotoxy(27,21);write(' (Нажмите Enter)');
              if sfood<buyprod then goto lct1;
              sfood:=sfood-buyprod;
              prod:=prod-buyprod;
              mymoney:=mymoney-(450*buyprod);
              buyprod:=0;
              case readkey of #13 :
              begin
              clrscr;graph;houses;setfin;policemoving;
              goto lct1;
              end;
              end;
              end;
            end;
        3 : goto lexit;
        end;
  end;
  until (p=0) or (p=4);
  if p=0 then p:=3 else p:=1; goto lct1;
  lexit:
  clrscr;graph;houses;setfin;policemoving;
  if level>=2 then
  villager01;
  px:=12;py:=15;
  gotoxy(px,py);textcolor(white);
  write(player);
end;

procedure location02;//bank
label lct1, lexit, if01, if02, if03,if033, if022, if011;
var p,bankout,bankin, i,j:integer;
begin
  p:=1;
  lct1:
  repeat;
  gamewindow(3,22);
  textcolor(7);
  gotoxy(5,5);write('Вы зашли в Центральный Банк. Выберите действие:');
  gotoxy(7,8);write('Снять деньги со счета');
  gotoxy(7,10);write('Положить на счет');
  gotoxy(7,12);write('Выплатить задолжность');
  gotoxy(7,14);write('Условия выплаты кредита');
  textcolor(8);gotoxy(7,16);write('Счет в банке: ');if money>=0 then write(money,'$') else write('0$');textcolor(7);
  textcolor(8);gotoxy(7,18);write('Задолжность банку: ');if money<0 then write(money*(-1),'$') else write('0$');textcolor(7);
  gotoxy(37,20);write('Выйти');
  textcolor(white);
  case p of
  1 : begin gotoxy(5,8); write('>'); end;
  2 : begin gotoxy(5,10); write('>'); end;
  3 : begin gotoxy(5,12); write('>'); end;
  4 : begin gotoxy(5,14); write('>');end;
  5 : begin gotoxy(35,20);write('>'); end;
  end;
  case readkey of
  'w' : p:=p-1;
  's' : p:=p+1;
  #13 : case p of
        1 : begin
              if011:
              if money<0 then
              begin
                textcolor(red);
                gotoxy(29,8);write('(у вас имеется задолжность)');
                delay(500);
                goto lct1;
              end else if money=0 then begin
                textcolor(red);
                gotoxy(29,8);write('(на вашем счету 0$)');
                delay(500);
                goto lct1;
              end;
              rect(15,9,65,19);
              for i:=16 to 64 do
              for j:=10 to 18 do
              begin
                gotoxy(i,j);write(' ');
              end;
              gotoxy(20,11);write('Введите сумму которую желаете снять:');
              gotoxy(35,13);write('╓─────────╖');
              gotoxy(35,14);write('║         ║');
              gotoxy(35,15);write('╙─────────╜');
              gotoxy(35,17);write('Снять сумму');
              gotoxy(37,14);read(bankout);
              if bankout>money then goto if011;
              mymoney:=mymoney+bankout;
              money:=money-bankout;
              bankout:=0;
              gotoxy(33,17);write('>');
              if01:
              if readkey = #13 then
              begin
              rect(20,11,60,17);
              for i:=16 to 64 do
              for j:=10 to 18 do
              begin
                gotoxy(i,j);write(' ');
              end;
              gotoxy(22,13);write('    Операция успешно выполнена!');
              textcolor(red);
              gotoxy(22,15);write('    (Нажмите Enter для выхода)');
              if readkey = #13 then goto lct1 else goto if01;
              end else goto if01;
            end;
            
        2 : begin
              if022:
              if mymoney=0 then begin
              gotoxy(24,10);
              textcolor(red);
              write('(У вас недостаточно денег наличными)');
              delay(500);
              end;
              rect(15,9,65,19);
              for i:=16 to 64 do
              for j:=10 to 18 do
              begin
                gotoxy(i,j);write(' ');
              end;
              gotoxy(19,11);write('Введите сумму которую желаете положить:');
              gotoxy(35,13);write('╓─────────╖');
              gotoxy(35,14);write('║         ║');
              gotoxy(35,15);write('╙─────────╜');
              gotoxy(33,17);write('Положить сумму');
              gotoxy(37,14);read(bankin);
              if bankin>mymoney then goto if022;
              mymoney:=mymoney-bankin;
              money:=money+bankin;
              bankin:=0;
              gotoxy(31,17);write('>');
              if02:
              if readkey = #13 then
              begin
              rect(20,11,60,17);
              for i:=16 to 64 do
              for j:=10 to 18 do
              begin
                gotoxy(i,j);write(' ');
              end;
              gotoxy(22,13);write('    Деньги успешно внесены на счет!');
              textcolor(red);
              gotoxy(22,15);write('      (Нажмите Enter для выхода)');
              if readkey = #13 then goto lct1 else goto if02;
              end else goto if02;
            end;
            
        3 : begin
            if money<0 then begin
              if033:
              rect(15,9,65,19);
              for i:=16 to 64 do
              for j:=10 to 18 do
              begin
                gotoxy(i,j);write(' ');
              end;
              gotoxy(19,11);write('Введите сумму которую желаете положить:');
              gotoxy(35,13);write('╓─────────╖');
              gotoxy(35,14);write('║         ║');
              gotoxy(35,15);write('╙─────────╜');
              gotoxy(33,17);write('Положить сумму');
              gotoxy(37,14);read(bankin);
              if bankin>mymoney then goto if033;
              mymoney:=mymoney-bankin;
              money:=money+bankin;
              bankin:=0;
              gotoxy(31,17);write('>');
              if03:
              if readkey = #13 then
              begin
              rect(20,11,60,17);
              for i:=16 to 64 do
              for j:=10 to 18 do
              begin
                gotoxy(i,j);write(' ');
              end;
              gotoxy(22,13);write('     Платеж успешно выполнен');
              textcolor(red);
              gotoxy(22,15);write('    (Нажмите Enter для выхода)');
              if readkey = #13 then goto lct1 else goto if03;
              end else goto if03;
            end else begin
            textcolor(7);
            gotoxy(29,12);write('(у вас нет задолжностей)');
            delay(500);
            goto lct1;
            end;
            end;
        4 : begin
              gamewindow(3,22);
              textcolor(7);
              gotoxy(5,5);write('    Вас обеспечивает банк. В случае если у вас недостаточно денег на');
              gotoxy(5,7);write('покупку своих товаров, мы оплатим их. Максимальная сумма, которую');
              gotoxy(5,9);write('мы можем предоставить - '); textcolor(lightgreen); write('900 000 $');textcolor(7);
              gotoxy(5,11);write('    Условия использования наших услуг:');
              gotoxy(5,13);write('Вы обязаны выплачивать каждую неделю по '); textcolor(lightgreen); write('5 000 $ ');textcolor(7);
              textcolor(8);gotoxy(5,17);write('(Одна игровая неделя это 7 полученых зарплат)');textcolor(7);
              gotoxy(5,15);write('В случае не выплаты, мы вынуждены будем применить силу!');
              textcolor(7);
              gotoxy(5,19);write('Спасибо что пользуетесь Central Bank of Svetlovodsk');
              textcolor(8);
              gotoxy(22,21);write('    (Нажмите Enter для выхода)');textcolor(7);
              case readkey of #13:goto lct1; end;
            end;
        5 : goto lexit;
        end;
  end;
  until (p=0) or (p=6);
  if p=0 then p:=5 else p:=1; goto lct1;
  lexit:
  clrscr;graph;houses;setfin;policemoving;
  if level>=2 then
  villager01;
  px:=44;py:=11;
  gotoxy(px,py);textcolor(white);
  write(player);
end;

procedure location05;//station
label lct1,if04, lexit;
var p,i,j,price:integer;
begin
  price:=400;
  p:=1;
  buyprod:=0;
  lct1:
  repeat;
  gamewindow(4,20);
  textcolor(7);
  gotoxy(5,6);write('Вы зашли на продуктовый склад. Выберите действие:');
  gotoxy(7,10);write('Введите кол-во коробок с продуктами для покупки:');
  gotoxy(61,9);write('╓──────╖');
  gotoxy(61,10);write('║      ║  ');
  gotoxy(61,11);write('╙──────╜');
  gotoxy(7,12);write('Оплатить');textcolor(8);
  gotoxy(7,14);write('На кассе: ',buyprod/10,' коробок (',buyprod*price,'$)');
  gotoxy(7,16);write('Цена за 1 коробку: ',price*10,'$ (1 коробка = 10 прод.)');textcolor(7);
  gotoxy(37,18);write('Выйти');
  textcolor(white);
  case p of
  1 : begin gotoxy(5,10); write('>'); case readkey of
                                      'd' : begin if04: gotoxy(63,10);textcolor(7);read(buyprod); buyprod:=buyprod*10; textcolor(white); gotoxy(5,10); if buyprod<0 then goto if04; end;
                                      's' : begin p:=2; goto lct1; end;
                                      'w' : begin p:=3; goto lct1; end;
                                      end; end;
  2 : begin gotoxy(5,12); write('>'); end;
  3 : begin gotoxy(35,18);write('>'); end;
  end;
  case readkey of
  'w' : p:=p-1;
  's' : p:=p+1;
  #13 : case p of
        2 : begin
              if buyprod=0 then
              begin
                gotoxy(17,12);textcolor(red);write('(вы ничего не выбрали)'); goto lct1;
              end;
              rect(23,3,47,22);
              for i:=24 to 46 do
              for j:=4 to 21 do
              begin
                gotoxy(i,j);write(' ');
              end;
              textcolor(7);gotoxy(25,5);write('Товарный чек:');
              textcolor(7);gotoxy(26,7);write('Продукты : ');textcolor(blue);write(buyprod/10);textcolor(7);write(' коробок');
              textcolor(7);gotoxy(26,9);write('Цена за 1 коробку: ');
              textcolor(lightgreen);gotoxy(26,11);write(price*10,'$ ');textcolor(7);write('(',price,'$ за 1 пр)');textcolor(7);
              textcolor(black);gotoxy(25,13);write('=====================');
              textcolor(7);gotoxy(25,15);write('Итоговая цена: ');textcolor(lightgreen);write(buyprod*price,'$');
              if buyprod*price>mymoney then begin
                textcolor(7);gotoxy(25,17);write('Оплатил: ');textcolor(lightgreen);write('Central Bank');
                textcolor(8);gotoxy(28,18);write('Ознакомьтесь с');
                gotoxy(27,19);write('правилами банка!');
                end;
              textcolor(red);gotoxy(25,20);write('Положить чек в карман');
              textcolor(red);gotoxy(27,21);write(' (Нажмите Enter)');
              sfood:=sfood+buyprod;
              if buyprod*price>mymoney then
              begin
                if buyprod*price>900000 then
                  begin
                    buyprod:=0;
                    goto lct1;
                  end;
                money:=money-(buyprod*price);
              end else
              mymoney:=mymoney-(price*buyprod);
              buyprod:=0;
              case readkey of #13 :
              begin
              clrscr;graph;houses;setfin;policemoving;
              goto lct1;
              end;
              end;
            end;
        3 : goto lexit;
        end;
  end;
  until (p=0) or (p=4);
  if p=0 then p:=3 else p:=1; goto lct1;
  lexit:
  clrscr;graph;houses;setfin;policemoving;
  if level>=2 then
  villager01;
  px:=65;py:=16;
  gotoxy(px,py);textcolor(white);
  write(player);
end;

Procedure Commands;
label l1, passport,baggage, lexit, notcom, help, menu, quit, mapturn, coords,pol,vill,prc, cheatpanel,comturn, llevel,cheatmoney,lhealth,gsave,deletesaves,
changecolor;
var command:string; i,p:integer;
begin
p:=1;
if commander=false then goto lexit;

l1:
  chat:='';
  textcolor(7);
  gotoxy(52,23);write('/                           ');
  gotoxy(53,23);readln(command);
  
  case command of
  'passport' : goto passport;
  'baggage' : goto baggage;
  'menu' : goto lexit;
  'help' : goto help;
  'quit' : goto quit;
  'mapturn' : goto mapturn;
  'coord' : goto coords;
  'fuckthepolice' : goto pol;
  'villturn' : goto vill;
  'procturn' : goto prc;
  'cheatpanel' : goto cheatpanel;
  'commander off' : goto comturn;
  'level 1','level 2','level 3','level 4','level 5','level 6','level 7','level 8','level 9','level 10','level' : goto llevel;
  'money' : goto cheatmoney;
  'heal' : goto lhealth;
  'save' : goto gsave;
  'deletesaves' : goto deletesaves;
  'changecolor' : goto changecolor;
  '' : begin chat:='Вы не ввели команду!'; goto lexit; end;
  //новаю комманду сюда
  else goto notcom; end;
  
help:
  gamewindow(3,23);
  gotoxy(36,3);write('КОМАНДЫ');
  gotoxy(5,6);write('/help - помощь');
  gotoxy(5,7);write('/passport - открыть свой паспорт');
  gotoxy(5,8);write('/baggage - список предметов(вещей) с собой');
  gotoxy(5,9);write('/menu - выход в стартовое меню (Если команда не работает, нажмите М)');
  gotoxy(5,10);write('/save - сохранение игры');
  gotoxy(5,11);write('/quit - выйти из игры');
  gotoxy(5,12);write('/commander off - отключить командную строку');
  gotoxy(5,13);write('/deletesaves - удалить все сохранения');
  gotoxy(5,14);write('/changecolor - изменить время года (цвет фона)');
  textcolor(8);if cheatpan=true then begin gotoxy(5,21);write('/cheatpanel - открыть чит-панель');end; textcolor(7);
  closepage(4);
  goto lexit;
  
cheatpanel:
  if cheatpan=false then goto notcom;
  gamewindow(3,23);
  textcolor(black);
  gotoxy(35,3);write('ЧИТ-ПАНЕЛЬ');
  gotoxy(5,6);write('/mapturn - вкл/выкл прозрачную карту (для игрока)');
  gotoxy(5,7);write('/coord - вкл/выкл координаты');
  gotoxy(5,8);write('/fuckthepolice - вкл/выкл урон от копов');
  gotoxy(5,9);write('/villturn - вкл/выкл урон от жителей');
  gotoxy(5,10);write('/procturn - вкл/выкл налоги');
  gotoxy(5,11);write('/level [1..10]  - переключить игровой уровень');
  gotoxy(5,12);write('/money -  много денег');
  gotoxy(5,13);write('/heal -  вылечить себя');
  closepage(4);
  goto lexit;
  
changecolor:
  them:=them+1;
  if them=4 then them:=1;
  case them of
    1 : textbackground(green);
    2 : textbackground(cyan);
    3 : textbackground(brown);
  end;
  goto lexit;
  
deletesaves:
  for i:=1 to 4 do
  begin
    rewrite(savefile[i]);
    save.saving:=false;
    write(savefile[i],save);
    closefile(savefile[i]);
  end;
  goto lexit;
  
gsave:
        repeat;
        gamewindow(5,21);
        textcolor(black);
        gotoxy(20,7);write('Сохранение игры. Выберите свободный слот:');
        
        if savedgame(1)=true then begin textcolor(black); gotoxy(34,10);write(datesave(1)); end else begin textcolor(8); gotoxy(36,10);write('(пусто)'); end;
        if savedgame(2)=true then begin textcolor(black); gotoxy(34,12);write(datesave(2)); end else begin textcolor(8); gotoxy(36,12);write('(пусто)'); end;
        if savedgame(3)=true then begin textcolor(black); gotoxy(34,14);write(datesave(3)); end else begin textcolor(8); gotoxy(36,14);write('(пусто)'); end;
        if savedgame(4)=true then begin textcolor(black); gotoxy(34,16);write(datesave(4)); end else begin textcolor(8); gotoxy(36,16);write('(пусто)'); end;
        textcolor(black);
        gotoxy(32,19);write('Вернуться в игру');
        case p of
        1 : begin if savedgame(1)=true then begin textcolor(white); gotoxy(34,10);write(datesave(1)); end else begin textcolor(7); gotoxy(36,10);write('(пусто)'); end; end;
        2 : begin if savedgame(2)=true then begin textcolor(white); gotoxy(34,12);write(datesave(2)); end else begin textcolor(7); gotoxy(36,12);write('(пусто)'); end; end;
        3 : begin if savedgame(3)=true then begin textcolor(white); gotoxy(34,14);write(datesave(3)); end else begin textcolor(7); gotoxy(36,14);write('(пусто)'); end; end;
        4 : begin if savedgame(4)=true then begin textcolor(white); gotoxy(34,16);write(datesave(4)); end else begin textcolor(7); gotoxy(36,16);write('(пусто)'); end; end;
        5 : begin gotoxy(30,19);write('◄');gotoxy(49,19);write('►');end;
        end;
        case readkey of
        'w','W','ц','Ц' : p:=p-1;
        's','S','ы','Ы','і','І' : p:=p+1;
        #13 :
          case p of
          1 : if savedgame(1)=false then begin savegame(1); chat:='Игра сохранена'; goto Lexit; end else begin savegame(1); chat:='Сохранение перезаписано'; goto Lexit; end;
          2 : if savedgame(2)=false then begin savegame(2); chat:='Игра сохранена'; goto Lexit; end else begin savegame(2); chat:='Сохранение перезаписано'; goto Lexit; end;
          3 : if savedgame(3)=false then begin savegame(3); chat:='Игра сохранена'; goto Lexit; end else begin savegame(3); chat:='Сохранение перезаписано'; goto Lexit; end;
          4 : if savedgame(4)=false then begin savegame(4); chat:='Игра сохранена'; goto Lexit; end else begin savegame(4); chat:='Сохранение перезаписано'; goto Lexit; end;
          5 : goto Lexit;
          end;
        end;
        until (p=0) or (p=6);
        if p=0 then p:=5 else p:=1;
        goto gsave;
  goto lexit;


  
llevel: if cheatpan=false then goto notcom;
  if command='level' then chat:='/level [1..10]';
  case command of
  'level 1':lvl:=10;
  'level 2':lvl:=20;
  'level 3':lvl:=30;
  'level 4':lvl:=40;
  'level 5':lvl:=50;
  'level 6':lvl:=60;
  'level 7':lvl:=70;
  'level 8':lvl:=80;
  'level 9':lvl:=90;
  'level 10':lvl:=100;
  else goto notcom;
  end;
  goto lexit;
  
lhealth: if cheatpan=false then goto notcom; h:=10; goto lexit;

cheatmoney: if cheatpan=false then goto notcom; if chmon=false then begin money:=999999;mymoney:=999999; chmon:=true end else begin chmon:=false; money:=0; mymoney:=5000 end;goto lexit;

prc: if cheatpan=false then goto notcom; if procturn=false then begin procturn:=true;chat:='Выплата налогов вкл'; end else begin; procturn:=false;chat:='Выплата налогов выкл'; end; goto lexit;
  
vill: if cheatpan=false then goto notcom; if villturn=false then begin villturn:=true;chat:='Урон от жителей вкл'; end else begin; villturn:=false;chat:='Урон от жителей выкл'; end; goto lexit;
  
pol: if cheatpan=false then goto notcom; if policeturn=false then begin policeturn:=true;chat:='Коп в деле'; end else begin; policeturn:=false;chat:='Коп обезврежен'; end; goto lexit;
  
coords: if cheatpan=false then goto notcom; if coord=false then begin coord:=true;chat:='Координаты включены'; end else begin; coord:=false;chat:='Координаты выключены'; end; goto lexit;
  
mapturn: if cheatpan=false then goto notcom; if cheat=false then begin cheat:=true; chat:='Прозрачная карта вкл'; end else begin cheat:=false; chat:='Прозрачная карта выкл'; end; goto lexit;

comturn: commander:=false; chat:='Commander turn off'; goto lexit;
  
quit:
  m:=2;
  goto lexit;
  
menu:
  m:=1;
  goto lexit;
  
passport:
  gamewindow(3,23);
  rect(13,6,27,16);
  for i:=4 to 22 do begin
    gotoxy(40,i);write('|'); end;
  gotoxy(14,7);write('     ___     ');
  gotoxy(14,8);write('   //|||\\   ');
  gotoxy(14,9);write('  // _ _ \\  ');
 gotoxy(14,10);write('  |│ 0 0 │|  ');
 gotoxy(14,11);write('  |│  >  │|  ');
 gotoxy(14,12);write('    \_~_/    ');
 gotoxy(14,13);write('╒═══/\ /\═══╕');
 gotoxy(14,14);write('│   \°|°/   │');
 gotoxy(14,15);write('│  │ \|/ │  │');
  
  gotoxy(5,17);write('           Имя: Петр');
  gotoxy(5,19);write('       Фамилия: Кобзаренко');
  gotoxy(5,21);write('      Отчество: Иванович');
  
  gotoxy(43,5);write('Дополнительная информация:');
  gotoxy(43,7);write('Мать: ');
  gotoxy(45,8);write('Кобзаренко Валентина Сергеевна');
  gotoxy(43,10);write('Отец: ');
  gotoxy(45,11);write('Кобзаренко Иван Николаевич');
  gotoxy(43,13);write('Прописка:');
  gotoxy(45,14);write('Ул. Тараса Шевченка 3');
  gotoxy(45,15);write('г.Светловодск, Кировоградская обл');
  gotoxy(43,17);write('Дата рождения:');
  gotoxy(45,18);write('25 марта 1983 года');
  closepage(4);
  goto lexit;
  
baggage:
  gamewindow(6,15);
  gotoxy(5,9);write('Предметы с собой:');
  gotoxy(7,11);write('Продуктов: ',sfood,' прод.');
  gotoxy(7,13);write('Денег в кошельке: ',mymoney,' $');
  closepage(7);
  goto lexit;

notcom:
  chat:='Неизвестная комманда';
  goto lexit;
  
  lexit:
  command:='';
  clrscr;graph;houses;setfin;policemoving;coordin;
  if level>=2 then villager01; if level>=4 then setproc;
  textcolor(white);gotoxy(px,py);write(player);
end;

begin
//parametrs
HideCursor;
commander:=false;
coord:=false;
cheat:=false;
policeturn:=true;
villturn:=true;
procturn:=true;
cheatpan:=false;
chmon:=false;
preview:=false;
them:=1;textbackground(green);
pincod:=713091656;

//файл
assignfile(savefile[1],'sf01.svng');
assignfile(savefile[2],'sf02.svng');
assignfile(savefile[3],'sf03.svng');
assignfile(savefile[4],'sf04.svng');

punktmenu:=1;
Lmenu:
  m:=0;
  repeat
  clrscr;
  textcolor(black);
  rect(8,7-2,72,20);
  gotoxy(21,4);write('┌───────────────────────────────────┐');
  gotoxy(21,6);write('└───────────────────────────────────┘');
  gotoxy(21,5);write('╡Добро пожаловать в игру "');textcolor(red);write('Чиновник');textcolor(black);write('"!╞');
  gotoxy(29,10-2);write('   Новая игра');
  gotoxy(27,12-2);write('   Загрузить игру');
  gotoxy(30,14-2);write('  Инструкция');
  gotoxy(30,16-2);write('  Настройки');
  gotoxy(31,18-2);write('  Про игру');
  gotoxy(32,20-2);write('  Выйти');
  
  case punktmenu of
  1 : begin gotoxy(30,10-2);write('◄');gotoxy(43,10-2);write('►'); end;
  2 : begin gotoxy(28,12-2);write('◄');gotoxy(45,12-2);write('►'); end;
  3 : begin gotoxy(30,14-2);write('◄');gotoxy(43,14-2);write('►'); end;
  4 : begin gotoxy(30,16-2);write('◄');gotoxy(42,16-2);write('►'); end;
  5 : begin gotoxy(31,18-2);write('◄');gotoxy(42,18-2);write('►'); end;
  6 : begin gotoxy(32,20-2);write('◄');gotoxy(40,20-2);write('►'); end;
  end;
         
  case readkey of
  'w','W','ц','Ц' : punktmenu:=punktmenu-1;
  's','S','ы','Ы','і','І' : punktmenu:=punktmenu+1;
  #13 :
  case punktmenu of
  1 : goto Lstart;
  2 : begin punktmenu:=1; goto Lload; end;
  3 : goto Linstr;
  4 : begin punktmenu:=2; goto Lsett; end;
  5 : goto Labout;
  6 : goto Lfinish;
  end;
  else
    begin
      gotoxy(1,24);
      textcolor(8);
      writeln('(Используйте W / S перемещения. Enter - для выбора)');
      delay(1000);
      goto Lmenu;
    end;
  end;
  until (punktmenu=0) or (punktmenu = 7);
  if punktmenu=0 then punktmenu:=6 else punktmenu:=1;
  goto Lmenu;
  
        begin
        Lload:
        repeat;
        clrscr;
        textcolor(black);
        rect(15,7,65,21);
        gotoxy(32,6);write('┌──────────────┐');
        gotoxy(32,8);write('└──────────────┘');
        gotoxy(32,7);write('╡ЗАГРУЗИТЬ ИГРУ╞');
        
        if savedgame(1)=true then begin textcolor(black); gotoxy(34,10);write(datesave(1)); end else begin textcolor(8); gotoxy(36,10);write('(пусто)'); end;
        if savedgame(2)=true then begin textcolor(black); gotoxy(34,12);write(datesave(2)); end else begin textcolor(8); gotoxy(36,12);write('(пусто)'); end;
        if savedgame(3)=true then begin textcolor(black); gotoxy(34,14);write(datesave(3)); end else begin textcolor(8); gotoxy(36,14);write('(пусто)'); end;
        if savedgame(4)=true then begin textcolor(black); gotoxy(34,16);write(datesave(4)); end else begin textcolor(8); gotoxy(36,16);write('(пусто)'); end;
        textcolor(black);
        gotoxy(37,19);write('Выйти');
        case punktmenu of
        1 : begin if savedgame(1)=true then begin textcolor(white); gotoxy(34,10);write(datesave(1)); end else begin textcolor(7); gotoxy(36,10);write('(пусто)'); end; end;
        2 : begin if savedgame(2)=true then begin textcolor(white); gotoxy(34,12);write(datesave(2)); end else begin textcolor(7); gotoxy(36,12);write('(пусто)'); end; end;
        3 : begin if savedgame(3)=true then begin textcolor(white); gotoxy(34,14);write(datesave(3)); end else begin textcolor(7); gotoxy(36,14);write('(пусто)'); end; end;
        4 : begin if savedgame(4)=true then begin textcolor(white); gotoxy(34,16);write(datesave(4)); end else begin textcolor(7); gotoxy(36,16);write('(пусто)'); end; end;
        5 : begin gotoxy(35,19);write('◄');gotoxy(43,19);write('►');end;
        end;
        case readkey of
        'w','W','ц','Ц' : punktmenu:=punktmenu-1;
        's','S','ы','Ы','і','І' : punktmenu:=punktmenu+1;
        #13 :
          case punktmenu of
          1 : if savedgame(1)=true then begin loadgame(1); preview:=true; goto lstartsaved; end;
          2 : if savedgame(2)=true then begin loadgame(2); preview:=true; goto lstartsaved; end;
          3 : if savedgame(3)=true then begin loadgame(3); preview:=true; goto lstartsaved; end;
          4 : if savedgame(4)=true then begin loadgame(4); preview:=true; goto lstartsaved; end;
          5 : begin punktmenu:=2;goto Lmenu;end;
          end;
        end;
        until (punktmenu=0) or (punktmenu=6);
        if punktmenu=0 then punktmenu:=5 else punktmenu:=1;
        goto Lload;
        end;
      
        begin
          Linstr:
          clrscr;
          textcolor(black);
          rect(2,5,79,24-2);
          gotoxy(33,4);write('┌──────────┐');
          gotoxy(33,6);write('└──────────┘');
          gotoxy(35-2,7-2);writeln('╡ИНСТРУКЦИЯ╞');
          gotoxy(7,10-2);write('Вы играете роль жадного чиновника который бессовестно крадет деньги.');
          gotoxy(7,12-2);write('Вас постоянно будет преследывать сотрудник полиции Сержант Петренко');
          gotoxy(7,14-2);write('Клавиши управления: ');textcolor(white);write('W A S D ');textcolor(black);write('Выйти в меню: ');textcolor(white);write('M');textcolor(black);write(' (в игре) Обозначения:');
          gotoxy(7,16-2);textcolor(white);write('☺');textcolor(black);write(' - Вы. ');textcolor(blue);write('☻');textcolor(black);write(' -  сержантПетренко. ');textcolor(red);write('$');textcolor(black);write(' - цель. ♀ - злой житель.');textcolor(magenta);write(' %');textcolor(black);write(' - налоги.');
          gotoxy(7,18-2);textcolor(red);write('Не забыывайте! Раскладка всегда должна быть на ENG. А Capslock - выкл.');textcolor(8);
          gotoxy(7,20-2);write('В местах где нужно вводить кол-во (магазин/склад), для ввода жмите "D"');textcolor(black);
          gotoxy(31,22-2);writeln('◄ Выйти в меню ►');
          if readkey = #13 then goto Lmenu else
          begin
            gotoxy(1,24);
            textcolor(8);
            writeln('(Нажмите Enter - для выхода)');
            delay(1000);
            goto Linstr;
          end;      
        end;
      
      
        begin
          Labout:
          clrscr;
          textcolor(black);
          rect(3,7,77,21);
          gotoxy(33,6);write('┌────────┐');
          gotoxy(33,8);write('└────────┘');
          gotoxy(35-2,7);write('╡ПРО ИГРУ╞');
          gotoxy(6,10);write('Игра написана на языке Pascal. В среде Pascal ABC.');
          gotoxy(6,12);write('Используемые модули: ');textcolor(red);write('CRT, System');textcolor(black);write('. Версия игры: ');textcolor(8);write('0.1 alpha');textcolor(black);
          gotoxy(6,14);write('Для получения кода игры, обратитесь по адресу: ');textcolor(blue);write('braginsuperman@inbox.ru');textcolor(black);
          gotoxy(6,16);write('Если есть идеи/предложения по поводу улучшения игры, пишите ↑');
          textcolor(8);gotoxy(6,18);write('Будьте добры, отправляйте письма с пометкой "Чиновник". Буду рад :)');textcolor(black);
          gotoxy(31,20);writeln('◄ Выйти в меню ►');
          if readkey = #13 then goto Lmenu else
          begin
          gotoxy(1,24);
          textcolor(8);
          writeln('(Нажмите Enter - для выхода)');
          delay(1000);
          goto Labout;
          end;
        end;
        
        
        begin
          Lsett:
          repeat
          clrscr;
          textcolor(black);
          rect(3,7,77,21);
          gotoxy(33,6);write('┌─────────┐');
          gotoxy(33,8);write('└─────────┘');
          gotoxy(35-2,7);write('╡НАСТРОЙКИ╞');
          gotoxy(6,10);write('');
          gotoxy(6,12);write('Включить ввод комманд:   ');textcolor(blue);write(commander,'    ');textcolor(black);if commander=true then write('(/help для помощи)');
          gotoxy(6,14);write('Выбрать цветовую тему:    ');textcolor(blue);write(them);textcolor(black); case them of
                                                                                                                  1:begin gotoxy(36,14); write('(лето)'); end;
                                                                                                                  2:begin gotoxy(36,14); write('(зима)'); end;
                                                                                                                  3:begin gotoxy(36,14); write('(осень)'); end; end;
          gotoxy(33,20);writeln('Выйти в меню');
          
          case punktmenu of
          2 : begin gotoxy(29,12); write('◄');gotoxy(37,12);write('►'); end;
          3 : begin gotoxy(30,14); write('◄');gotoxy(34,14);write('►'); end;
          4 : begin gotoxy(31,20); write('◄');gotoxy(46,20);write('►'); end;
          end;
          
          case readkey of
          'w','W','ц','Ц' : punktmenu:=punktmenu-1;
          's','S','ы','Ы','і','І' : punktmenu:=punktmenu+1;
          #13 : case punktmenu of
                  2 : if commander=false then commander:=true else commander:=false;
                  3 : begin if them=3 then them:=1 else them:=them+1;
                      case them of
                      1 : textbackground(green);
                      2 : textbackground(cyan);
                      3 : textbackground(brown);
                      end; end;
                  4 : begin punktmenu:=4; goto Lmenu; end;
                end;
          else
            begin
              gotoxy(1,24);
              textcolor(7);
              writeln('(Используйте W / S перемещения. Enter - для выбора)');
              delay(1000);
              goto Lsett;
             end;
          end;
          until (punktmenu=1) or (punktmenu=5);
          if punktmenu=1 then punktmenu:=4 else punktmenu:=2;
          goto Lsett;
        end;

    
Lstart:
  lvl:=0;
  clrscr;
  if preview=false then begin
  gotoxy(5,20);write('г.Светловодск, Кировоградская обл.');
  gotoxy(5,22);write('Время: 13:00');
  delay(2000);
  preview:=true;
  end;
  clrscr;
  steplake:=0;

  px:=28;py:=18;
  money:=0;mymoney:=5000;
   h:=10;
  level:=1;
  preview:=false;gfood:=0;sfood:=1;
  prod:=5983; chat:='';
  
  step:=0;
  lx:=74; ly:=10;

  changefin;
  stepdollar:=0;

  stepvill:=0;
  vx:=2; vy:=10;

  stepproc:=0;
  stepproccolor:=0;
  changeproc;
  
  lvl2:=true;lvl4:=true;lvl10:=true;
  
  msg1:=false;graph;
  
  LStartSaved:
  villager:='♀';finish:='$';player:='☺';
  proc:='%';police:='☻';health:='♥';
  case them of
    1 : textbackground(green);
    2 : textbackground(cyan);
    3 : textbackground(brown);
  end;
  clrscr;
  graph;houses;
  textcolor(white);
  gotoxy(px,py);
  write(player);
  textcolor(blue);
  gotoxy(lx,ly);
  write(police);
  textcolor(lightred);
  gotoxy(fx,fy);
  write(finish);
  if level>=2 then villager01; if level>=4 then setproc;
  
  repeat
    case readkey of
    's','S','ы','Ы','і','І' : MPDown;
    'w','W','ц','Ц' : MPUp;
    'a','A','ф','Ф' : MPLeft;
    'd','D','в','В' : MPRight;
    'm','M','ь','Ь' : goto Lmenu;
    '0' : goto pin;
    '/' : Commands;
    end;
    
    //подключение командной строки
    if m=1000 then begin
    pin:
    if readkey='7' then
      if readkey='1' then
        if readkey='3' then
          if readkey='0' then
            if readkey='9' then
              if readkey='1' then
                if readkey='6' then
                  if readkey='5' then
                    if readkey='6' then
                      if (cheatpan=false) and (commander=true) then begin chat:='Cheatpanel turn on :)'; cheatpan:=true; end else begin chat:='Cheatpanel turn off :('; cheatpan:=false; end;
                      clrscr;graph;houses;setfin;policemoving;coordin;
                      if level>=2 then villager01; if level>=4 then setproc;
                      textcolor(white);gotoxy(px,py);write(player);
    end;
    
    case m of
    1 : begin m:=1; goto Lmenu; end;
    2 : begin m:=2; goto Lfinish; end;
    
    end;
    
    Llevel:
    
    if location=1 then location01;
    if location=2 then location02;
    if location=4 then location04;
    if location=5 then location05;
    
    if (money<0) and (msg1=false) then begin msg1:=true; chat:='У вас задолжность в банке!' end;
    if (px=vx) and (py=vy) and (level>=2) and (villturn=true) then begin chat:='Вас ранил житель (-2xp)'; h:=h-2; vx:=74; vy:=10; end;
    if (px=rx) and (py=ry) and (level>=4) and (procturn=true) then begin h:=h-1; changeproc; Money:=money-PABCSystem.random(1000); chat:='Вы заплатили налоги!'; end;
    if stepproc >= 10 then begin changeproc; stepproc:=0; end;
    
    if (level >= 2) and (lvl2=true) then begin // переход на 2-й уровень
    gamewindow(7,17);
    gotoxy(5,11);write('Вы переходите на 2-й уровень! Будьте осторожны - появляются злые жители!');
    gotoxy(5,13);write('Они ходят со своими вилами и могут вас серьёзно поранить! Остерегайтесь!');
    gotoxy(5,15);write('Для перехода на 3-й уровень, соберите 30 "зарплат" (');textcolor(red);write('$');textcolor(black);write(')');
    lvl2:=false;
    closepage(8);
    end;
    
    if (level >= 4) and (lvl4=true) then begin // переход на 4-й уровень
    gamewindow(7,22);
    gotoxy(5,11);write('Поздравляем! Вы перешли на 4-й уровень! Вы собрали 40 зарплат');
    gotoxy(5,13);write('Теперь на карте будут появляться налоги (');textcolor(magenta);write('%');textcolor(black); write('),в случайном месте.');
    gotoxy(5,15);write('Наткнувшись на них, вы потеряете часть своих денег и немного здоровья. ');textcolor(8);
    gotoxy(5,19);write('Введите комбинацию цифр: 0 713091656 для подключения чит-панели');
    gotoxy(5,20);write('(чит-коды вводятся во время игрового процесса)');textcolor(black);
    gotoxy(5,17);write('Для перехода на 5-й уровень, соберите 50 зарплат (');textcolor(red);write('$');textcolor(black);write(')');
    lvl4:=false;
    closepage(8);
    end;
    
    if (level >= 10) and (lvl10=true) then begin // переход на 10-й уровень
    gamewindow(7,17);
    gotoxy(5,11);write('Поздравляем! Вы перешли на 10-й уровень! Дальше вы играете на рекорд.');
    gotoxy(5,13);write('Т.к. игра находится в альфа разработке, мы предлагаем вам отправлять ваши');
    gotoxy(5,15);write('идеи на мой E-mail. Спасибо за уделенное время, приятной вам игры :)');
    lvl10:=false;
    closepage(8);
    //goto Lmenu;
    end;
    
    if (px = lx) and (py = ly) and (policeturn=true) then
    begin
      gamewindow(10,16);
      money:=0;mymoney:=0;
      graph;
      gotoxy(33,12);
      writeln('Вас повязали!');
      gotoxy(20,14);
      writeln('Вас нашла полиция и люстрировала все ваше имущество.');
      h:=h-4; chat:='Петренко снял вам -4xp'; money:=0; mymoney:=0;lx:=74; ly:=10;px:=28;py:=18;
      closepage(11);
    end;
    
    if h=0 then begin
      gamewindow(10,16);
      gotoxy(25,12);writeln('Вы проиграли! Вы потеряли сознание.');
      gotoxy(15,14);write('Вас "пытались" вылечить в больнице, но не безуспешно :(');
      closepage(11);
      goto Lmenu;
    end;
    
  until (px = fx) and (py = fy);
  changefin;
  lvl:=lvl+1;
  money:=money+PABCSystem.random(500)+501;
  
  case lvl of
  1..10000 : level:=lvl div 10;
  end;
  
  goto Llevel;
  
    Lfinish:
    
end.