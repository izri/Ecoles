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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
%close all;
clf %clear figure
PuisMax= 50;
dur=10;
epsilon=10^(-10);
t=1; %indice de temps
V=7; %number of cells => pr le moment nous considerons uniquement 7 cellules
alpha=2;
noise=10^(-alpha)*PuisMax; %noise variance  on peut egalement le prendre directement comme etant 10^(-alpha)
beta=4; %valeur essentiel pour le calcul du SINR d'un user
N = 5;     %Number of RBs/cell
R = 15;     %Radius of Hexagon
M = N;     %Number of users => au max nbre user= nbre de RBs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tabRB=zeros(V, N);
apprentissageRB=zeros(V, N);
qValue=zeros(V, N);
gain=zeros(V, N);
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
for c=1:V
    eNB{c}.porte=10; %Km
    eNB{c}.puissanceMax=PuisMax; %db
end
%%%%%%%%%%
t=linspace(0,2*pi,V); % g�n�re le m�me t 7 fois (pr les 7 cellules)
%Generating a hexagon with centre (0,0) and,
% To generate 6 adjacent hexagon
% Generating a hexagon 
grid on
hold on
for j=1:V
    %Vertexes
    cell{j}.x = eNB{j}.x + R * cos(t);
    cell{j}.y = eNB{j}.y + R * sin(t);     
    plot(cell{j}.x,cell{j}.y);  %dessiner la cellule
    if j==1 
        plot(eNB{j}.x,eNB{j}.y,'ro'); %emplacement du eNB  
    else
        plot(eNB{j}.x,eNB{j}.y,'ko'); %emplacement du eNB
    end 
    cell{j}.nbrUser=randi([1, M], 1, 1);    %affecter un certain nbr d user par cellule
end      

%generation des RBs/Agent de maniere alea
%Generate 3N random points with square that is 2R by 2R
for i=1:V
bool=0;
Cx=[];
Cy=[];
while bool==0
%placer des RBs/Agent de maniere aleatoire dans la cellule i
    c_x1 =eNB{i}.x + R-rand(1,3*N)*2*R;
    c_y1 =eNB{i}.y + R-rand(1,3*N)*2*R;
    %get the points within the polygon
    IN = inpolygon(c_x1, c_y1, cell{i}.x, cell{i}.y);
    %drop nodes outside the hexagon
    c_x1 = c_x1(IN);
    c_y1 = c_y1(IN);
    Cx=[Cx c_x1];
    Cy=[Cy c_y1];
    %choose only N points
    if length(Cx)>= N
        %idx = randperm(length(Cx));
        randperm(length(Cx)); %ranger le vecteur Cx de maniere alea
        randperm(length(Cy));%ranger le vecteur Cy de maniere alea
        %recuperer les coordonnes (x,y) de chaque RB/Agent a placer dans la cellule i 
       % c_x11 = Cx(idx(1:N));
       % c_y11 = Cy(idx(1:N));
        for u=1:N
         cell{i}.RB(u).x =Cx(u);
         cell{i}.RB(u).y = Cy(u);
         cell{i}.RB(u).dist= distance(eNB{i}.x, eNB{i}.y, cell{i}.RB(u).x, cell{i}.RB(u).y);
         cell{i}.RB(u).puissance=PuisMax;
           if i==1  plot(cell{i}.RB(u).x, cell{i}.RB(u).y, 'g*');
           else plot(cell{i}.RB(u).x, cell{i}.RB(u).y, 'm*');
           end
        end
        bool=1;
    end
end
 % if i==1  plot(c_x11, c_y11, 'g*');
 % else plot(c_x11, c_y11, 'm*');
 % end
