%13/05/2013 by Nora IZRI
%PRiSM Laboratory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%  Edit History  %%%%
    %14/05/2013 modified (structure de donnees+affectation des RBs/cell)
    %modified 15/05/2013 exploration step
    %16/05/2013 modified (recuperer les RB en commun pr chaque cellule i et
    %c 6 cellules voisines ==>  RB_common
    %modified 30/05/2013 ==> calcul du SINR pr les users par rapports aux
    %users voisins uilisant la meme RB
    %modified 03/06/2013 ==> correction de la notion de temps; variante 1
    %du model==> tt les users des differentes cellules emettent a la meme puissance
    %modfied 05/06/2013 ==> ajustement du temps, rajout de la fct de
    %recompense globale au sein d une cellule sur un RB et la fct global de
    %la cellule
    
    
    %%%%%%%%%%%%%%%%%%%%         URGENT          %%%%%%%%%%%%%%%%%%%
    %modified 02/07/2013 ==> correction de kelk erreurs de compilation
    %suite � l introduction de la notion de temps ; j ai introduit une
    %variable ta=1, pr r�soudre le problm mais par la suite il faudra
    %remettre la variable t (temps) � la place de ta; et faire biensur les
    %modifs qu il faut dans tt le code par rapport � la mise � jour des
    %RB utilis�s etc
    %==> il faut �galement r�soudre le problm de la fct de r�compense elle
    %n est pas au bon endroit
    
    %03/07/2013
    %d�placement du block concernant le calcul de la fct r�compense
    %d�but de la fct modifRB dans un fichier ind�pendent permettant de
    %s�lection un autre RB que celui utilis� actuellement
    
    %04/07/2013
    
    %la conf des puissances d emission est faite lors de l etape init ==>
    %il faudra peut �tre pr�voir de faire des modifs par rapport � c
    %puissances lors des mises � jours des RBs utilis�s au fur et � mesure
    
    
    
    %05/07/2013
    %les mises � jour de : 
    %lorsque l on choisi un autre RB + verif de la convergence (avec des
    %multiples de 200 ms en relation avec les msg RNTP
    
    
     %10/07/2013: 
          %int�gration du calcul du d�bit pr chaque RB ayant d�j� eu un
          %calcul du SINR 
        %sauvegarde dans deux fichiers le SINR et le d�bit de chaque RB en
        %conflit
        %placer juste une variable cste =2 pr l utiliser lors de l'arriv�e
        %d'un msg CQI avec des intervalles de 2 ms
        
        
     
    %11/07/2013
    %voir pr le noise est ce que l on utilise la puissance max ou bien celle tir� al�atoirement
         
    
   %15/07/2013
   %rajout de la notion de charge,
   %il reste kelk fois ou le SINR est > 1 ???
   
   
   %26/07/2013
   %pr que la difference soit >0 pr rentrer dans l algo d allocation, il ne
   %fallait pas mettre le gain et le gaintotal � 0
  
   
   %il faut voir est ce que lorsque l'on change de RB dans une cellule les
   %equations de la fct de r�compenses ainsi que celle du calcul de la diff
   %sont li�s avec l'ancien rb jusque l'on n a pas de valeurs pr ces fcts �
   %t-1
  
  %voir si c utile de refaire le calcul des RB_common et de la  sommeDistUsersNew     
                    %513==>527
                    
    %29/07/2013
    %t_RNTP  ==> j ai mis sa valeur a 10 au lieu de 200 juste pr tester par
    %rapport � la convergence de l algo en mettant la duree de simul � 50
    
    
    %06/08/2013
    %calcul de la fct gain globale de chaque cellule 
    %on d�termine la stabilit� si pour chaque cellule, la fct de gain
    %globale n'a pas chang� entre une it�ration et une autre
    
    %07/08/2013
    %il faut utiliser ca pr la partie coordonn�es des RB et users pr �viter
    %de tomber sur les coordonn�es des eNBs
    
    %1-  Si tu as envi d'enlever toutes les occurrence tu fais
    %setdiff(A,elt,'stable');

    %2- Si tu as envi d'enlever d'une seule occurrence, � savoir la premi�re qui appara�t dans le tableau  tu fais
    %a) q=find(A==elt);
    %b) A=[A(1:q(1)-1), A(q(1)+1:length(A))].

    %==> rajout de la variable "varianteStab" pr d�finir plusieurs m�thodes
    %concernant les conditions de stabilit�/convergence de l algo

    
    %20/08
    %==>calcul du debit moyen ET du nbre d'intef�rences moyenne par cellule
    %==> pour pouvoir tracer en fct du nbre de RB dans chaque cellule c
    %deux indices de perf
    
    %r�cup�rer la fct de r�compense globale par cellule pr tracer une
    %courbe en fct des it�rations avec des pas correspondant � l'arriv�e
    %d'un msg CQI
    
    
    %27/08
    %cell{q,ta}.nbrRBmodif rajout de cette variable pr permettre de tracer
    %pr chaque cellule q le nbre de modif de RB qui a du se faire durant la simul
    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
