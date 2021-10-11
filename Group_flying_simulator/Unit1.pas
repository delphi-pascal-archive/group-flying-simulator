unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Math;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

type
 TBoide=record
     x,y: integer;
     vx,vy: integer;
    end;

const
 maxboides=500;
 Cursor_attract=300;
 cohesion_attract=100;
 Align_attract=8;
 Separation_repuls=100;
 Vitesse_Max=200;
 Distance_Max=200*200;
 Angle_Vision=90; // 180° total

var
  Form1: TForm1;
  boides:array[0..maxboides] of TBoide;
  buffer:tbitmap;
  palette:array[0..360] of longint;

implementation

{$R *.dfm}

// vérifie si b1 vois b2
function AngleDeVisionOk(b1,b2:tboide):boolean;
var
 angle: extended;
begin
 b1.x:=b1.x-b2.x;
 b1.y:=b1.y-b2.y;
 angle:=abs(arctan2(b1.x,b1.y)*180/pi);
 result:=(b1.x*b1.x+b1.y*b1.y<Distance_Max) and (angle<=Angle_Vision);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 pt: TPoint;
 i,j,c: integer;
 bx,by,bvx,bvy: integer;
 cohesion,align,separation,center: TPoint;
begin
 // position de la souris
 GetCursorPos(pt);

 // pour chaque boïde
 for i:=0 to maxboides do
  begin
   c:=0;
   cohesion.X:=0;
   cohesion.y:=0;
   align.x:=0;
   align.y:=0;
   separation.x:=0;
   separation.y:=0;

   // ils suivent le comportement des voisins
   // on parcours toute la liste
   for j:=0 to maxboides do
    // si le boides J est dans le champs de vision de I
    // càd : pas trop loin et devant lui
    if (i<>j) and AngleDeVisionOk(boides[i],boides[j]) then
     begin
      // alors on traite les 3 forces qui régissent de comportement du groupe
      c:=c+1;
      // il se rapproche du centre de masse de ses voisins
      cohesion.X:=cohesion.x+boides[j].x;
      cohesion.y:=cohesion.Y+boides[j].y;
      // il aligne sa direction sur celle des autres
      align.x:=align.x+boides[j].vx;
      align.y:=align.y+boides[j].vy;
      // mais il s'éloigne si ils sont trop nombreux
      separation.x:=separation.x-(boides[j].x-boides[i].x);
      separation.y:=separation.y-(boides[j].y-boides[i].y);
     end;

   // si il y a des voisins, on fini les calculs des moyennes
   if c<>0 then
    begin
     cohesion.x:=(cohesion.x div c-boides[i].x) div cohesion_attract;
     cohesion.y:=(cohesion.y div c-boides[i].y) div cohesion_attract;
     align.x:=(align.x div c-boides[i].vx) div Align_attract;
     align.y:=(align.y div c-boides[i].vy) div Align_attract;
     separation.x:=separation.x div Separation_repuls;
     separation.y:=separation.y div Separation_repuls;
    end;


   // la dernière force les poussent tous vers la souris
   center.x:=(pt.x*10-boides[i].x) div Cursor_attract;
   center.y:=(pt.y*10-boides[i].y) div Cursor_attract;

   // on combine toutes les infos pour avoir la nouvelle vitesse
   boides[i].vx:=boides[i].vx+cohesion.x+align.x+separation.x+center.x;
   boides[i].vy:=boides[i].vy+cohesion.y+align.y+separation.y+center.y;

   // attention, si il va trop vite, on le freine
   c:=round(sqrt(boides[i].vx*boides[i].vx+boides[i].vy*boides[i].vy));
   if c>Vitesse_Max then
    begin
     boides[i].vx:=boides[i].vx*Vitesse_Max div c;
     boides[i].vy:=boides[i].vy*Vitesse_Max div c;
    end;

   // on le déplace en fonction de sa vitesse
   boides[i].x:=boides[i].x+boides[i].vx;
   boides[i].y:=boides[i].y+boides[i].vy;

   //rebond sur les bords
   //if boides[i].x>clientwidth then boides[i].vx:=-boides[i].vx;
   //if boides[i].x<0 then boides[i].vx:=-boides[i].vx;
   //if boides[i].y>clientheight then boides[i].vy:=-boides[i].vy;
   //if boides[i].y<0 then boides[i].vy:=-boides[i].vy;

   // univers fermé
   //if boides[i].x>clientwidth then boides[i].x:=boides[i].x-clientwidth;
   //if boides[i].x<0 then boides[i].x:=boides[i].x+clientwidth;
   //if boides[i].y>clientheight then boides[i].y:=boides[i].y-clientheight;
   //if boides[i].y<0 then boides[i].y:=boides[i].y+clientheight;
  end;


 // on efface le buffer et on affiche les boïdes
 buffer.canvas.Brush.color:=clblack;
 buffer.canvas.FillRect(clientrect);
 for i:=0 to maxboides do
  begin
   bx:=boides[i].x div 10;
   by:=boides[i].y div 10;
   bvx:=boides[i].vx div 10;
   bvy:=boides[i].vy div 10;
   //calcul de la direction de déplacement pour la couleur
   c:=round(arctan2(bvx,bvy)*180/PI)+180;
   buffer.canvas.pen.color:=palette[c];
   // dessine un très de la longueur de la vitesse
   buffer.canvas.MoveTo(bx,by);
   buffer.canvas.lineto(bx+bvx,by+bvy);
  end;

 // affiche le résultat
 canvas.Draw(0,0,buffer);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
 i: integer;
begin
 randomize;
 // on dessinera dans buffer
 buffer:=tbitmap.Create;
 buffer.Width:=clientwidth;
 buffer.Height:=clientheight;
 // on initialise une vitesse et une place aléatoire pour le départ
 for i:=0 to maxboides do
  with boides[i] do
   begin
    x:=random(clientwidth*10);
    y:=random(clientheight*10);
    vx:=random(200)-100;
    vy:=random(200)-100;
   end;
 // on crée la palette de oculeur pour l'affichage
 for i:=0 to 360 do
   Case (i div 60) of
      0,6:palette[i]:=rgb(255,(i Mod 60)*255 div 60,0);
      1: palette[i]:=rgb(255-(i Mod 60)*255 div 60,255,0);
      2: palette[i]:=rgb(0,255,(i Mod 60)*255 div 60);
      3: palette[i]:=rgb(0,255-(i Mod 60)*255 div 60,255);
      4: palette[i]:=rgb((i Mod 60)*255 div 60,0,255);
      5: palette[i]:=rgb(255,0,255-(i Mod 60)*255 div 60);
   end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
 buffer.Width:=clientwidth;
 buffer.Height:=clientheight;
end;

procedure TForm1.FormClick(Sender: TObject);
begin
 timer1.Free;
 buffer.Free;
 close;
end;

end.