end  
%t=1 ==> effectuer la phase d'exploration
for k=1:V %etape init de mon algo
    %exploration step of my algo

    %placer les users dans chaque cellule => affectation alea pr l'etape init de mon algo    
    if M>N fprintf ('erreuuuurrrr \n');
    else
    % pris=[];
     cell{k}.rbUserPris=[];
     for h=1:cell{k}.nbrUser
       %placer les users sur les RBs base sur l'OFDMA
       %il n'existe pas plusieurs users dans la cellule k sur le meme RB
       test=0;
       while test ==0
       selectRB=randi([1, N], 1, 1);  %selectionner un RB parmis N pr chaque user 
       id=intersect(cell{k}.rbUserPris, selectRB);%cell{k}.rbUserPris au lieu du vecteur pris 
       if length(id)==0
         %il faut verifier si ce RB n a pas ete deja affecte
         cell{k}.user(h).x = cell{k}.RB(selectRB).x;
         cell{k}.user(h).y = cell{k}.RB(selectRB).y;
       %  plot(cell{k}.user{h}.x, cell{k}.user{h}.y, 'k+'); % pr visualiser
       %  les users
         cell{k}.user(h).rb = selectRB;
         tabRB(k,selectRB) =1; % pr dire k ce rb est occupe
         cell{k}.user(h).duration = randi([1, dur], 1, 1); %duree de communication
         %il faut calculer les distances entre chaque user et le eNB
         cell{k}.user(h).dist=distance(eNB{k}.x, eNB{k}.y, cell{k}.user(h).x, cell{k}.user(h).y);
         test =1; 
        % pris=[pris, selectRB]; %mise a jour de l ensemble des RB pris
         cell{k}.rbUserPris=[cell{k}.rbUserPris, selectRB]; %mise a jour de l ensemble des RB pris
        % cell{k}.user(h).puissance=PuisMax;
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
    for d=1:V
        if d~=k 
            sum=sum + cell{d}.nbrUser;
        end
    end
    cell{k}.probCollision=cell{k}.nbrUser/sum;
end


%faire une fonction pr calculer le SINR ==> calculSINR
 %en prametres d entree: le num de la cellule et l'user 
 
  
%exploitation step 
  for q=1:V
% %    %chercher pour chaque cellule q  si c 6 cellules voisines ont utilis�
% %    %les m�me RB qu'elle
     for t=1:V
        if q~=t
            sommeDistUsers=0; 
            cpt=0;
            [RB_common, indexCell1, indexCell2]= intersect(cell{q}.rbUserPris, cell{t}.rbUserPris);
            %indexCell1: permet d'avoir les indexes au sein de la celle q
            %indexCell2: indexes pr la cellule t
        
            if length(RB_common) > 0
            %il y a des RB en commun
            %il faut appliquer l'ago d'apprentissage
            % nbreCommun=length(RB_common);
            for f=1:length(RB_common)
                ww=RB_common(f);%num de RB
                ss=indexCell2(f); %num du user
                %le test "if" qui suit a ete commente 30/05/2013 car il a
                %ete fait juste pr des raisons de verification
%                 if cell{t}.RB(ww).dist == cell{t}.user(ss).dist
%                     cpt=cpt+1;
%                     fprintf ('%d %d OKIIIIIIIIIIIII %d %d \n',t, cpt, q, length(RB_common)); 
%                 end
                sommeDistUsers=sommeDistUsers + (1/ cell{t}.RB(ww).dist)^beta; %on peut egalement passer par l user
                %premiere etape: calculer les SINR
            end
            %sommeDistUsers contient a ce niveau l impact des users utilisant le
            %meme RB dans les cellules voisines a un saut
            cell{q}.RB(ww).SINR = calculSINR(cell{q}.RB(ww).dist, sommeDistUsers, PuisMax, beta, noise);
           
            
            %calcul de la fonction d'apprentissage 
            qValue(q,ww)=log(1+cell{q}.RB(ww).SINR); %fct QValue
            apprentissageRB(q,ww)=cell{q}.probCollision*qValue(q,ww); %fct d'apprentissage
          %  gain(q,ww)=cell{q}.probCollision*apprentissageRB(q,ww);
            
            %qd on change un RB; il faut mettre a jour:
            %cell{k}.probCollision, cell{d}.nbrUser, 
            end
        end
     end
% 
  end
% 


axis square
hold off