%close all;
clf %clear figure
varianteStab=1; %1: usage de la fct de gain globale pr chaque cellule; 2 : usage du SINR pr chaque RB de chaque cellule
varianteALGO=1; %1: tous les users utilisent la meme puissance de transmission dans tout le reseau; 2: les users d'une meme cellule sont sur la meme puisssance; 3: la puissance de transmission d un user est en fct de sa distance par rapport au eNB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 10;     %Number of RBs/cell
R = 15;     %Radius of Hexagon==> rayon
charge=0.5;
M = N*charge;     %Number of users => au max nbre user= nbre de RBs
V=7; %number of cells => pr le moment nous considerons uniquement 7 cellules
rayonPorte_eNB=10; %km
W=180000; %hz bande passante ==> c 180khz pr 1 RB %10/07/2013
%PuissBruit=2; %puissance du bruit, je l avais rajout� en pensant utilis�
%la formule de shannon directement mais je remplace ca par le SINR
t=1; %indice de temps
T_max=300; %temps de simul
dur=10; %pr la duree max de communication
t_RNTP=100;%200; %a chaque 200 ms un msg RNTP est envoye sur le lien X2
dur1RNTP=t_RNTP;
t_CQI=2; % 2ms mais max c 3 ms 10/07/2013
cpt_CQI=0;
tConverg=1; % compteur pr calculer le temps de convergence de l algo, il fait que ca soit un multiple de t_RNTP
cpt_RNTP=0; %compteur du msg RNTP
TmaxConvergence=1000; %il ne faudrait pas que l'algo converge avec un temps > � 1000 ms; condition:  t_RNTP <= tConverg <= TmaxConvergence

epsilon=10^(-10);
alpha=2;
PuisMax= 50;
portion=0.8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PuisSeuil = PuisMax*portion; %c juste un exemple
PuisUsedAll=randi([1, PuisSeuil], 1, 1); %PuisMax
noise=10^(-alpha)*PuisMax; %noise variance  on peut egalement le prendre directement comme etant 10^(-alpha)

beta=4; %valeur essentiel pour le calcul du SINR d'un user

PuisUsed=zeros(V, N);
debitMoyen=zeros(V); %20/08
nbreInterfMoyen=zeros(V); %20/08
 %choisir une puissance que tous les users vont avoir pr la premiere variante de l algo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tabRB=zeros(V, N);
matriceRNTP=zeros(V, N);%cette matrice va contenir des 1 ou des 0 ==> 1 : le RB est utilise avec une puissance max ==> pas bon car il va d�ranger
%apprentissageRB=zeros(V, N);
%qValue=zeros(V, N);
%gain=zeros(V, N);
%gainTotal=zeros(V, N); %fct gain total au sein de chaque cellule, c la fct a maximiser sur un RB
gainGlobal=zeros(V);
matriceInterf=zeros(V, V); %contient le nbre de RB qui interfere entre une cellule i et une cellule j ==> NBRE D INTERFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%les trois variables svtes sont defini pr les ajustement des cellules
c1=R*1.732;
c2=R*0.866;
c3=R*1.500;
%le tableau ajust permet de manupuler les ajustements des cellules ainsi
%que les users
%le vecteur ajust correspond aux coordonnees des eNBs
eNB{1}.x=0; eNB{1}.y=0; %center 
eNB{2}.x=0; eNB{2}.y=c1; % Upper hex
eNB{3}.x=0; eNB{3}.y=-c1; % Lower hex
eNB{4}.x=c3; eNB{4}.y=-c2;  % Right lower hex
eNB{5}.x=c3; eNB{5}.y=c2;  % Right upper hex
eNB{6}.x=-c3; eNB{6}.y= c2;    % Left upper hex
eNB{7}.x=-c3; eNB{7}.y=-c2;  % Left lower hex
ta=1; %a revoir car pr le moment le rbUserPris est fix� � l �tape init alors que les users changent au fur et � mesure

OutputFileSINR_Throughput= strcat('fileSINR_Throughput.txt');
fiSINR_Debit = fopen(OutputFileSINR_Throughput, 'w');  %wt

OutputFileUser= strcat('nbrUserCell.txt'); %pr le d�bit
fi = fopen(OutputFileUser, 'w');  %wt

OutputFileGAIN= strcat('fctRecompGain.txt'); %pr le d�bit
fiRecompGain = fopen(OutputFileGAIN, 'w');  %wt

fileSortie= strcat('debitMoyInterfMoy.txt'); %pr le d�bit moyen et le nbre d interf�rences moyennes %26/08/2013
fichierA = fopen(fileSortie, 'a+');  %wt

OutpuVerfi= strcat('VerfiGain.txt'); %pr le d�bit
fiTest = fopen(OutpuVerfi, 'w');  %wt

gainTotalCell=zeros(V,N);

switch varianteALGO
    %ce switch a ete fait le 05/06/2013
    case 1
      PuisUsedAll=randi([1, PuisSeuil], 1, 1); %PuisMax
     %j ai mis la ligne pr�c�dente en commentaire le 11/07/2013 car je l ai d�plac� pr l utilis� lors du calcul de noise tt au d�but du code 
     for bb=1:V
            %tous les users fonctionnent � la m�me puissance
            for zz=1:N
             PuisUsed(bb,zz) = PuisUsedAll; %puissance d emission du RB zz au sein de la cellule zz 
             if (PuisUsedAll == PuisSeuil) 
                 Mat(t).matriceRNTP(bb,zz)=1; %utilisation de la puissance max
             else
                 Mat(t).matriceRNTP(bb,zz)=0;
             end
            end
        end
        
    case 2
        for aa=1:V
            for hh=1:N  %PuisMax
             PuisUsed(aa,hh) =randi([1, PuisSeuil], 1, 1);
              if (PuisUsed(aa,hh) == PuisSeuil) 
                 Mat(t).matriceRNTP(aa,hh)=1; %utilisation de la puissance max
             else
                 Mat(t).matriceRNTP(aa,hh)=0;
             end
            end
        end
        
    case 3
          PuisUsedAll=randi([1, PuisMax], 1, 1);
        %rester a completer ce cas par rapport a la distance d un RB et eNB
  
end

for c=1:V
    eNB{c}.porte=rayonPorte_eNB; %Km
    eNB{c}.puissanceMax=PuisMax; %db
