%15/07/2013 by Nora IZRI
    %%%%%%%%%%%%% History
      %   modified 16/07/2013 
      %rajout des sauvegardes de r�sultat dans les fichiers
      %modified 17/07/2013
      % processus poisson en entree de chacune des files
      
%PRiSM Laboratory
%23/07/2013 ==> ok pr le calcul des distributions de chaque files
%==> il faudra int�grer les distributions des trames
%� rajouter la notion de stabilit� ==> ligne 151
%voir la ligne 204 par rapport � la variable t3 est ce k je peux la laisser
%la bas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
%close all;
clf %clear figure
 
grid on
hold on
%on suppose que la trame a deja une partie ctrl et entete ==> ce qui
%signifie que la variable C est associee uniquement a la partie info
C=10; %taille max de la trame
Cap=C;
N=2; %nbre de files 
n=1; %indice de la trame courante
M=5; %nbre de paquets max a generer en entree
T_max=10; %la duree de simul
TTI=1; %la duree de construction de la trame;
%H=T/TTI; %nbre de trames possibles de generer
if mod(T_max,TTI)==0
    H=T_max/TTI; %nbre de TTI qui passe
else
    H=floor(T_max/TTI)+1;
end

a=3; %valeur max pr le seuil min pr g�n�rer le PBR
b=5; %valeur max pr le seuil max pr g�n�rer le max
Buffer=10; %taille max du buffer
%lambda=6; 
hm=10; %valeur max de lambda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputFileTrame= strcat('taillesTrames.dat'); %pr les trames
fiTrame = fopen(OutputFileTrame, 'w');  %wt

OutputFile= strcat('indicesPerf.dat'); %pr les attentes et transmis
fi = fopen(OutputFile, 'w');  %wt


somme=0;

j=1;
c_min=zeros(1,N);
c_max=zeros(1,N);
%%%%% section affectation des valeurs buffer, min et max associ� pr chaque file
while ((j<=N) && (Cap>=0))
    buffer(j)=Buffer; %on suppose que toutes les files ont la meme taille de buffer
%  lambda(j)=randi([1, hm], 1, 1);
    %parametres min et max pr la QoS
    %pr le moment tte les files on les meme seuils min et max
    c_min(j)= randi([1, a], 1, 1);
    c_max(j)=randi([1, Cap], 1, 1); %il ne faut oublier que la somme des c_max =C
    somme=somme+c_max(j);
    lambda(j)= c_min(j); %randi([ c_min(j), c_max(j)], 1, 1); %pr verifier que les files sont stables, la somme des rho est < � 1
   
    if ((Cap-c_max(j) <0) && j > N) 
        break;
    else
        if (Cap-c_max(j) > 0)
             Cap=Cap-c_max(j);
        end
    end
       j=j+1;
end


%somme %ca correspond � la capacit� de la trame � travers les c_max

% if (somme > C)
%     %il faut refaire la g�n�ration des max
%     for j=1:N
%        c_max(j)=randi([1, b], 1, 1); 
%     end
% end

%%%%%%%%%%%%%%%%% section processus d arrivee au niveau des files %%%%%%%%%
%15/07/2013
% v=1;
% s=1; %indice du temps pr les arriv�es mais il faut modifier cela par des instants peut �tre
% e=1;
% z=s+TTI;
% %chaque file i correspond a une M/D/L_i/B_i
% while s<=T
%     if e < s <=z
%         %il faut transformer les arrives de chaque file par un processus de
%         %poisson =>fct de repartition de l expo: y=f(x)=1-e^(-mu x)
%         %donc on aura : x= - ln(1-y) / mu
%         %il ne faut pas oublier la stabilite de la file en calculant 
%         %rho = lamdba E[X]/debit; en considerant que mu=debit/E[X]
%       for g=1:N
%         trame(v).file(g).A=randi([1, M], 1, 1); %il faut specifier un processus d arrivee 
%       end
%       if s==z 
%         e=s;
%         z=e+TTI;
%         v=v+1;
%       end
%     end
%     s=s+1;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%etant donn� qu'avec ce model, on suppose que les trames ont �t� d�j�
%pr�-rempli par les PBRs
minTotal=0;
for d=1:N
    minTotal = minTotal+ c_min(d);