end
%%%%%%%%%%
tp=linspace(0,2*pi,V); % g�n�re le m�me t 7 fois (pr les 7 cellules)
%Generating a hexagon with centre (0,0) and,
% To generate 6 adjacent hexagon
% Generating a hexagon 
grid on
hold on
%figure(1);
for j=1:V
    %Vertexes
    cell{j,1}.x = eNB{j}.x + R * cos(tp);
    cell{j,1}.y = eNB{j}.y + R * sin(tp);     
    plot(cell{j}.x,cell{j}.y, 'b');  %dessiner la cellule
    if j==1 
        plot(eNB{j}.x,eNB{j}.y,'rd'); %emplacement du eNB  ==> le central je le voulais en rouge "ro"
    else
        plot(eNB{j}.x,eNB{j}.y,'rd'); %emplacement du eNB
    end 
    cell{j,1}.nbrUser=randi([1, M], 1, 1);    %affecter un certain nbr d user par cellule
    fprintf(fi, '%d \t %d \n',  j, cell{j,1}.nbrUser);  
    cell{j,1}.cumulInterfRB=0;
    cell{j,1}.cumulDebit=0;
end      

%generation des RBs/Agent de maniere alea
%Generate 3N random points with square that is 2R by 2R
for i=1:V
bool=0;
Cx=[];
Cy=[];
while bool==0
%placer des RBs/Agent de maniere aleatoire dans la cellule i
%g�n�rer un nbre important de coordonn�es (3*N)
    c_x1 =eNB{i}.x + R-rand(1,3*N)*2*R;
    c_y1 =eNB{i}.y + R-rand(1,3*N)*2*R;
    %get the points within the polygon
    IN = inpolygon(c_x1, c_y1, cell{i}.x, cell{i}.y);
    %drop nodes outside the hexagon
    c_x1 = c_x1(IN);
    c_y1 = c_y1(IN);
 
    Cx=[Cx c_x1];
    Cy=[Cy c_y1];
    %07/08/2013
    %retirer les coordonn�es des eNBs
     Cx=setdiff(Cx,eNB{i}.x,'stable'); %cette fct permet d'enlever toutes les occurances de la coordonn�e x du eNB + ordonne le tableau 
     Cy=setdiff(Cy,eNB{i}.y,'stable');
%     Cx= find(Cx~=eNB{i}.x);
%     Cy= find(Cy~=eNB{i}.y);
%     
    %choose only N points
    if length(Cx)>= N
        %idx = randperm(length(Cx));
        randperm(length(Cx)); %ranger le vecteur Cx de maniere alea
        randperm(length(Cy));%ranger le vecteur Cy de maniere alea
        %recuperer les coordonnes (x,y) de chaque RB/Agent a placer dans la cellule i 
       % c_x11 = Cx(idx(1:N));
       % c_y11 = Cy(idx(1:N));
        for u=1:N
            %j ai mis directement un 1 car la notation "t" ne passe pas
            %!!!! 03 Juin 2013
           cell{i,1}.RB(u).x =Cx(u);
           cell{i,1}.RB(u).y = Cy(u);
           cell{i,1}.RB(u).dist= distance(eNB{i}.x, eNB{i}.y, cell{i,ta}.RB(u).x, cell{i,ta}.RB(u).y);
           cell{i,1}.RB(u).puissance=PuisUsed(i, u);
           cell{i,1}.nbrRBmodif=0; %27/08/2013
           if i==1  plot(cell{i,1}.RB(u).x, cell{i,1}.RB(u).y, 'g*'); %g*
           else plot(cell{i,1}.RB(u).x, cell{i,1}.RB(u).y, 'm*');
           end
        end
        bool=1;
    end
end
 % if i==1  plot(c_x11, c_y11, 'g*');
 % else plot(c_x11, c_y11, 'm*');
 % end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% placer les voisins a un saut de chaque cellule 
   cell{1,1}.voisins=[2 3 4 5 6 7];
   cell{2,1}.voisins=[1 3 7];
   cell{3,1}.voisins=[1 2 4];
   cell{4,1}.voisins=[1 3 5];
   cell{5,1}.voisins=[1 4 6];
   cell{6,1}.voisins=[1 5 7];
   cell{7,1}.voisins=[1 2 6];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%t=1 ==> effectuer la phase d'exploration
for k=1:V %etape init de mon algo
    %exploration step of my algo

    %placer les users dans chaque cellule => affectation alea pr l'etape init de mon algo    
    if M>N fprintf ('erreuuuurrrr \n');
    else
    % pris=[];
     cell{k,1}.rbUserPris=[];
     for h=1:cell{k,1}.nbrUser
       %placer les users sur les RBs en se basant sur l'OFDMA ==> canaux
       %orthogonaux
       %il n'existe pas plusieurs users dans la cellule k sur le meme RB
       test=0;
       while test ==0
       selectRB=randi([1, N], 1, 1);  %selectionner un RB parmis N pr chaque user 
       id=intersect(cell{k,1}.rbUserPris, selectRB);%cell{k}.rbUserPris au lieu du vecteur pris 
       if length(id)==0
         %il faut verifier si ce RB n a pas ete deja affecte
         cell{k,1}.user(h).x = cell{k,1}.RB(selectRB).x;
         cell{k,1}.user(h).y = cell{k,1}.RB(selectRB).y;
       %  plot(cell{k}.user{h}.x, cell{k}.user{h}.y, 'k+'); % pr visualiser
       %  les users
       
        % if k==1  plot(cell{k,1}.RB(selectRB).x, cell{k,1}.RB(selectRB).y, 'ro');
        % else
             plot(cell{k,1}.RB(selectRB).x, cell{k,1}.RB(selectRB).y, 'ko');
       % end
       
         cell{k,1}.user(h).rb = selectRB;
         Mat(t).tabRB(k,selectRB) = 1; % pr dire k ce rb est occupe 
         %j ai rajout� le lien avec  Mat(t), pr que je puisse comparer � l
         %instant (t) et (t-1) pr la convergence ==> modif fait le
         %03/07/2013
      
         %04/07/2013 ==> affecter un 2 � la case ou il y avait un 1 dans la
         %matriceRNTP pr dire que ce RB est utilis� et en plus il est �
         %haute puissance
         
         if (Mat(t).matriceRNTP(k,selectRB) == 1) 
             Mat(t).matriceRNTP(k,selectRB)=2; %utilisation de la puissance max
            %ds le cas ou le RB "selectRB" a ete modifie, il ne faut pas
            %oubli� de remettre la valeur de cette case � 1
         end
        %%%%%%%%%%%%%%%%%%%%%
         cell{k,1}.user(h).duration = randi([1, dur], 1, 1); %duree de communication
         %il faut calculer les distances entre chaque user et le eNB
         cell{k,1}.user(h).dist = distance(eNB{k}.x, eNB{k}.y, cell{k,1}.user(h).x, cell{k}.user(h).y);
         test =1; 
        % pris=[pris, selectRB]; %mise a jour de l ensemble des RB pris
         cell{k,1}.rbUserPris=[cell{k,1}.rbUserPris, selectRB]; %mise a jour de l ensemble des RB pris
        % cell{k}.user(h).puissance=PuisUsed;
         %else
        %   id
        %   length(id)
       end
      %si trouver alors rechercher � nouveau   
       end
     end
    %  cell{k}.rbUserPris %vecteur contenant les differents RB affecte pr les
    %  user pr la cellule k
    end
    %affecter les proba de collision pr chaque cellule
    sum=0;
    for d=1:length(cell{k,ta}.voisins)
        dd=cell{k,1}.voisins(d);
        if dd~=k 
            sum=sum + cell{dd}.nbrUser;
        end
    end
    cell{k,1}.probCollision=cell{k,ta}.nbrUser/sum;
end

%%%%%%%%%%%
continuer = -1;
sauv=1;
sauvegardddd=1;
okStable=0;
okStableA=0;
cellInterf=[];

%faire une fonction pr calculer le SINR ==> calculSINR
 %en prametres d entree: le num de la cellule et l'user 
 while ((t<=T_max) && (continuer ~= 0) && (okStable~=V))
fprintf(2,' t=%g  \n',t);
boolll=-1;
boolTest=-1;
%exploitation step 
  for q=1:V
% %    %chercher pour chaque cellule q  si c cellules voisines ont utilis�
% %    %les m�me RB qu'elle
     sommeDistUsers = 0; 
     for tt=1:length(cell{q,ta}.voisins) 
        %on suppose que les cellules restent � la config initiale (indice t=1) par rapport aux voisinages cell{q,1}.voisins
        voisin=cell{q,ta}.voisins(tt);
        Mat(t).matriceInterf(q,voisin)=0; %initialiser la case
        if voisin~=q %tt  
            cpt=0;
            [RB_common, indexCell1, indexCell2]= intersect(cell{q,ta}.rbUserPris, cell{voisin,ta}.rbUserPris);            %indexCell1: permet d'avoir les indexes au sein de la celle q
            %indexCell2: indexes pr la cellule t
            if (length(RB_common) > 0)
              cell{q,1}.cumulInterfRB=cell{q,1}.cumulInterfRB+length(RB_common); %20/08 pr calculer le nbre d'interf cumul
              cellInterf=[cellInterf, q];
              cellInterfOK=unique(cellInterf);
              LL{q}=RB_common;
              boolll=true;
              %il y a des RB en commun
              %il faut appliquer l'ago d'apprentissage
              % nbreCommun=length(RB_common);
              Mat(t).matriceInterf(q,voisin) = length(RB_common); %nbre de RB en interfe avec la cellule q
         
                for f=1:length(RB_common) %calcul de la plus grande partie du d�nominateur pr le caclul du SINR
                ww=RB_common(f);%num de RB
                ss=indexCell2(f); %num du user
                %le test "if" qui suit a ete commente 30/05/2013 car il a
                %ete fait juste pr des raisons de verification