end

capacity=somme-minTotal; %capacit� restante dans la trame
 %r�cup de data d entree � partir du fichier 
% filename1='arriveFiles.dat';
% dataArribe=load(filename1);
 
 %extraire les valeurs des  arrivees du fichier 
 
 ArriveFile=zeros(N,H);
 t3=zeros(1,N);
 % time Ar instantGener cumulArrive
 [tempsAr ArrivInst instantGene ArriveFile t3]=expoGener2(lambda, T_max, M, N, TTI, H, Buffer);
 bool=0;
 [linf col]=size(tempsAr);
 [linF nbrAr ]=size(ArrivInst);
%linf == nbre de files
%on sait que: col=nbrAr mais c juste pr tester
stock=zeros(1,N);
for u=1:N
    stock(u)=1;
end
tsim=zeros(1,N); 
mu=1;
ni=zeros(N,Buffer+1);
Pi=zeros(1,Buffer+1);
 
tailleRetir=zeros(1,N);
t1=0;
%%%%%%%%%%% section creation des trames %%%%%%%%%%%%
%crit�re de stabilit� � rajoute rpar rapport � la taille des trames
 nb=zeros(1,N);
while ((n<=T_max) && (t1<=T_max))

      for i=1:N
          %indiquer que les sorties et les attentes sont nulles
         trame(n).file(i).W=0;
         trame(n).file(i).out=0;
         trame(n).file(i).A=  randi([1, M], 1, 1); %� transformer en proccessus de poisson
      end
      trame(n).taille=0;
      sommeOUT=0;
      h=1;
      if(bool ==0) sizeT=0;
      else
          sizeT=0;
          for in=1:N
             sizeT=sizeT+tailleRetir(in);
          end
      end
   
        while ( (h<=N) && (sizeT < capacity) ) %on v�rifie aussi par rapport � la taille de la trame
        count=0;
        hg=stock(h);

       while ((hg<col) && (count <TTI))
           count=count+tempsAr(h,hg);
          % nb(h)=nb(h)+ArrivInst(h,hg);
           nb(h)= min( buffer(h), nb(h)+ArrivInst(h,hg));
          
           if (count < TTI)
            if (nb(h)>0) 
                ni(h,nb(h))=ni(h,nb(h))+abs(count-tsim(h));
            end
            tsim(h)=count;
           end
             hg=hg+1;
        end
       
          trame(n).file(h).A =  ArriveFile(h,n);  
          trame(n).file(h).L = min(max(0,c_max(h)-trame(n).file(h).out ), trame(n).file(h).W +trame(n).file(h).A);
          trame(n).file(h).out = min(max(0, capacity-trame(n).taille)+sommeOUT, trame(n).file(h).L); %transmis
          sommeOUT = sommeOUT+trame(n).file(h).out; %tt ce que j ai pu extraire jusqu � pr�sent
          trame(n).file(h).W =max(0, min(buffer(h), trame(n).file(h).W+trame(n).file(h).A)- trame(n).file(h).out); %Attente
          if (count >= TTI)
              if (nb(h)>0) 
               ni(h,nb(h))=ni(h,nb(h))+abs(TTI-tsim(h));
               nb(h)=max(0, nb(h)- trame(n).file(h).out); %service
              end
              tsim(h)=TTI;
              stock(h)=hg-1; %pr garder une trame de l indice ou l on c arr�t�
         end 
        
          %  t3(h)=t3(h)+tsim(h); %23/07/2013
          
          if (trame(n).taille+trame(n).file(h).out <= capacity) 
              trame(n).taille= trame(n).taille+trame(n).file(h).out;
          else
              tailleRetir(h)=trame(n).file(h).out;
              bool=1;
          end 
          
          sizeT=trame(n).taille;
        
          fprintf(fi, '%d \t %d \t %d \t %d \t %d \t %d \t %d\n', h, n ,  trame(n).file(h).out, trame(n).file(h).L, trame(n).file(h).W, sommeOUT,  trame(n).taille);  %indice de la trame et sa taille
        %  plot( n, trame(n).file(h).out, '-*','color','red','LineWidth',2.0);
          h=h+1;
        end %fin de la boucle qui parcours ttes les files
      
          fprintf(fiTrame, '%d \t %d \n',  n, trame(n).taille);  %indice de la trame et sa taille
          
         % plot( n, trame(n).taille, '-*','color','blue','LineWidth',2.0); % figure
         %plot(x2,y2,'-*','color','blue','LineWidth',2.0);
 n=n+1;
 t1=t1+1;