%                 if cell{t}.RB(ww).dist == cell{t}.user(ss).dist
%                     cpt=cpt+1;
%                     fprintf ('%d %d OKIIIIIIIIIIIII %d %d \n',t, cpt, q, length(RB_common)); 
%                 end
% modified 05/06/2013 ==> integration de la puissance de chaque user
                sommeDistUsers=sommeDistUsers + cell{voisin,ta}.RB(ww).puissance * ((1/ cell{voisin,ta}.RB(ww).dist)^beta); %on peut egalement passer par l user
                %premiere etape: calculer les SINR
               
            end
                    %sommeDistUsers contient a ce niveau l impact des users utilisant le
                    %meme RB dans les cellules voisines a un saut

                    %qd on change un RB; il faut mettre a jour:
                    %cell{k}.probCollision, cell{d}.nbrUser, 

                    %%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%   %%%%%%
                    %%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%   %%%%%
                    %la ligne svt a ete mise le 03/07/2013, mais c pas sur que c le
                    %bon endroit
                    diffGainTotal=0;
                    for rbConfli=1:length(RB_common)     
                     wwRbConfli=RB_common(rbConfli);%num de RB
                     Mat(t).gainTotal(q,wwRbConfli)= 0; % erreur corrige le 02/07/2013; il faut ini cette variable
                     %%%%%%%%%%%%%%      affectation SINR     %%%%%%%%%%%%
                     cell{q,t}.RB(wwRbConfli).SINR = calculSINR(cell{q,ta}.RB(wwRbConfli).dist, sommeDistUsers, PuisUsed(q,wwRbConfli), beta, noise);
                     %10/07/2013: rajout de la ligne permettant de calculer le
                     %d�bit avec la formule de shannon
                     cell{q,t}.RB(wwRbConfli).Throughput = W * log(1 + cell{q,t}.RB(wwRbConfli).SINR);
                     cell{q,1}.cumulDebit=cell{q,1}.cumulDebit+cell{q,t}.RB(wwRbConfli).Throughput; %20/08
                     %cell{q,t}.RB(wwRbConfli).SINR %mis en commentaire 10/07/2013
                     %cell{q,t}.RB(wwRbConfli).Throughput %mis en commentaire 10/07/2013
                     %l'�criture dans les deux fichiers today 10/07/2013
                     fprintf(fiSINR_Debit, '%d \t %d \t %d \t %d \t %f \t %f \t %f \n', t,q, voisin,  wwRbConfli, cell{q,ta}.RB(wwRbConfli).dist, cell{q,t}.RB(wwRbConfli).SINR, cell{q,t}.RB(wwRbConfli).Throughput); %t \t cell{q,t}.RB(wwRbConfli).SINR
                      %t, '\t', cell{q,t}.RB(wwRbConfli).SINR, 
                     %  fprintf(fiDebit, '%d \t %d \t %d \t %f \n', t, q, wwRbConfli, cell{q,t}.RB(wwRbConfli).Throughput); %t \t cell{q,t}.RB(wwRbConfli).Throughput
                     %calcul de la fonction d'apprentissage 
                    Mat(t).qValue(q,wwRbConfli)=log(1+cell{q,t}.RB(wwRbConfli).SINR); %fct QValue 
                    Mat(t).apprentissageRB(q,wwRbConfli)=cell{q,ta}.probCollision * Mat(t).qValue(q,wwRbConfli); %fct d'apprentissage
                    %  fprintf('** sauv=%g\t\t q=%g\t\t wwRbConfli=%g \t \t voisin= %g\n',sauv,q,wwRbConfli, voisin);
                    if(t>1)   
                      if (length(intersect(T{sauv}.Cel{q},wwRbConfli )) > 0)    
                       Mat(t).gain(q,wwRbConfli)= Mat(t).apprentissageRB(q,wwRbConfli) - Mat(sauv).apprentissageRB(q,wwRbConfli); %cell{q,t}.probCollision*apprentissageRB(q,ww);
                       %  disp('???????????????');  
                       Mat(t).gainTotal(q,wwRbConfli) = Mat(t).gainTotal(q,wwRbConfli) + Mat(t).gain(q,wwRbConfli);
                       diffGainTotal = Mat(t).gainTotal(q,wwRbConfli) - Mat(sauv).gainTotal(q,wwRbConfli);
                       %06/08/2013                   
                      else
                       Mat(t).gain(q,wwRbConfli)= Mat(t).apprentissageRB(q,wwRbConfli);
                       Mat(t).gainTotal(q,wwRbConfli) = Mat(t).gainTotal(q,wwRbConfli) + Mat(t).gain(q,wwRbConfli);
                       diffGainTotal = Mat(t).gainTotal(q,wwRbConfli);
                     end   
                  else
                    %init 
                    Mat(t).gain(q,wwRbConfli)= Mat(t).apprentissageRB(q,wwRbConfli);
                    Mat(t).gainTotal(q,wwRbConfli)=0;    
                    Mat(t).gainTotal(q,wwRbConfli) = Mat(t).gainTotal(q,wwRbConfli) + Mat(t).gain(q,wwRbConfli);
                    Mat(t).gainCell(q)=0;
                    %%%%%%% 
                    diffGainTotal = Mat(t).gainTotal(q,wwRbConfli);% - Mat(t-1).gainTotal(q,wwRbConfli);
                end
                
                   gainTotalCell(q,wwRbConfli)=Mat(t).gainTotal(q,wwRbConfli);
                   fprintf('--------------- t=%g\t\t q=%g\t\t RB=%g \t \t gainTotal(t)=%f  \n',t,q, wwRbConfli,Mat(t).gainTotal(q,wwRbConfli));
               
               fprintf(fiRecompGain, '%d \t %d \t %d \t %f \t %f  \t %f \t %f   \t %f  \t %f   \n', t,q, wwRbConfli, Mat(t).gain(q,wwRbConfli),  Mat(t).gainTotal(q,wwRbConfli), Mat(t).apprentissageRB(q,wwRbConfli),   Mat(t).qValue(q,wwRbConfli),    cell{q,ta}.probCollision      ,diffGainTotal);  
              
                %04/07/2013 g fait sortir ce test, car au cas o il faut
                %changer de RB c mieux de refaire les calcul ailleurs
                if ( diffGainTotal < 0 )
                        % il faut changer le rb "wwRbConfli" au niveau de
                        % la celle q.
               %modifRB(cellSouci, RBsouci,nbrUser, rbUserPrisCell, tabRB, N )   
                        newRB=modifRB(q,wwRbConfli, cell{q,ta}.nbrUser, cell{q,ta}.rbUserPris  , Mat(t).tabRB ,N);
                      % newRB
                        %04/07/2013 ==> a voir
                        if (newRB ~= wwRbConfli)
                           cell{q,ta}.nbrRBmodif=cell{q,ta}.nbrRBmodif+1; %27/08
                            %05/07/2013 ==> ttes les lignes de code de ce
                            %test "if"; on �tait fait aujourd'hui
                            %choisir un RB                  ===> OK
                            %calculer son SNIR              ===> OK
                            %mettre � jour la matriceRNTP   ===> OK
                            % ainsi que la matrice tabRB    ===> OK
                            %et les champs li� o user
                            %mettre � jour cell{q,ta}.rbUserPris; en retirant
                            %de ce tableau le RB wwRbConfli et le remplacer �
                            %son endroit par le nouveau RB    
                        %    fprintf(2,'Je change %g \t avec \t %g \t vois %g \n ',wwRbConfli,newRB, voisin);
                            uRB =  find(cell{q,ta}.rbUserPris == wwRbConfli) ; %indexe de l user utilisant le wwRbConfli
                            cell{q,ta}.user(uRB).rb = newRB; %comment
                           % r�cup�rer le num du user uRB ??????
                            cell{q,ta}.rbUserPris(uRB)=newRB;
                           
                            Mat(t).tabRB(q,newRB) = 1; % pr dire k ce rb est occupe 
                            Mat(t).tabRB(q,wwRbConfli) = 0; %  
                     
                            cell{q,ta}.RB(newRB).SINR =0; %a calculer
                            cell{q,1}.cumulDebit = cell{q,1}.cumulDebit - cell{q,t}.RB(wwRbConfli).Throughput; %20/08
                   
                            cell{q,t}.RB(wwRbConfli).Throughput=0; %car il n est plus utilis�
                            cell{q,ta}.RB(wwRbConfli).SINR =0; %car il n est plus utilis�
                            
                            Mat(t).matriceRNTP(q,wwRbConfli)=1;
                            Mat(t).matriceRNTP(q,newRB)=2;
                           % fprintf ('*******  JE SUIS ICI ******** \n');
                            
                            %%%%%%%%%%%%% 11/07/2013  begin
                       
                            Mat(t).gainTotal(q,wwRbConfli)= 0; 
                            %%%%%%%%%%%%%%      affectation SINR     %%%%%%%%%%%%
                            Mat(t).gainTotal(q,newRB)= 0;    
                            
                         
                            %26/07/2013 voir si c utile de refaire le calcul des RB_common et de la  sommeDistUsersNew     
                    %513==>527        
                           [RB_commonNew, indexCell1New, indexCell2New]= intersect(cell{q,ta}.rbUserPris, cell{voisin,ta}.rbUserPris);            %indexCell1: permet d'avoir les indexes au sein de la celle q
          
                            
                            %26/07/2013
                           sommeDistUsersNew=0;
                         if(length(RB_commonNew)>0)
                           for f=1:length(RB_commonNew) %calcul de la plus grande partie du d�nominateur pr le caclul du SINR
                            ww=RB_common(f);%num de RB
                          %  ss=indexCell2(f); %num du user   
                            sommeDistUsersNew=sommeDistUsersNew + cell{voisin,ta}.RB(ww).puissance * ((1/ cell{voisin,ta}.RB(ww).dist)^beta); %on peut egalement passer par l user
                           end
                          cell{q,1}.cumulInterfRB=cell{q,1}.cumulInterfRB-length(RB_common)+length(RB_commonNew); %20/08 pr calculer le nbre d'interf cumul
              
                         end
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           
                            cell{q,t}.RB(newRB).SINR = calculSINR(cell{q,ta}.RB(newRB).dist, sommeDistUsersNew, PuisUsed(q,newRB), beta, noise);
                            %10/07/2013: rajout de la ligne permettant de calculer le
                            %d�bit avec la formule de shannon

                            cell{q,t}.RB(newRB).Throughput = W * log(1 + cell{q,t}.RB(newRB).SINR);
                            cell{q,1}.cumulDebit=cell{q,1}.cumulDebit+cell{q,t}.RB(newRB).Throughput; %20/08
                            %l'�criture dans les deux fichiers today 10/07/2013
                            fprintf(fiSINR_Debit, '%d \t %d \t %d \t %d \t %f \t %f \n', t,q, newRB, voisin,  cell{q,t}.RB(newRB).SINR, cell{q,t}.RB(newRB).Throughput);  

                            %calcul de la fonction d'apprentissage 
                            Mat(t).qValue(q,newRB)=log(1+cell{q,ta}.RB(newRB).SINR); %fct QValue
                            Mat(t).apprentissageRB(q,newRB)=cell{q,ta}.probCollision * Mat(t).qValue(q,newRB); %fct d'apprentissage

                            if(t>1) 
                                Mat(t).gain(q,newRB)= Mat(t).apprentissageRB(q,newRB) - Mat(t).apprentissageRB(q,wwRbConfli);     %26/07/2013  � voir avant c �tait   - Mat(t).apprentissageRB(q,newRB);  
                                Mat(t).gainTotal(q,newRB) = Mat(t).gainTotal(q,newRB) + Mat(t).gain(q,newRB);
                               %%%%%%% 
                               % Mat(t).gainCell(q)=Mat(t).gainCell(q)- Mat(t).gainTotal(q,wwRbConfli) + Mat(t).gainTotal(q,newRB);
                                diffGainTotal = Mat(t).gainTotal(q,newRB) - Mat(t).gainTotal(q,wwRbConfli);
                                %26/07/2013 � voir avant c �tait   - Mat(t).gainTotal(q,newRB);  
                            else
                                %init 
                                Mat(t).gain(q,newRB)=0;
                                Mat(t).gainTotal(q,newRB)=0; 
                                Mat(t).gain(q,newRB)=Mat(t).apprentissageRB(q,newRB);  
                                Mat(t).gainTotal(q,newRB) = Mat(t).gainTotal(q,newRB) + Mat(t).gain(q,newRB);
                               %%%%%%% 
                                Mat(t).gainCell(q)=0;
                                diffGainTotal = Mat(t).gainTotal(q,newRB);% - Mat(t-1).gainTotal(q,wwRbConfli);
                            end
                            gainTotalCell(q,newRB)=Mat(t).gainTotal(q,newRB);
                         %%%%%%%%%%%%% 11/07/2013 end pr cette partie de modif 
                          
                        else
                            %pas de changement 
                             Mat(t).matriceRNTP(q,wwRbConfli)=2;
                        end
                    else
                        %remise � z�ro de la variable pr la suite;
                        % ==> gain est soit > 0 (am�lior�) ou = 0
                        % (inchang�)
                        diffGainTotal = 0;
                      %  fprintf ('*******  JE SUIS LAAAAAAAAAAAAAAAAA ******** \n');
                          
                    end
                
            end
            else
               LL{q}=[];
              
            end
        end
     end
     
[RB_Cellll, ind1, ind2]=intersect(cell{q,ta}.rbUserPris,RB_common);
   %calculer le SINR et le debit de chacun de c RB ainsi que la
   %fct de r�compense
sumDit=0;
if (length(RB_Cellll) > 0)
    boolTest=true;
    RRC{q}=RB_Cellll;
  for uuRB=1:length(RB_Cellll)
      rb_A=RB_Cellll(uuRB);
      cell{q,t}.RB(rb_A).SINR = calculSINR(cell{q,ta}.RB(rb_A).dist, sumDit, PuisUsed(q,rb_A), beta, noise);
      cell{q,t}.RB(rb_A).Throughput = W * log(1 + cell{q,t}.RB(rb_A).SINR);
      cell{q,1}.cumulDebit=cell{q,1}.cumulDebit+cell{q,t}.RB(rb_A).Throughput; %20/08            
      Mat(t).qValue(q,rb_A)=log(1+cell{q,t}.RB(rb_A).SINR); %fct QValue 
      Mat(t).apprentissageRB(q,rb_A)=cell{q,ta}.probCollision * Mat(t).qValue(q,rb_A); %fct d'apprentissage
      %  fprintf('** sauv=%g\t\t q=%g\t\t wwRbConfli=%g \t \t voisin= %g\n',sauv,q,rb_A, voisin);     
      if (t>1)
          %27/08 ==> quelques petites modifs en utilisant la variable sauv
          %car c le m�me principe que lorsque l on ex�cute le m�canisme de
          %changement de RB
       if (length(intersect(T{sauvegardddd}.cellO{q},rb_A )) > 0)  
         Mat(t).gain(q,rb_A)= Mat(t).apprentissageRB(q,rb_A) - Mat(sauvegardddd).apprentissageRB(q,rb_A); 
         %cell{q,t}.probCollision*apprentissageRB(q,ww);
         %  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');  
         Mat(t).gainTotal(q,rb_A) = Mat(t).gainTotal(q,rb_A) + Mat(t).gain(q,rb_A);
         diffGainTotal = Mat(t).gainTotal(q,rb_A) - Mat(sauvegardddd).gainTotal(q,rb_A);
         %06/08/2013
        end
      else
         Mat(t).gain(q,rb_A)= Mat(t).apprentissageRB(q,rb_A);
         Mat(t).gainTotal(q,rb_A) = Mat(t).gainTotal(q,rb_A) + Mat(t).gain(q,rb_A);
      end
      gainTotalCell(q,rb_A)=Mat(t).gainTotal(q,rb_A);
      fprintf('######## t=%g\t\t q=%g\t\t RB=%g \t \t gainTotal(t)=%f  \n',t,q, rb_A,Mat(t).gainTotal(q,rb_A));
  end