end
fclose(fiTrame);
fclose(fi);
% 
% 23/07/2013
for rr=1:N
 Pi=ni(rr,:)/t3(rr);
 PI{rr}=[(1-sum(Pi)) Pi];
 PI{rr}
 Pi=[];
end



for yy=1:N
    OutputFile= strcat('distribFile-', num2str(yy), '.dat'); %pr les attentes et transmis
    fiDistrib = fopen(OutputFile, 'w');  %wt
    sommeProba=0;
    for xx=1:buffer(yy)
       fprintf(fiDistrib, '%d \t %d \n',  xx,  PI{yy}(xx));  %indice de la trame et sa taille
       sommeProba=sommeProba+  PI{yy}(xx); %pr v�rifier que la distribution est bien = � 1
    end
    fprintf(fiDistrib, '%d \t \n',  sommeProba);  %indice de la trame et sa taille   
    fclose(fiDistrib);
end







% 
% 
% 
% 
% 
% %23/07/2013 ==> j ai mis en commentaire tt ce qui suit pr le d�placer sur
% le fichier tracerResultats.m
% 
% 
% 
% 
% %16/07/2013
% %tracer les courbes
 filename1='taillesTrames.dat';
 filename2='indicesPerf.dat';
%  
%  %tracer les tailles des trames 
      fileT=load(filename1);
%     % y1=load(filename1,1,'A1:A10');
      xlabel('Trame ID');
      ylabel('Trame Size');
      figure(1);
      plot(fileT(:,1),fileT(:,2),'-+','color','red','LineWidth',2.0);
%      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     dataFile=load(filename2);
     [n,k]=size(dataFile);
if ((n>0) && (k>0))     
     [jj,ll]=sort(dataFile(:,1));
     dataFile=dataFile(ll,:);
     deb=0;
     figure(2);
     t=[];
     color=['r', 'g', 'b', 'm']; 
 
   for ii=1:N %nombre de file
        v=find(dataFile(:,1)==ii); % B= sortrows(A)  
   
        G{ii}=dataFile(deb+1:n, 2:k);
   
        %legend('Queue',1);   %1 en haut � droite
        %xlabel('TRame ID');
        %ylabel('Wait Queue');
       % figure(ii+1);
        plot(G{ii}(:,1),G{ii}(:,4), color(ii)); %,'*','color','blue','LineWidth',2.0);
        %plot(G{ii}(:,1),G{ii}(:,4),'r','LineWidth',1.5,'Marker','*');
        Spec_concat = strcat('Queue' ,num2str(ii)); 
        t=[t; Spec_concat]; 
        hold on
        if length(v)>0  deb=v(length(v));     
        end
   end
      legend(t(1:N,:));
      xlabel('Trame ID');
      ylabel('Wait Queue');
else
    fprintf('msg erreur ==> fichier vide \n');
    
end
%     figure(2);
%     plot(dataFile(:,2),dataFile(:,5),'*','color','blue','LineWidth',2.0);
 hold off