else
     RRC{q}=[];
end

%ici il faut avoir une boucle pr tt les RB de chaque cellule pr calculer le
%gain de la cellule

cumulGainTotal=0;
for allRB=1:length(cell{q,ta}.rbUserPris)
    rbActuel=cell{q,ta}.rbUserPris(allRB);
    cumulGainTotal= cumulGainTotal + gainTotalCell(q,rbActuel); % Mat(t).gainTotal(q,rbActuel);
end
if(t>1)
        Mat(t).gainCell(q)=Mat(t-1).gainCell(q)+ cumulGainTotal; 
      %  fprintf('** t-1=%g\t\t q=%g\t\t gainCell(t)=%f \t \t gainCell(t-1)= %f\n',t-1,q,Mat(t).gainCell(q), Mat(t-1).gainCell(q));
 else
        Mat(t).gainCell(q)= cumulGainTotal; 
end

fprintf(fiTest, '%d \t %d \t %f \t %f \t  \n', q, t, Mat(t).gainCell(q), cell{q,ta}.probCollision );  
   


 
%arriv�e d un msg CQI  ==> 10/07/2013 ==> 20/08 modif d'emplacement de ce
%test
if (mod(t, t_CQI) ==0)
    cpt_CQI=cpt_CQI+1;  
        %  Mat(t).gainCell(q);    
    %�criture dans un fichier 20/08 la fct globale de chaque cellule pr tracer une courbe en fct du nbre d'it�rations
 %27/08
    OutputFileGainProb= strcat('Gain&Proba-', num2str(q), '.dat'); %pr les attentes et transmis
    if (cpt_CQI==1)
         fiDistrib = fopen(OutputFileGainProb, 'w');  %wt
   % fprintf(fiDistrib, '%d \t %f \t %f \n',  q,  PI{yy}(xx), sommeProba);  %indice de la trame et sa taille
    else
          fiDistrib = fopen(OutputFileGainProb, 'a+');  %wt
    end
    
    fprintf(fiDistrib, '%d \t %d \t %f \t %f \t  \n', q, t, Mat(t).gainCell(q), cell{q,ta}.probCollision );  
    fclose(fiDistrib);
end

end


   if ((cpt_RNTP >= 1) && (t> dur1RNTP) ) %on utilise cette variable pour �tre sur que l'on a bien re�u d�j� un premier msg RNTP
     for celParcour=1:V
      for inde=1:length(cell{celParcour,ta}.voisins) 
        %on suppose que les cellules restent � la config initiale (indice t=1) par rapport aux voisinages cell{q,1}.voisins
        vois=cell{celParcour,ta}.voisins(inde);
        if (mod((t+1), dur1RNTP)~=0)
        if (Mat(t).matriceInterf(celParcour,vois) >  Mat(mod((t+1), dur1RNTP)).matriceInterf(celParcour,vois))
           %le nbre d interf�rence a augment� ==> continuer � d�rouler l
           %algo
            continuer=1;
        else
            continuer=0; %il faut arr�ter l'algo, convergence OK
        end
        end
      end 
     end
   end
% % 06/08/2013
%==> condition de stabilit� ==> convergence de l algo
if t>1  
    switch varianteStab
        case 1    
            %utiliser la fct de gain globale au sein de chaque cellule
            diffG=0;
            for cc=1:V
                diffG=Mat(t).gainCell(cc)-Mat(t-1).gainCell(cc); 
                if (diffG==0)
                     okStable=okStable+1;
                     continuer=0;
                else
                     continuer=1;
                end
            end
        case 2
            %07/08/2013
            %voir par rapport aux SINR des RBs utilis�s
             diffSINR=0;
             tabSINRstable=zeros(1,V);
             for xx=1:V
                for allRBx=1:length(cell{xx,ta}.rbUserPris)
                    diffSINR=cell{xx,t}.RB(allRBx).SINR- cell{xx,t-1}.RB(allRBx).SINR; %Mat(t).gainCell(cc)-Mat(t-1).gainCell(cc); 
                    if (diffSINR==0)
                         okStableA=okStableA+1;
                         continuer=0;
                    else
                         continuer=1;
                    end
                end
                %modif rajouter le 28/08
                if(okStableA == length(cell{xx,ta}.rbUserPris)) 
                    tabSINRstable(xx)=1;
                end
             end
            
             
             for xw=1:V
                 if (tabSINRstable(xw)==1)
                     okStable=okStable+1;
                 end
             end
        case 3  
            %07/08/2013 ==> a venir
            %tester sur le nbre d interf�rences entre 2 it�rations non
            %cons�cutives pour chacune des cellules comme ce que j'avais
            %fait pr le SP3
            
            
    end
end

tConverg=tConverg+1;   
if boolll == 1
     sauv=t;
     for ce=1:V
         T{sauv}.Cel{ce}=LL{ce};

     end
end

if boolTest==1
    sauvegardddd=t;
    for cee=1:V
        T{sauvegardddd}.cellO{cee}=RRC{cee};
    end
end

%ce test permet d indiquer d'un msg RNTP est arriv� et qu il faut verifier
%par rapport � la convergence de l algo
   if (mod(t, t_RNTP) == 0)
     %arriver d un msg RNTP
     cpt_RNTP=cpt_RNTP+1; %compteur du nombre de msg RNTP
  
        % note le 03/07/2013: a voir ce qui suit
        % il faut comparer la matrice � l instant (t) et � (t-1) pr voir s
        % il y a eu changement si c le cas pas de convergence encore
        
%      for celParcour=1:V
%       for inde=1:length(cell{celParcour,ta}.voisins) 
%         %on suppose que les cellules restent � la config initiale (indice t=1) par rapport aux voisinages cell{q,1}.voisins
%         vois=cell{celParcour,ta}.voisins(inde);
%         if (Mat(t).matriceInterf(celParcour,vois) >  Mat(t).matriceInterf(celParcour,vois))
%             continuer=1;
%         else
%             continuer=0; %il faut arr�ter l'algo, convergence OK
%         end
%       end 
%      end
        
   end
   
 t=t+1;  
 end
 
 if (t>1)
     %26/08 rajout de ce test; et correction que sur la division c par
     %(t-1) et non t
    for qa=1:V
     %20/08==> indice de perf
        debitMoyen(qa)=cell{qa,1}.cumulDebit/(t-1);
        nbreInterfMoyen(qa)=cell{qa,1}.cumulInterfRB/(t-1);
        fprintf(fichierA, '%d \t %d \t %d  \t %d  \t %f \t %f \t %d \n', (t-1), qa, N, cell{qa,1}.nbrUser,  debitMoyen(qa), nbreInterfMoyen(qa), cell{qa,ta}.nbrRBmodif );  
      %pr le tracer de ces deux courbes debit moyen et nbre d interference moyenne, cela se fera avec gnuplot ou excel par la suite car ilfaut tte les valeurs      
       %le N correspond au nbre de RB max/cell
    end
 end
 
 if (okStable== V)
  fprintf ('---------  FIN CONVERGENCE OK   --------- re�u %d  \t msg RNTP  ---- \t %d msg CQI -- %d s  \t duree de convergence  \n', cpt_RNTP, cpt_CQI,  tConverg);
 end
 
fclose(fiSINR_Debit); %pr v�rifier les valeurs des d�bits et SINR
fclose(fi);
fclose(fiTest);
fclose(fiRecompGain);
fclose(fichierA); %les graphiques se feront en dehors de ce code matlab

axis square
hold off